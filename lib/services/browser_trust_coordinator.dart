import 'dart:async';
import 'dart:collection' show UnmodifiableListView;
import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../constants.dart';
import 'cf_challenge_logger.dart';
import 'cf_clearance_refresh_service.dart';
import 'discourse/discourse_service.dart';
import 'network/cookie/boundary_sync_service.dart';
import 'network/cookie/cookie_jar_service.dart';
import 'network/cookie/webview_cookie_priming.dart';
import 'preloaded_data_service.dart';
import 'webview_session_cookie_refresh_service.dart';
import 'webview_settings.dart';
import 'windows_webview_environment_service.dart';

enum BrowserTrustPreloadPath { native, webView }

/// 浏览器信任编排器。
///
/// 负责启动/恢复阶段的浏览器态准备，避免 WebView priming、session bootstrap、
/// cf_clearance 维护、预加载请求在 main / widget 中散落。
class BrowserTrustCoordinator {
  BrowserTrustCoordinator._();
  static final BrowserTrustCoordinator instance = BrowserTrustCoordinator._();

  static const Duration _trustedClearanceMinTtl = Duration(minutes: 10);
  static const Duration _webViewPreloadTimeout = Duration(seconds: 25);
  static const Duration _domSnapshotTimeout = Duration(seconds: 12);
  static const Duration _originLoadTimeout = Duration(seconds: 8);
  static const Duration _backgroundPauseDelay = Duration(seconds: 8);
  static const Duration _diagnosticBackgroundPauseDelay = Duration(seconds: 60);

  final CookieJarService _jar = CookieJarService();
  final PreloadedDataService _preload = PreloadedDataService();

  Future<void>? _activePreload;
  Future<bool>? _activeBrowserTrust;
  Timer? _backgroundPauseTimer;

  BrowserTrustPreloadPath? _lastPreloadPath;

  BrowserTrustPreloadPath? get lastPreloadPath => _lastPreloadPath;

  void setNavigatorContext(BuildContext context) {
    DiscourseService().setNavigatorContext(context);
    _preload.setNavigatorContext(context);
  }

  /// 启动期轻量准备：只做 cookie priming，不加载首页，不阻塞 runApp。
  void prepareStartup({String reason = 'startup'}) {
    unawaited(
      _primeWebViewCookies(reason: reason).catchError((Object e) {
        _log('startup priming failed: $e', level: 'warning');
      }),
    );
  }

  void pauseForBackground() {
    _backgroundPauseTimer?.cancel();
    final delay = CfChallengeLogger.isEnabled
        ? _diagnosticBackgroundPauseDelay
        : _backgroundPauseDelay;
    _log('schedule cf_clearance refresh pause: delay=${delay.inSeconds}s');
    _backgroundPauseTimer = Timer(delay, () {
      _backgroundPauseTimer = null;
      _log('execute delayed cf_clearance refresh pause');
      CfClearanceRefreshService().pause();
    });
  }

  /// 前台恢复：恢复 cf_clearance 维护，并在后台补一次浏览器 session bootstrap。
  void resumeFromBackground({String reason = 'resume', bool force = false}) {
    final hadPendingPause = _backgroundPauseTimer != null;
    _backgroundPauseTimer?.cancel();
    _backgroundPauseTimer = null;
    if (hadPendingPause) {
      _log('cancel scheduled cf_clearance refresh pause: reason=$reason');
    }
    CfClearanceRefreshService().resume();
    unawaited(
      ensureBrowserTrust(reason: reason, force: force).catchError((Object e) {
        _log('resume browser trust failed: $e', level: 'warning');
        return false;
      }),
    );
  }

  /// 确保预加载完成。可信时走 native Dio；不可信时只在启动期临时 WebView 中
  /// 加载一次首页并复用 HTML hydrate。
  Future<void> ensurePreloaded({String reason = 'unknown'}) {
    if (_preload.isLoaded) return Future.value();

    final active = _activePreload;
    if (active != null) {
      _log('reuse active preload: reason=$reason');
      return active;
    }

    late final Future<void> future;
    future = _ensurePreloadedInternal(reason: reason).whenComplete(() {
      if (identical(_activePreload, future)) {
        _activePreload = null;
      }
    });
    _activePreload = future;
    return future;
  }

  Future<bool> ensureBrowserTrust({
    String reason = 'unknown',
    bool force = false,
  }) {
    if (!force) {
      final active = _activeBrowserTrust;
      if (active != null) return active;
    }

    late final Future<bool> future;
    future = _ensureBrowserTrustInternal(reason: reason).whenComplete(() {
      if (identical(_activeBrowserTrust, future)) {
        _activeBrowserTrust = null;
      }
    });
    _activeBrowserTrust = future;
    return future;
  }

  void startClearanceRefresh({String reason = 'unknown'}) {
    _log('start cf_clearance refresh: reason=$reason');
    CfClearanceRefreshService().start();
  }

  Future<void> _ensurePreloadedInternal({required String reason}) async {
    final nativeTrusted = await _isNativePreloadTrusted();
    if (nativeTrusted) {
      _lastPreloadPath = BrowserTrustPreloadPath.native;
      _log('preload path=native reason=$reason');
      try {
        await _preload.ensureLoaded();
        _log('native preload success reason=$reason');
        _startClearanceRefreshIfLoggedIn();
        return;
      } catch (e) {
        _log(
          'trusted native preload failed, switching to startup WebView: $e',
          level: 'warning',
        );
      }
    }

    _log('preload path=startup_webview reason=$reason');
    var hydrated = false;
    try {
      hydrated = await _hydratePreloadThroughWebView(
        reason: reason,
      ).timeout(_webViewPreloadTimeout);
    } on TimeoutException {
      _log('startup WebView preload timeout', level: 'warning');
    }
    if (hydrated) {
      _lastPreloadPath = BrowserTrustPreloadPath.webView;
      _log('startup WebView preload success reason=$reason');
      _startClearanceRefreshIfLoggedIn();
      return;
    }

    _lastPreloadPath = BrowserTrustPreloadPath.native;
    _log(
      'startup WebView preload unavailable, fallback native reason=$reason',
      level: 'warning',
    );
    await _preload.ensureLoaded();
    _log('fallback native preload success reason=$reason');
    _startClearanceRefreshIfLoggedIn();
  }

  Future<bool> _ensureBrowserTrustInternal({required String reason}) async {
    _log('browser trust sync begin reason=$reason');
    await _primeWebViewCookies(reason: reason);
    final synced = await WebViewSessionCookieRefreshService.instance
        .ensureSynced(reason: reason, force: true);
    _log('browser trust sync end reason=$reason synced=$synced');
    _startClearanceRefreshIfLoggedIn();
    return synced;
  }

  Future<void> _primeWebViewCookies({required String reason}) async {
    try {
      await WebViewCookiePriming.instance.prime(AppConstants.baseUrl);
    } catch (e) {
      _log(
        'WebView cookie priming failed: reason=$reason $e',
        level: 'warning',
      );
      rethrow;
    }
  }

  Future<bool> _hydratePreloadThroughWebView({required String reason}) async {
    await _primeWebViewCookies(reason: '$reason:webview_preload');
    _log('startup WebView create reason=$reason');

    var loadCompleter = Completer<void>();
    HeadlessInAppWebView? webView;

    webView = HeadlessInAppWebView(
      webViewEnvironment: io.Platform.isWindows
          ? WindowsWebViewEnvironmentService.instance.environment
          : null,
      initialSettings: WebViewSettings.headless,
      initialUserScripts: _startupPreloadScripts(),
      onReceivedServerTrustAuthRequest: (_, challenge) =>
          WebViewSettings.handleServerTrustAuthRequest(challenge),
      onWebViewCreated: (createdController) {
        WebViewSettings.registerJsErrorReporter(createdController);
      },
      onLoadStop: (_, _) {
        if (!loadCompleter.isCompleted) {
          loadCompleter.complete();
        }
      },
      onReceivedError: (_, request, error) {
        _log(
          'startup WebView error: url=${request.url}, ${error.description}',
          level: 'warning',
        );
      },
    );

    try {
      await webView.run();
      final c = webView.webViewController;
      if (c == null) return false;

      if (io.Platform.isWindows) {
        await c.loadUrl(
          urlRequest: URLRequest(url: WebUri(_windowsBootstrapUrl)),
        );
        try {
          await loadCompleter.future.timeout(_originLoadTimeout);
        } on TimeoutException {
          debugPrint('[BrowserTrust] Windows origin bootstrap timeout');
        }
        await _writeStartupShell(c);
      } else {
        await c.loadData(
          data: _startupShellHtml,
          baseUrl: WebUri(AppConstants.baseUrl),
          mimeType: 'text/html',
          encoding: 'utf-8',
        );
      }

      loadCompleter = Completer<void>();
      await _navigateToHome(c);
      await _waitForLoad(loadCompleter);
      _log('startup WebView home loaded, syncing cookies reason=$reason');
      await _syncCookiesFromController(c);

      final html = await _readPreloadedSnapshot(c);
      final hydrated =
          html != null &&
          html.isNotEmpty &&
          await _preload.hydrateFromHtml(html);
      _log(
        'startup WebView snapshot html=${html != null && html.isNotEmpty} hydrated=$hydrated reason=$reason',
        level: hydrated ? 'info' : 'warning',
      );

      final tToken = await _jar.getTToken();
      if (tToken != null && tToken.isNotEmpty) {
        _log('startup WebView session bootstrap begin reason=$reason');
        await WebViewSessionCookieRefreshService.instance.runOnController(
          c,
          reason: '$reason:startup_webview',
          pluginCandidates: _preload.pluginCandidatesSync,
        );
        await _syncCookiesFromController(c);
        _log('startup WebView session bootstrap end reason=$reason');
      } else {
        _log('startup WebView session bootstrap skipped: no _t');
      }

      return hydrated;
    } catch (e) {
      _log('startup WebView preload failed: $e', level: 'warning');
      return false;
    } finally {
      try {
        await webView.dispose();
      } catch (e) {
        _log('dispose startup WebView failed: $e', level: 'warning');
      }
    }
  }

  Future<void> _navigateToHome(InAppWebViewController controller) async {
    await controller.loadUrl(
      urlRequest: URLRequest(
        url: WebUri(AppConstants.baseUrl),
        headers: const {
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        },
      ),
    );
  }

  Future<void> _waitForLoad(Completer<void> loadCompleter) async {
    try {
      await loadCompleter.future.timeout(_originLoadTimeout);
    } on TimeoutException {
      _log('startup WebView load timeout, continue', level: 'warning');
    }
  }

  Future<String?> _readPreloadedSnapshot(
    InAppWebViewController controller,
  ) async {
    final deadline = DateTime.now().add(_domSnapshotTimeout);
    while (DateTime.now().isBefore(deadline)) {
      try {
        final raw = await controller.evaluateJavascript(
          source: 'window.__rawPreloaded || null',
        );
        final html = raw?.toString();
        if (html != null && html.isNotEmpty && html != 'null') {
          return html;
        }
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 250));
    }
    return null;
  }

  Future<void> _syncCookiesFromController(
    InAppWebViewController controller,
  ) async {
    await BoundarySyncService.instance.syncFromWebView(
      currentUrl: AppConstants.baseUrl,
      controller: controller,
      cookieNames: null,
      allowLowConfidenceSessionCookies: true,
      trusted: true,
    );
  }

  Future<bool> _isNativePreloadTrusted() async {
    if (!_jar.isInitialized) {
      await _jar.initialize();
    }
    final clearance = await _jar.getCanonicalCookie('cf_clearance');
    if (clearance == null || clearance.value.isEmpty) {
      _log('native trust check: untrusted, no cf_clearance');
      return false;
    }
    if (!CookieJarService.matchesAppHost(clearance.domain)) {
      _log(
        'native trust check: untrusted, domain=${clearance.domain}',
        level: 'warning',
      );
      return false;
    }
    final expiresAt = clearance.expiresAt?.toLocal();
    if (expiresAt == null) {
      _log('native trust check: trusted, no expires');
      return true;
    }
    final ttl = expiresAt.difference(DateTime.now());
    final trusted = ttl >= _trustedClearanceMinTtl;
    _log(
      'native trust check: trusted=$trusted ttl=${ttl.inSeconds}s expires=${expiresAt.toIso8601String()}',
    );
    return trusted;
  }

  void _startClearanceRefreshIfLoggedIn() {
    if (_preload.currentUserSync != null) {
      startClearanceRefresh(reason: 'preload_logged_in');
    } else {
      _log('skip cf_clearance refresh: not logged in');
    }
  }

  void _log(String message, {String level = 'info'}) {
    CfChallengeLogger.log('[BrowserTrust] $message', level: level);
  }

  UnmodifiableListView<UserScript> _startupPreloadScripts() {
    return UnmodifiableListView([
      ...WebViewSettings.compatPolyfillScripts,
      UserScript(
        source: _preloadedSnapshotScript,
        injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
        forMainFrameOnly: true,
      ),
    ]);
  }

  Future<void> _writeStartupShell(InAppWebViewController controller) async {
    final html = jsonEncode(_startupShellHtml);
    await controller.evaluateJavascript(
      source:
          '''
document.open();
document.write($html);
document.close();
''',
    );
  }

  String get _windowsBootstrapUrl => '${AppConstants.baseUrl}/robots.txt';

  String get _startupShellHtml =>
      '<!DOCTYPE html><html><head><meta charset="utf-8"></head>'
      '<body></body></html>';

  String get _preloadedSnapshotScript => '''
(function() {
  if (window.__fluxdoPreloadedSnapshotInstalled) return;
  window.__fluxdoPreloadedSnapshotInstalled = true;

  function capture() {
    var el = document.querySelector('[data-preloaded]');
    if (!el) return false;
    var parts = [el.outerHTML];
    document.querySelectorAll('meta[name]').forEach(function(m) {
      parts.push(m.outerHTML);
    });
    var setup = document.getElementById('data-discourse-setup');
    if (setup) parts.push(setup.outerHTML);
    window.__rawPreloaded = parts.join('\\n');
    return true;
  }

  if (capture()) return;
  var observer = new MutationObserver(function() {
    if (capture()) observer.disconnect();
  });
  function observe() {
    var root = document.documentElement || document;
    observer.observe(root, { childList: true, subtree: true });
    capture();
  }
  if (document.documentElement) {
    observe();
  } else {
    document.addEventListener('DOMContentLoaded', observe, { once: true });
  }
})();
''';
}
