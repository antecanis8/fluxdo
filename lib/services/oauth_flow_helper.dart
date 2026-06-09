import 'dart:math';

/// linux.do 系 OAuth 链路 (cdk / credit / 未来其他) 共用的拟人化工具。
///
/// 当前只做一件事: 给链路里相邻的请求之间插入带抖动的随机延迟,
/// 避免被反爬识别为固定 400ms gap 的脚本。
///
/// 历史教训:
/// 曾经尝试过给 OAuth 链路加 Sec-Fetch-* / Accept / Referer 等"伪装成浏览器"
/// 的请求头, 结果让 connect.linux.do 误识别请求模式, 生成的 OAuth code
/// 与业务方 session 不匹配, callback 报 "CSRF 验证失败"。
/// 实测可工作的 curl 例只带 user-agent + content-type + cookie + accept-encoding,
/// 服务端依赖的是 cookie 关联, 不需要额外头来"看起来像浏览器"。
class OAuthFlowHelper {
  OAuthFlowHelper._();

  static final Random _random = Random();

  /// 真人级别的随机延迟。
  ///
  /// 真人浏览器跳转 OAuth 同意页时, 上一步到下一步的间隔通常呈现:
  /// - 网络请求自然延迟 (几百毫秒级)
  /// - 用户手指反应 / 渲染时间 (几百毫秒到 1 秒级)
  ///
  /// 固定 400ms 极容易被识别为脚本, 这里改为 [minMs, maxMs] 之间均匀分布。
  static Future<void> humanGap({
    required int minMs,
    required int maxMs,
  }) async {
    assert(minMs > 0 && maxMs >= minMs);
    final delay = minMs + _random.nextInt(maxMs - minMs + 1);
    await Future<void>.delayed(Duration(milliseconds: delay));
  }
}
