import 'dart:async';

import 'package:enhanced_cookie_jar/enhanced_cookie_jar.dart';
import 'package:flutter/foundation.dart';

import 'cookie_jar_service.dart';
import 'cookie_logger.dart';
import 'cookie_store_observer.dart';
import 'raw_cookie_writer.dart';
import 'session_cookie_sentinel.dart';

/// WV 启动重灌服务。
///
/// 取代 v0.3.0 的 `RawSetCookieQueue` 持久化队列。
/// 在 WV 即将被使用前，从 jar 重灌所有 critical cookies。
///
/// 设计依据：`docs/cookie-sync-design-v0.4.0.md` §5.2
///
/// 关键不变量：
/// - 任何 WV 使用者在使用 WV 前必须 await [prime]
/// - prime 是幂等的（[isPrimed] 为 true 时立即返回）
/// - 同一 url 并发调用 [prime] 会去重（共享同一个 Future）
class WebViewCookiePriming {
  WebViewCookiePriming._();
  static final WebViewCookiePriming instance = WebViewCookiePriming._();

  // ---------------------------------------------------------------------------
  // 可注入依赖
  // ---------------------------------------------------------------------------

  RawCookieWriter _writer = RawCookieWriter.instance;
  CookieJarService _jar = CookieJarService();
  SessionCookieSentinel _sentinel = SessionCookieSentinel.instance;

  /// 仅测试用：替换内部依赖。
  @visibleForTesting
  void replaceDependenciesForTest({
    RawCookieWriter? writer,
    CookieJarService? jar,
    SessionCookieSentinel? sentinel,
  }) {
    if (writer != null) _writer = writer;
    if (jar != null) _jar = jar;
    if (sentinel != null) _sentinel = sentinel;
  }

  // ---------------------------------------------------------------------------
  // 内部状态
  // ---------------------------------------------------------------------------

  bool _isPrimed = false;

  /// 当前进行中的 prime Future（用于同 url 并发去重）。
  Future<void>? _primingFuture;
  String? _primingUrl;

  // ---------------------------------------------------------------------------
  // 公开 API
  // ---------------------------------------------------------------------------

  /// 当前 WV 是否已就绪。
  bool get isPrimed => _isPrimed;

  /// 确保 WV 中的 critical cookies 与 jar 同步。
  ///
  /// 详见 §5.2 接口契约。
  Future<void> prime(String url) async {
    if (_isPrimed) return;

    // 同 url 并发去重
    final existing = _primingFuture;
    if (existing != null && _primingUrl == url) {
      return existing;
    }

    final future = _primeInternal(url);
    _primingFuture = future;
    _primingUrl = url;

    try {
      await future;
    } finally {
      if (identical(_primingFuture, future)) {
        _primingFuture = null;
        _primingUrl = null;
      }
    }
  }

  /// 标记 WV 状态为"未就绪"。
  void invalidate() {
    _isPrimed = false;
  }

  /// 等待当前正在进行的 priming 完成（如有）。
  Future<void> awaitReady() async {
    final future = _primingFuture;
    if (future != null) await future;
  }

  /// 仅测试用：重置内部状态。
  @visibleForTesting
  void resetForTest() {
    _isPrimed = false;
    _primingFuture = null;
    _primingUrl = null;
  }

  // ---------------------------------------------------------------------------
  // 内部实现
  // ---------------------------------------------------------------------------

  Future<void> _primeInternal(String url) async {
    final stopwatch = Stopwatch()..start();
    CookieLogger.priming(event: 'invoked', url: url, isPrimed: _isPrimed);
    // 注册 url 到 observer, 后续 WV 外部 cookie 变化时会对该 url sweep
    CookieStoreObserver.instance.registerUrl(url);
    try {
      // 1. 确保 jar 已初始化（兜底，调用方应该已经初始化）
      if (!_jar.isInitialized) {
        await _jar.initialize();
      }

      // 2. 从 jar 读"当前 url 适用的所有 cookie" (RFC 6265 domain matching)
      // 不再按 criticalCookieNames 过滤 — 该列表 hard-code 维护不可持续
      // (每次发现新业务 cookie 如 LDC/CDK 没同步就要追加, 永远列不全)。
      // jar 是 source of truth, loadCanonicalCookiesForRequest 已经按
      // RFC 6265 domain matching 选出"该 url 适用的全部 cookie", 直接
      // 全量同步到 WV 即可。
      final uri = Uri.parse(url);
      final jarCookies = await _jar.loadCanonicalCookiesForRequest(uri);

      // 3. per-cookie 严格 "先 nuke 后写" 流程, 保证写入后 each name 恰好 1 条:
      //
      // 旧流程 "先全部 setRawCookie 后 sweepAll 兜底" 对 Apple 平台行为
      // 不够鲁棒 — 实测 macOS 上同 (name, domain, path) 写入未必覆盖
      // (可能 sourceScheme / sourcePort / SameSite 等隐藏字段差异导致 4-tuple
      // 不全等), 残留多条 variant。
      //
      // 新流程 per-cookie:
      //   a) sweep(intent: delete) — 暴力删除当前 url 域下该 name 所有 variant
      //   b) setRawCookie(jar canonical) — 写入 1 条规范形式
      //   c) verify count — 不等于 1 时 dump 所有 variant 字段到日志
      var injected = 0;
      var attempted = 0;
      var skippedEmpty = 0;
      var skippedExpired = 0;
      final mismatched = <String, int>{};
      for (final cookie in jarCookies) {
        if (cookie.value.isEmpty) {
          skippedEmpty++;
          continue;
        }
        if (_isExpired(cookie)) {
          skippedExpired++;
          continue;
        }
        attempted++;

        // a) nuke 同 name 所有 variant
        await _sentinel.sweep(url, cookie.name, intent: SweepIntent.delete);

        // b) 写入 jar canonical (含 hostOnly/Domain/SameSite)
        final ok = await _writer.setRawCookie(url, cookie.toSetCookieHeader());
        if (ok) injected++;

        // c) verify 是否恰好 1 条
        final postCount = await _writer.countCookiesByName(url, cookie.name);
        final isOk = postCount == 1;
        if (!isOk) mismatched[cookie.name] = postCount;
        debugPrint(
          '[Priming] ${cookie.name} '
          '(hostOnly=${cookie.hostOnly}, domain=${cookie.domain}, '
          'len=${cookie.value.length}) write=$ok postCount=$postCount '
          '${isOk ? "✓" : "⚠️ expected=1"}',
        );

        // c.1) 若 count != 1, dump WV 中该 name 所有 variant 完整字段
        if (!isOk) {
          final all = await _writer.getAllCookieInfos(url);
          final variants = all.where((c) => c.name == cookie.name).toList();
          debugPrint(
            '[Priming] ⚠️ ${cookie.name} variants in WV ($postCount):',
          );
          for (var i = 0; i < variants.length; i++) {
            debugPrint('  [$i] ${variants[i]}');
          }
        }
      }

      // 4. verify pass (信息汇总, 不影响 _isPrimed)
      var verified = 0;
      final missingNames = <String>[];
      for (final cookie in jarCookies) {
        if (cookie.value.isEmpty || _isExpired(cookie)) continue;
        final count = await _writer.countCookiesByName(url, cookie.name);
        if (count >= 1) {
          verified++;
        } else {
          missingNames.add(cookie.name);
        }
      }

      _isPrimed = true;
      final hasMismatch = mismatched.isNotEmpty || missingNames.isNotEmpty;
      debugPrint(
        '[Priming] WV primed for $url: '
        'injected=$injected/$attempted, verified=$verified/$attempted '
        '(jarTotal=${jarCookies.length}, '
        'skippedEmpty=$skippedEmpty, skippedExpired=$skippedExpired)'
        '${hasMismatch ? ", MISSING=$missingNames, COUNT_MISMATCH=$mismatched" : ""}',
      );
      CookieLogger.priming(
        event: hasMismatch ? 'failed' : 'completed',
        url: url,
        cookiesInjected: injected,
        durationMs: stopwatch.elapsedMilliseconds,
        reason: hasMismatch
            ? 'missing=$missingNames count_mismatch=$mismatched '
                'verified=$verified/$attempted'
            : null,
      );
    } catch (e, s) {
      debugPrint('[Priming] prime $url failed: $e\n$s');
      _isPrimed = false;
      CookieLogger.priming(
        event: 'failed',
        url: url,
        reason: '$e',
        durationMs: stopwatch.elapsedMilliseconds,
      );
      throw WebViewPrimingException('prime failed for $url: $e', e);
    }
  }

  bool _isExpired(CanonicalCookie cookie) {
    final expiresAt = cookie.expiresAt;
    return expiresAt != null && expiresAt.isBefore(DateTime.now());
  }
}

/// WV priming 失败时抛出。
class WebViewPrimingException implements Exception {
  WebViewPrimingException(this.message, [this.cause]);
  final String message;
  final Object? cause;

  @override
  String toString() => 'WebViewPrimingException: $message'
      '${cause != null ? ' (caused by $cause)' : ''}';
}
