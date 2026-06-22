import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;

import '../utils/url_helper.dart';
import '../widgets/content/discourse_html_content/chunked/html_chunk.dart';
import '../widgets/content/discourse_html_content/chunked/html_chunker.dart';
import '../widgets/content/discourse_html_content/image_utils.dart';

/// 单份 HTML 的所有派生数据。
///
/// 同一 cooked HTML 在帖子渲染路径上至少需要 chunks(分块渲染)
/// 与 galleryInfo(画廊匹配)两份派生数据。原本两者各自调用
/// `html_parser.parseFragment(html)`,在长帖子 mount 时会成为
/// UI 主线程的同步阻塞热点。
///
/// 这里把两份派生合并:isolate 内一次 parseFragment,同时算出
/// chunks 与 gallery 的原始字段;主 isolate 拿到结果后再做需要
/// 当前运行时配置(CDN/baseUri)的 URL 解析,构造 GalleryInfo。
class ParsedHtml {
  final String html;
  final List<HtmlChunk> chunks;
  final _GalleryRaw _galleryRaw;
  GalleryInfo? _galleryInfo;

  ParsedHtml._({
    required this.html,
    required this.chunks,
    required _GalleryRaw galleryRaw,
  }) : _galleryRaw = galleryRaw;

  /// 懒构造 GalleryInfo:需要 [UrlHelper] 当前运行时配置,
  /// 必须在主 isolate 调用。同一 ParsedHtml 实例只构造一次。
  GalleryInfo get galleryInfo =>
      _galleryInfo ??= _buildGalleryInfo(_galleryRaw);
}

/// HTML 解析与缓存服务。
///
/// - 短 html(< 2KB)直接同步解析,避开 isolate 调度成本
/// - 长 html 进 isolate 解析,主 isolate 不被 parseFragment 阻塞
/// - 同一 html 的并发 parse 请求共享同一个 Future,避免重复解析
/// - LRU 缓存解析结果,命中时同步返回
class HtmlParseService {
  HtmlParseService._();

  static final HtmlParseService _instance = HtmlParseService._();
  static HtmlParseService get instance => _instance;

  /// 短 html 的同步解析阈值(byte 长度)。
  /// 小于此值时同步解,isolate 调度本身的成本会超过解析成本。
  static const int _syncThreshold = 2000;

  /// LRU 缓存上限。
  ///
  /// 一个详情页常态可见 20-50 个 post,加上历史滚动经过的 post,
  /// 200 条够容纳一次浏览会话不被频繁淘汰。
  static const int _maxCacheSize = 200;

  final LinkedHashMap<(int, int), ParsedHtml> _cache =
      LinkedHashMap<(int, int), ParsedHtml>();
  final Map<(int, int), Future<ParsedHtml>> _pending =
      <(int, int), Future<ParsedHtml>>{};

  /// 同步返回缓存的解析结果;未命中返回 null。
  ///
  /// 调用方可据此决定是否需要 fallback(显示 loading + 触发异步 parse),
  /// 或对短 html 走 [parseSync] 直接同步出结果。
  ParsedHtml? getCached(String html) {
    final key = _keyOf(html);
    final cached = _cache[key];
    if (cached != null) {
      // LRU: 移到末尾
      _cache.remove(key);
      _cache[key] = cached;
    }
    return cached;
  }

  /// 同步解析。命中缓存或 html 较短时使用。
  ///
  /// 注意:长 html 在主 isolate 解析会阻塞 UI,优先用 [parse]。
  /// 仅在确实无法异步(如同步的 build 路径)或 html 短时调用此方法。
  ParsedHtml parseSync(String html) {
    final cached = getCached(html);
    if (cached != null) return cached;

    final parsed = _doParse(html);
    _put(_keyOf(html), parsed);
    return parsed;
  }

  /// 异步解析。命中缓存立即返回 already-completed Future。
  ///
  /// 同一 html 的并发 parse 共享同一个 Future,避免重复 isolate 调度。
  Future<ParsedHtml> parse(String html) {
    final cached = getCached(html);
    if (cached != null) return Future.value(cached);

    final key = _keyOf(html);
    final pending = _pending[key];
    if (pending != null) return pending;

    final future = _parseAsync(html, key);
    _pending[key] = future;
    return future;
  }

  /// 预加载:fire-and-forget 异步解析。
  ///
  /// 短 html 同步解(基本零成本);长 html 进 isolate 解析,
  /// 帖子 widget mount 时 [getCached] 即可同步命中。
  void preload(String html) {
    if (html.isEmpty) return;
    final key = _keyOf(html);
    if (_cache.containsKey(key) || _pending.containsKey(key)) return;

    if (html.length < _syncThreshold) {
      parseSync(html);
      return;
    }

    // ignore: discarded_futures
    parse(html);
  }

  /// 批量预加载。
  void preloadAll(Iterable<String> htmls) {
    for (final html in htmls) {
      preload(html);
    }
  }

  /// 清空缓存(测试或主动释放使用)。
  @visibleForTesting
  void clear() {
    _cache.clear();
    _pending.clear();
  }

  Future<ParsedHtml> _parseAsync(String html, (int, int) key) async {
    try {
      // 短 html 不走 isolate,直接同步以避免调度开销。
      if (html.length < _syncThreshold) {
        final parsed = _doParse(html);
        _put(key, parsed);
        return parsed;
      }

      final raw = await compute(_parseInIsolate, html);
      final parsed = ParsedHtml._(
        html: html,
        chunks: raw.chunks,
        galleryRaw: raw.galleryRaw,
      );
      _put(key, parsed);
      return parsed;
    } catch (e, st) {
      // isolate 失败时同步兜底:绝不让业务流程因解析失败卡住。
      debugPrint('[HtmlParseService] isolate parse failed: $e\n$st');
      final parsed = _doParse(html);
      _put(key, parsed);
      return parsed;
    } finally {
      _pending.remove(key);
    }
  }

  void _put((int, int) key, ParsedHtml value) {
    while (_cache.length >= _maxCacheSize) {
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  static (int, int) _keyOf(String html) => (html.hashCode, html.length);

  static ParsedHtml _doParse(String html) {
    final raw = _parseInIsolate(html);
    return ParsedHtml._(
      html: html,
      chunks: raw.chunks,
      galleryRaw: raw.galleryRaw,
    );
  }
}

/// isolate 内一次 parseFragment 同时产出 chunks 与 gallery 原始字段。
///
/// 必须是纯函数:不能访问任何主 isolate 单例(UrlHelper 的 CDN/baseUri
/// 配置在主 isolate 里,所以 URL 解析延迟到主 isolate 完成)。
_ParseResult _parseInIsolate(String html) {
  if (html.isEmpty) {
    return const _ParseResult(
      chunks: <HtmlChunk>[],
      galleryRaw: _GalleryRaw(entries: <_GalleryEntry>[]),
    );
  }

  // 一次 parseFragment 给两个派生用,避免重复 DOM 解析
  final document = html_parser.parseFragment(html);

  final chunks = HtmlChunker.chunkDocument(html: html, document: document);
  final galleryRaw = _extractGalleryRaw(document);

  return _ParseResult(chunks: chunks, galleryRaw: galleryRaw);
}

/// 从已解析 DOM 中提取画廊原始字段(href/title/imgSrc/spoiler 标记)。
/// URL 解析延迟到主 isolate 完成。
_GalleryRaw _extractGalleryRaw(dom.DocumentFragment document) {
  final entries = <_GalleryEntry>[];
  final lightboxLinks = document.querySelectorAll('a.lightbox');

  for (final anchor in lightboxLinks) {
    bool inSpoiler = false;
    var parent = anchor.parent;
    while (parent != null) {
      if (parent.classes.contains('spoiler') ||
          parent.classes.contains('spoiled')) {
        inSpoiler = true;
        break;
      }
      parent = parent.parent;
    }

    final href = anchor.attributes['href'];
    if (href == null || href.isEmpty) continue;

    final title = anchor.attributes['title'];
    final img = anchor.querySelector('img');
    final imgSrc = img?.attributes['src'];

    entries.add(_GalleryEntry(
      href: href,
      title: title,
      imgSrc: imgSrc,
      inSpoiler: inSpoiler,
    ));
  }

  return _GalleryRaw(entries: entries);
}

/// 主 isolate 内:基于原始字段 + 当前运行时 URL 配置构造 GalleryInfo。
GalleryInfo _buildGalleryInfo(_GalleryRaw raw) {
  if (raw.entries.isEmpty) {
    return GalleryInfo.fromImages(const <String>[]);
  }

  final originalUrls = <String>[];
  final filenames = <String?>[];
  final thumbnailToIndex = <String, int>{};
  final spoilerImageUrls = <String>{};

  for (final entry in raw.entries) {
    final originalUrl = UrlHelper.resolveUrlWithCdn(entry.href);
    final index = originalUrls.length;
    originalUrls.add(originalUrl);
    filenames.add(entry.title);

    if (entry.inSpoiler) {
      spoilerImageUrls.add(originalUrl);
    }

    final imgSrc = entry.imgSrc;
    if (imgSrc != null) {
      final thumbnailUrl = UrlHelper.resolveUrlWithCdn(imgSrc);
      thumbnailToIndex[thumbnailUrl] = index;
      final thumbOriginal = DiscourseImageUtils.getOriginalUrl(thumbnailUrl);
      if (thumbOriginal != thumbnailUrl) {
        thumbnailToIndex[thumbOriginal] = index;
      }
    }
    thumbnailToIndex[originalUrl] = index;
  }

  return GalleryInfo.fromParsedEntries(
    originalUrls: originalUrls,
    thumbnailToIndex: thumbnailToIndex,
    filenames: filenames,
    spoilerImageUrls: spoilerImageUrls,
  );
}

/// isolate 输出。
class _ParseResult {
  final List<HtmlChunk> chunks;
  final _GalleryRaw galleryRaw;

  const _ParseResult({required this.chunks, required this.galleryRaw});
}

/// 画廊原始字段(URL 未解析)。
class _GalleryRaw {
  final List<_GalleryEntry> entries;
  const _GalleryRaw({required this.entries});
}

class _GalleryEntry {
  final String href;
  final String? title;
  final String? imgSrc;
  final bool inSpoiler;

  const _GalleryEntry({
    required this.href,
    required this.title,
    required this.imgSrc,
    required this.inSpoiler,
  });
}
