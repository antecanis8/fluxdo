import 'dart:io' as io;

import 'package:cookie_jar/cookie_jar.dart' as base;

import 'canonical_cookie.dart';
import 'cdp_cookie_parser.dart';
import 'file_cookie_store.dart';
import 'set_cookie_parser.dart';

class EnhancedPersistCookieJar implements base.CookieJar {
  EnhancedPersistCookieJar({required FileCookieStore store, this.ignoreExpires = false}) : _store = store;

  final FileCookieStore _store;

  @override
  final bool ignoreExpires;

  List<CanonicalCookie>? _cache;

  Future<List<CanonicalCookie>> readAllCookies() async => List.unmodifiable(await _readAll());

  Future<List<CanonicalCookie>> _readAll() async {
    final cached = _cache;
    if (cached != null) return cached;
    final loaded = await _store.readAll();
    _cache = loaded;
    return loaded;
  }

  Future<void> _writeAll(List<CanonicalCookie> cookies) async {
    _cache = cookies;
    // 只持久化非过期 + 非 session 的 cookie，session cookie 仅保留在内存缓存中
    final toPersist = cookies.where(_shouldPersist).toList(growable: false);
    await _store.writeAll(toPersist);
  }

  /// 保存一组 CanonicalCookie，按 storageKey 去重。
  ///
  /// [trusted] 标记写入来源是否权威：
  /// - true（服务器 Set-Cookie / CF challenge 确认值）：值变化时升 version 盖过
  ///   泛读旧值；值未变则保持。
  /// - false（WebView 泛读，可能读到旧残留）：仅当比已有值更新鲜（[isFresherThan]）
  ///   时才覆盖，避免旧值盖掉权威新值。
  Future<void> saveCanonicalCookies(
    Uri uri,
    List<CanonicalCookie> cookies, {
    bool trusted = false,
  }) async {
    if (cookies.isEmpty) return;
    final all = [...await _readAll()];
    for (final cookie in cookies) {
      var resolved = cookie.copyWith(
        domain: cookie.domain ?? uri.host.toLowerCase(),
        path: cookie.path.isEmpty ? '/' : cookie.path,
        lastAccessTime: DateTime.now().toUtc(),
      );
      final idx =
          all.indexWhere((existing) => existing.storageKey == resolved.storageKey);
      if (idx >= 0) {
        final existing = all[idx];
        if (trusted) {
          resolved = resolved.copyWith(
            version: existing.value == resolved.value
                ? existing.version
                : existing.version + 1,
          );
        } else if (!resolved.isFresherThan(existing)) {
          // 不可信且不更新鲜：保留已有的权威值，跳过本次写入。
          continue;
        }
        all.removeAt(idx);
      }
      if (ignoreExpires || !resolved.isExpired) {
        all.add(resolved);
      }
    }
    await _writeAll(all);
  }

  Future<void> saveFromSetCookieHeaders(
    Uri uri,
    List<String> headers, {
    bool trusted = false,
  }) async {
    final cookies = headers.map((e) => SetCookieParser.parse(e, uri: uri)).toList();
    await saveCanonicalCookies(uri, cookies, trusted: trusted);
  }

  Future<void> saveFromCdpCookies(
    Uri uri,
    List<Map<String, dynamic>> rawCookies, {
    bool trusted = false,
  }) async {
    final cookies = rawCookies
        .map((e) => CdpCookieParser.parse(e, originUrl: uri.toString()))
        .whereType<CanonicalCookie>()
        .toList();
    await saveCanonicalCookies(uri, cookies, trusted: trusted);
  }

  Future<List<CanonicalCookie>> loadCanonicalForRequest(Uri uri) async {
    final all = await _readAll();
    final filtered = all.where((cookie) => _matches(uri, cookie) && (ignoreExpires || !cookie.isExpired)).toList()
      ..sort((a, b) {
        final pathCompare = b.path.length.compareTo(a.path.length);
        if (pathCompare != 0) return pathCompare;

        final domainCompare =
            (b.normalizedDomain?.length ?? 0).compareTo(a.normalizedDomain?.length ?? 0);
        if (domainCompare != 0) return domainCompare;

        if (a.hostOnly != b.hostOnly) {
          return a.hostOnly ? -1 : 1;
        }

        return a.creationTime.compareTo(b.creationTime);
      });
    return filtered;
  }

  @override
  Future<List<io.Cookie>> loadForRequest(Uri uri) async {
    final cookies = await loadCanonicalForRequest(uri);
    return cookies.map((e) => e.toIoCookie()).toList(growable: false);
  }

  @override
  Future<void> saveFromResponse(Uri uri, List<io.Cookie> cookies) async {
    final canonical = cookies.map((e) => SetCookieParser.fromIoCookie(e, uri: uri)).toList();
    await saveCanonicalCookies(uri, canonical);
  }

  /// 与 [saveFromResponse] 相同，但可标记 [trusted]（CF challenge 等确认的权威
  /// 写入），升 version 盖过 WebView 泛读到的旧值。
  Future<void> saveFromResponseTrusted(
    Uri uri,
    List<io.Cookie> cookies, {
    bool trusted = false,
  }) async {
    final canonical =
        cookies.map((e) => SetCookieParser.fromIoCookie(e, uri: uri)).toList();
    await saveCanonicalCookies(uri, canonical, trusted: trusted);
  }

  @override
  Future<void> delete(Uri uri, [bool withDomainSharedCookie = false]) async {
    final all = [...await _readAll()];
    all.removeWhere((cookie) {
      final matchDomain = cookie.normalizedDomain ?? _originHost(cookie);
      if (cookie.hostOnly) return matchDomain == uri.host.toLowerCase();
      if (!withDomainSharedCookie) return false;
      return _domainMatches(uri.host, matchDomain);
    });
    await _writeAll(all);
  }

  @override
  Future<void> deleteAll() async {
    _cache = const [];
    await _store.deleteAll();
  }

  /// RFC 6265 §5.3: 有 expires/max-age 的是持久化 cookie，没有的是 session cookie
  /// session cookie 只保留在内存缓存中，不写入文件（与浏览器行为一致）
  bool _shouldPersist(CanonicalCookie cookie) {
    if (ignoreExpires) return true;
    if (cookie.isExpired) return false;
    return cookie.expiresAt != null || cookie.maxAge != null;
  }

  bool _matches(Uri uri, CanonicalCookie cookie) {
    final matchDomain = cookie.normalizedDomain ?? _originHost(cookie);
    if (!_domainMatches(uri.host, matchDomain, hostOnly: cookie.hostOnly)) {
      return false;
    }
    if (!_pathMatches(uri.path.isEmpty ? '/' : uri.path, cookie.path)) {
      return false;
    }
    if (cookie.secure && uri.scheme != 'https') return false;
    return true;
  }

  String? _originHost(CanonicalCookie cookie) {
    final originHost = Uri.tryParse(cookie.originUrl ?? '')?.host.trim();
    if (originHost == null || originHost.isEmpty) return null;
    return originHost.toLowerCase();
  }

  bool _domainMatches(String host, String? cookieDomain, {bool hostOnly = false}) {
    final normalizedHost = host.toLowerCase();
    if (cookieDomain == null || cookieDomain.isEmpty) return false;
    if (hostOnly) return normalizedHost == cookieDomain;
    return normalizedHost == cookieDomain ||
        normalizedHost.endsWith('.$cookieDomain');
  }

  bool _pathMatches(String requestPath, String cookiePath) {
    final normalizedRequest = requestPath.isEmpty ? '/' : requestPath;
    final normalizedCookie = cookiePath.isEmpty ? '/' : cookiePath;
    if (normalizedCookie == '/' || normalizedRequest == normalizedCookie) return true;
    if (!normalizedRequest.startsWith(normalizedCookie)) return false;
    if (normalizedCookie.endsWith('/')) return true;
    return normalizedRequest.length > normalizedCookie.length && normalizedRequest[normalizedCookie.length] == '/';
  }
}
