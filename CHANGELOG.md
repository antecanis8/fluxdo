# Changelog

所有版本的变更记录。beta / rc 版本提交在 stable 发版时会折叠并入对应 stable 版本。

## [0.2.21] - 2026-06-23


### 🌟 新功能

- 全局图标统一为 Material Symbols Rounded + 支持自绘 by @Lingyan000

- 加载更多统一使用自定义 LoadingSpinner by @Lingyan000

- 支持查看 DNS 缓存记录 by @Lingyan000

- 支持 Premium 回复最小长度 by @Lingyan000

- 统一底部弹框为 AppSheetScaffold(贴边/卡片双形态) by @Lingyan000


### 🐛 修复

- 修复网络适配器与 Cookie 同步稳定性 by @Lingyan000

- 修复用户卡片更多菜单层级 by @Lingyan000

- 修复 CF 静默验证页布局异常 by @Lingyan000


### ⚡ 性能

- 合并 HTML 解析路径,长帖渲染走 isolate 预热 by @Lingyan000

- 隔离自驱动重绘 + 头像 SVG 探测短路 by @Lingyan000

- 优化后台 WebView 资源占用 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.20...v0.2.21

## [0.2.20] - 2026-06-19


### 🌟 新功能

- 改进移动端表情长按面板体验 by @Lingyan000

- 弹出菜单顶部快捷按钮条 + 子面板展开动画 by @Lingyan000

- 帖子编辑历史 + 修复 callout 跨标签贪婪正则 by @Lingyan000

- 优化 CF 信任刷新与 Cookie 同步 by @Lingyan000

- 表情选择器改造为手势驱动的连贯交互 by @Lingyan000

- 长按进度条菜单加入衍生 / 收回动画 by @Lingyan000

- 支持轻量 WebView 会话 cookie bootstrap by @Lingyan000


### 🐛 修复

- 识别 CHIPS 分区 cf_clearance，终结 sweep 空转 by @Lingyan000

- 修复页面刷新后通知徽章回退到初值 by @Lingyan000

- 修复通知图标 build 阶段 setState 报错 by @Lingyan000

- 修复 mac 进度指示器卡死 + 表情选择器 tap 误触发动画 by @Lingyan000

- 修复启动页动画卡顿 by @Lingyan000

- 修复话题详情 listener 触发 inactive ancestor lookup by @Lingyan000

- 修复 Cloudflare 验证完成后的 404 闪烁 by @Lingyan000

- 修复登录态 probe 的 _t 回退逻辑 by @Lingyan000


### ⚡ 性能

- CDK/LDC 余额改为进入页面才请求，不在冷启动预取 by @Lingyan000


### ♻️ 重构

- WebView session bootstrap CF 失败接入 BrowserTrustCoordinator by @Lingyan000

- 网络引擎设置重做为预设单选 + VPN 开关意图/生效分离 by @Lingyan000


### 🎨 样式

- 收尾表情选择器手势细节 by @Lingyan000


### 🔧 其他

- 🔒 优化浏览器信任与 Cookie 同步 by @Lingyan000

- ⬆️ lock 更新 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.19...v0.2.20

## [0.2.19] - 2026-06-16


### 🐛 修复

- 修复 LDC 余额趋势符号显示 by @Lingyan000

- 修复实时 Boost 权限误判 by @Lingyan000

- Harden WebView session cookie sync by @Lingyan000

- Fix: 修复 Windows 登录验证和加载卡住 by @Lingyan000

- Fix: 兼容伪装成 PNG 的 SVG 头像 by @Lingyan000


### ♻️ 重构

- 抽象分页加载状态 by @Lingyan000


### 🔧 其他

- :bug: fix: 收敛 Discourse 登录态与上报逻辑 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.18...v0.2.19

## [0.2.18] - 2026-06-13


### 🌟 新功能

- 登录页调整 by @Lingyan000

- 增加本地草稿兜底缓存 by @Lingyan000

- 优化启动页 UI 并统一氛围页角落按钮 by @Lingyan000

- 点击通知跳转后不再主动关闭通知面板 by @Lingyan000

- 统一登录文案为 LINUX.DO by @Lingyan000

- 调整主题预览弹窗自适应高度 by @Lingyan000

- 支持话题摘要流式更新 by @Lingyan000

- Cdk 卡片跳转地址更改 by @Lingyan000

- 头像点击改弹用户卡片:基于话题私信/关注/静音忽略 by @Lingyan000

- 统一错误页 UI:补网络设置入口 + 收敛 9 个页面到 ErrorView by @Lingyan000

- MessageBus 对齐官方 v4 协议：消除 iOS 100ms 重连风暴 by @Lingyan000

- CF 验证期间冻结业务请求：模拟网页 CF 403 直接停滞 by @Lingyan000

- 编辑器工具栏极简化：网格工具面板 + 可自定义外显工具 by @Lingyan000

- Boost 弹幕化 + 阅读设置开关 by @Lingyan000

- 移除「连通性检查」,「测试模型」按钮挪到 AppBar by @Lingyan000

- 支持 Boost 举报功能 (#279) ([#279](https://github.com/lingyan000/fluxdo/pull/279)) by @miniworldcnmm

- 登录 dialog CSRF 403 自动重过 CF 验证 by @Lingyan000


### 🐛 修复

- 修复私信草稿 key 恢复和收件人同步 by @Lingyan000

- 用户卡片背景图露边:背景图移入 child 与渐变蒙版同层,避免 border 内缩导致边缘未被遮罩覆盖 by @Lingyan000

- Cookie 读写加固:显式删除被新鲜度仲裁拦截 + 并发写竞态 + 每响应全量写盘 by @Lingyan000

- Cf_clearance 新旧变体打架致 cdk 反复 403:jar 版本化防旧盖新 + native 精确删 by @Lingyan000

- 关键词过滤场景下话题列表死循环 loadMore 导致下拉刷新卡 loading by @Lingyan000

- Profile 页下拉刷新 LDC/CDK 卡片无 spinner 也不刷数据 by @Lingyan000

- LDC 今日收益偶发 +0:score 与 LDC 数据解耦,展示层组合 by @Lingyan000

- 多图发帖偶发永久裂图:lookup-urls 失败不再缓存 null + 批量合并加 429 重试 by @Lingyan000

- 草稿偶发 409:对齐 Discourse 前端的 sequence 三板斧 by @Lingyan000

- 复制日志炸 TransactionTooLargeException:>1MB 回退分享 by @Lingyan000

- CF 速率限制 challenge 返 429:拦截器只看 403 漏判 by @Lingyan000

- 修登录后 ProfilePage 卡 loading：refresher 改用 ProviderContainer by @Lingyan000

- 修 rhttp 写死 30s timeout 截断长请求：违反 HttpClientAdapter 契约 by @Lingyan000

- 修 macOS CF 验证死循环：补齐 WKWebView 半截 UA by @Lingyan000

- 修 AI 对话表格 1px 溢出：totalWidth 算错列间分隔线 by @Lingyan000

- 修 footer 操作栏溢出：表情叠叠乐 + 弹幕开关挪到 header by @Lingyan000

- 修 Anthropic 多个真实失败 + baseUrl 自动补 /v1 + 诊断增强 by @Lingyan000

- 修预见式返回手势进行中锁屏致 UI 卡死 by @Lingyan000


### ⚡ 性能

- DoH 提速:接入 h2 MITM 开关 + 升级 doh_proxy 子模块 by @Lingyan000

- 表情面板滚动卡顿:缓存 panel/页面实例阻断 rebuild 级联 by @Lingyan000

- AVIF 解码:缩略图单帧解码 + 并发 1→4 恢复预热 + 预览流式逐帧 by @Lingyan000

- 图片加载地基:缓存索引 JSON→Hive + 失败 evict 自动重试 + 下载全局限流 by @Lingyan000


### ♻️ 重构

- 日志系统重构:统一入口 + 缓冲落盘轮换 + 日志页重做 by @Lingyan000


### 🔧 其他

- Keep node tools for crashlytics upload by @Lingyan000

- Fix release workflow failures by @Lingyan000

- 👷 TG 发布失败不再静默：CI 报错可重跑 + 回收半截消息，并美化消息模板 by @Lingyan000

- 👷 Android 构建前清理 runner 预装组件,避免磁盘写满导致构建失败 by @Lingyan000

- 👷 macOS CI 改 M1 交叉编 x86_64 + 全 Rust job 加缓存 by @Lingyan000

- 💄 网络并发设置文案太硬核:改大白话 + 档位预设 + 一键重置 by @Lingyan000

- 👷 CI 出 Android 包时分离并上传 Dart symbols 到 Crashlytics by @Lingyan000

- ⬆️ 升若干依赖 + 项目级关 SwiftPM 修 gal macOS 11.0 报错 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.17...v0.2.18

## [0.2.17] - 2026-06-10


### 🌟 新功能

- Hcaptcha create endpoint 可配置 + fallback 列表 by @Lingyan000

- Hcaptcha create endpoint 可配置 + fallback 列表 by @Lingyan000


### 🐛 修复

- ApiKey 改明文存储 + 诊断走应用日志,根治「未收到 AI 回复」 by @Lingyan000

- 修 Android nukeAllVariants 因无 Looper 线程致空操作 by @Lingyan000

- 升 native_animated_image 0.3.1: 修不透明动画 WebP 解码 crash by @Lingyan000

- 修请求调度器按 dio 实例独立窗口, 导致服务端 429 by @Lingyan000

- 修请求调度器按 dio 实例独立窗口, 导致服务端 429 by @Lingyan000

- Release notes 从上个 stable 起算 + Pages 图标路径动态化 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.16...v0.2.17

## [0.2.16] - 2026-06-09


### 🌟 新功能

- 俺也一样: OP 帖底部 ME TOO 表态按钮 (discourse-solved shared_issue) by @Lingyan000

- Notion 同步: 帖子/话题 -> Notion Database (close [#230](https://github.com/lingyan000/fluxdo/issues/230)) by @Lingyan000

- 导出历史: 帖子导出/同步统一可追溯 (PR1/2 → #227) by @Lingyan000

- Native 应用登录页: WebView 内 JS 全流程登录 by @Lingyan000

- 多解决方案支持: 列表化 banner + 兼容 discourse-solved 新分支 by @Lingyan000

- 老 WKWebView 兼容层: core-js polyfill 子工程 + JS 错误回传 by @Lingyan000

- Cookie 引擎 v0.4.0 闭环: 全量同步 + 跨平台 observer + Win/Linux 接通 by @Lingyan000

- 进度悬浮条手势：按压时间反馈 + 长按菜单设置页 by @Lingyan000

- 进度悬浮条手势：左右上滑 + 长按半圆菜单 by @Lingyan000

- CF 盾自动验证开关 by @Lingyan000

- APK 更新支持后台下载 + 通知栏进度 by @Lingyan000

- Release 日志改造：接入 git-cliff + TG 通知重构 by @Lingyan000

- Cookie 引擎 v0.4.0 (#276) ([#276](https://github.com/lingyan000/fluxdo/pull/276)) by @Lingyan000

- : 更新桌面端 App Icon ([#272](https://github.com/lingyan000/fluxdo/pull/272)) by @Silhouette-my

- 字体粗细调整 by @Lingyan000

- CF 验证样式优化 by @Lingyan000

- Flutter 更新到 3.44.0 by @Lingyan000

- 刷新率设置支持 by @Lingyan000

- 优化 CF 盾处理与验证体验 (#266) ([#266](https://github.com/lingyan000/fluxdo/pull/266)) by @Lingyan000

- 添加话题关键词过滤功能，允许用户根据标题关键词筛选话题 (#268) ([#268](https://github.com/lingyan000/fluxdo/pull/268)) by @SuperJeason

- 跨平台我的书签工作区与统一书签编辑体验（clean） (#262) ([#262](https://github.com/lingyan000/fluxdo/pull/262)) by @liucong2013

- AI 提供商排序置顶与模型收藏排序，新增发帖 AI 审核，修复网页端草稿编辑问题 (#261) ([#261](https://github.com/lingyan000/fluxdo/pull/261)) by @miniworldcnmm

- 优化桌面布局与侧边栏导航分组 (#249) ([#249](https://github.com/lingyan000/fluxdo/pull/249)) by @liucong2013

- AI 助手功能优化 by @Lingyan000


### 🐛 修复

- 修 AI 测试模型弹框标题撞状态栏 by @Lingyan000

- 修 _t 被错存为 domain cookie 挂到子域名 by @Lingyan000

- 修 cdk/ldc OAuth callback "CSRF 验证失败" by @Lingyan000

- Cdk/ldc OAuth 链路拟人化, 缓解 429 by @Lingyan000

- 修 iOS 切换应用图标无法切回主图标 by @Lingyan000

- 修 iOS 真机 AI「未收到 AI 回复」+ 跟随网络 Claude 第二次起必挂 by @Lingyan000

- 修日志文件含非法 utf-8 字节时日志页面崩溃打不开 by @Lingyan000

- 修双栏布局下正在输入指示器居中显示 by @Lingyan000

- 修 cdk/ldc OAuth user-info 双发 + 链路无间隔触发 429 by @Lingyan000

- 修 Priming 与 cf_challenge 竞态导致 CF 第一次验证关闭 by @Lingyan000

- 修 CF 验证循环 bug + sameSite 字段全链路保留 by @Lingyan000

- 修复 release notes stable 漏合 beta + TG 双消息缺少关联 by @Lingyan000

- 修复 Priming 同步失败: 去掉 fast path + 加 verify by @Lingyan000

- 修复查看图片隐藏状态栏之后不再显示的问题 by @Lingyan000

- Flutter 升级兼容性修复 by @Lingyan000

- 修复 AI 功能跟随应用网络配置失效的问题 by @Lingyan000

- LDC 功能错误提示优化 by @Lingyan000

- Fix post-login loading handoff (#258) ([#258](https://github.com/lingyan000/fluxdo/pull/258)) by @liucong2013

- 修复 rhttp 引擎开关退出重进自动关闭问题 (#254) ([#254](https://github.com/lingyan000/fluxdo/pull/254)) by @miniworldcnmm


### 🔧 其他

- Revert ":rocket: AVIF 走 Skia 内置 codec 优先 — 跟浏览器同档 path" by @Lingyan000

- :rocket: AVIF 走 Skia 内置 codec 优先 — 跟浏览器同档 path by @Lingyan000

- :zap: Android AVIF 卡 + 关闭面板还卡 — generation cancel + AVIF 并发 1 by @Lingyan000

- :zap: sticker / AVIF 完整方案 (2/2): 后续微优化(解码并发/UI/网络) by @Lingyan000

- :sparkles: sticker / AVIF 完整方案 (1/2): native 集成 + 架构重构 + 主要修复 by @Lingyan000

- 🔥 移除 hCaptcha 无障碍 Cookie 功能 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.15...v0.2.16

## [0.2.15] - 2026-05-09


### 🌟 新功能

- 为「新话题」筛选新增二级子过滤下拉，对齐 Linux.do 网页版行为。 (#243) ([#243](https://github.com/lingyan000/fluxdo/pull/243)) by @miniworldcnmm

- Boost 切换到帖子回复 (#238) ([#238](https://github.com/lingyan000/fluxdo/pull/238)) by @miniworldcnmm

- 新增剪贴板话题链接识别服务 (#237) ([#237](https://github.com/lingyan000/fluxdo/pull/237)) by @miniworldcnmm

- 取消主动指纹上报 by @Lingyan000

- Cookie 同步到 webview 逻辑优化 by @Lingyan000

- 用户签名显示支持，close [#234](https://github.com/lingyan000/fluxdo/issues/234) by @Lingyan000

- 图片查看器体验优化 by @Lingyan000

- 树形视图体验优化 by @Lingyan000

- 编辑器支持插入 Callout，close [#95](https://github.com/lingyan000/fluxdo/issues/95) by @Lingyan000

- AI 模型快捷词支持导出导入 by @Lingyan000

- AI 助手模型调用 prompt 缓存支持 by @Lingyan000

- 优化 AI 助手关闭连接逻辑 by @Lingyan000

- AI 助手支持选择思考深度 by @Lingyan000

- 模型配置界面优化 by @Lingyan000

- AI 助手提示词界面优化，生图模式优化 by @Lingyan000

- AI 助手优化 by @Lingyan000

- 发布脚本优化 by @Lingyan000

- 国际化功能优化，项目工程优化 by @Lingyan000

- 快捷键功能优化 by @Lingyan000


### 🐛 修复

- 修复回复话题和 messageBus 的竞态问题，fix [#233](https://github.com/lingyan000/fluxdo/issues/233) by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.13...v0.2.15

## [0.2.13] - 2026-04-24


### 🌟 新功能

- 默认树形视图支持，树形视图功能优化 by @Lingyan000

- 话题详情更多菜单中支持更多的功能 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.12...v0.2.13

## [0.2.12] - 2026-04-22


### 🌟 新功能

- 树形视图界面优化 by @Lingyan000


### 🐛 修复

- 树形视图 404 修复 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.11...v0.2.12

## [0.2.11] - 2026-04-20


### 🌟 新功能

- 帖子 details 性能优化 by @Lingyan000

- 帖子 policy 内容支持 by @Lingyan000

- 贴内时间内容支持，close [#202](https://github.com/lingyan000/fluxdo/issues/202) by @Lingyan000

- 顶栏自定义布局支持 by @Lingyan000

- 添加底栏设置 by @Lingyan000


### 🐛 修复

- Android PassKey 修复 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.10...v0.2.11

## [0.2.10] - 2026-04-20


### 🐛 修复

- 修复 macOS 下 per-device CA 未启用导致 WKWebView 证书验证失败 (#228) ([#228](https://github.com/lingyan000/fluxdo/pull/228)) by @AmosBloomfield




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.9...v0.2.10

## [0.2.9] - 2026-04-18


### 🌟 新功能

- 对话框模糊性能优化 by @Lingyan000

- PassKey 支持 by @Lingyan000

- 内置浏览器网址输入弹框优化 by @Lingyan000

- 请求添加 Discourse-Present 头 by @Lingyan000

- 内置浏览器性能优化 by @Lingyan000

- 添加指纹上报 by @Lingyan000

- 优化 DOH 保活检测 by @Lingyan000

- 优化通知列表更新逻辑 by @Lingyan000

- 新增侧栏分类快捷入口与 Windows WebView 兜底逻辑 (#217) ([#217](https://github.com/lingyan000/fluxdo/pull/217)) by @liucong2013


### 🐛 修复

- 修复一些无感知异常 by @Lingyan000


### ♻️ 重构

- 代码优化 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.8...v0.2.9

## [0.2.8] - 2026-04-13


### 🌟 新功能

- 修复 Windows 无法分享的问题，close [#200](https://github.com/lingyan000/fluxdo/issues/200) by @Lingyan000

- 修复 windows 无法上传图片，close [#212](https://github.com/lingyan000/fluxdo/issues/212) by @Lingyan000

- 网络检查性能优化，ref #205 by @Lingyan000

- 通知、私信功能优化，并添加私信列表，close [#216](https://github.com/lingyan000/fluxdo/issues/216) by @Lingyan000

- 保守登出复检机制 by @Lingyan000

- WebView 适配器缓存问题修复 by @Lingyan000

- 日志记录优化 by @Lingyan000


### 🐛 修复

- 修复 Windows 无法关闭的问题 by @Lingyan000

- 修复某些场景无法加载更多帖子的问题 by @Lingyan000

- 修复帖子内容更新后无法发送 boost by @Lingyan000

- 修复 cookieJar 同步到 webview 的异常 by @Lingyan000


### ♻️ 重构

- 取消提交多语言的 merged by @Lingyan000

- 多语言能力模块化设计 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.7...v0.2.8

## [0.2.7] - 2026-04-12


### 🌟 新功能

- 自检优化 by @Lingyan000

- 优化 boost 显示 by @Lingyan000

- 解决应用内清除 Cookie 的隐患 by @Lingyan000

- 移除 Android CDP 同步 Cookie by @Lingyan000

- 一些功能优化 by @Lingyan000

- 样式优化 by @Lingyan000

- Webview 适配器支持 by @Lingyan000

- 嵌套视图实现（实验性） by @Lingyan000

- Boost 支持 by @Lingyan000

- 登录流程优化 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.6...v0.2.7

## [0.2.6] - 2026-03-31


### 🌟 新功能

- 请求链路优化 by @Lingyan000

- 适配器优化 by @Lingyan000

- 桌面端快捷键完善 by @Lingyan000

- CF 自动续期逻辑优化 by @Lingyan000

- Windows 图标圆角，close [#183](https://github.com/lingyan000/fluxdo/issues/183) by @Lingyan000

- 桌面端快捷键支持 by @Lingyan000

- 桌面平台鼠标操作优化，ref #186 by @Lingyan000

- 支持私信反馈日志 by @Lingyan000

- 附件上传支持 by @Lingyan000

- MessageBus 日志记录优化 by @Lingyan000

- 模糊效果优化 by @Lingyan000


### 🐛 修复

- 修复 Windows 上 WebView 不被代理的问题，fix [#199](https://github.com/lingyan000/fluxdo/issues/199) by @Lingyan000

- 修复 Cronet 适配器异常降级无法恢复的问题 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.5...v0.2.6

## [0.2.5] - 2026-03-30


### 🔧 其他

- 🚑️ Windows 卡验证修复 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.4...v0.2.5

## [0.2.4] - 2026-03-30


### 🌟 新功能

- 添加元宇宙授权遇到异常时的提示，close [#172](https://github.com/lingyan000/fluxdo/issues/172) by @Lingyan000

- 下载功能优化，close [#180](https://github.com/lingyan000/fluxdo/issues/180) by @Lingyan000

- Cookie 逻辑精简优化，⚠️ 需要重新登录 by @Lingyan000

- CA 证书相关优化，IOS 编译优化 by @Lingyan000

- 模糊效果优化 by @Lingyan000


### 🐛 修复

- 修复双栏模式下，分类/标签详情列表无法跳转的问题，fix [#191](https://github.com/lingyan000/fluxdo/issues/191) by @Lingyan000

- : APP内置网页浏览注入 iOS 15 polyfill 修复JS缺失导致白屏问题 (#190) ([#190](https://github.com/lingyan000/fluxdo/pull/190)) by @nebula5725




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.3...v0.2.4

## [0.2.3] - 2026-03-29


### 🐛 修复

- : 注入 iOS 15 JS polyfill 修复登录页白屏问题 (#185) ([#185](https://github.com/lingyan000/fluxdo/pull/185)) by @nebula5725


### 🔧 其他

- 🚑️ 取消 Android 默认 CDP 机制，不再支持 WebView 双向同步，解决新版本掉登录问题 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.2...v0.2.3

## [0.2.2] - 2026-03-28


### 🔧 其他

- 🚑️ 尝试解决掉登录的问题 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.2.1...v0.2.2

## [0.2.1] - 2026-03-27


### 🌟 新功能

- 支持对话框模糊背景 by @Lingyan000

- 长表格渲染优化，close [#170](https://github.com/lingyan000/fluxdo/issues/170) by @Lingyan000

- 功能优化 by @Lingyan000

- AI 助手可开启滑动显示模式 by @Lingyan000

- 统计卡片自定义 by @Lingyan000

- 功能优化，UI 更新 by @Lingyan000

- 新 Cookie 机制迁移 by @Lingyan000

- Windows DOH 适配 by @Lingyan000

- 修改 CookieJar 与 WebView Cookie 的同步方式 by @Lingyan000

- Cookie 相关代码逻辑优化 by @Lingyan000

- CA 证书相关优化 by @Lingyan000

- IOS DOH 功能支持 by @Lingyan000

- 优化 macOS 构建以及支持 macOS 的 WebView 代理 (#171) ([#171](https://github.com/lingyan000/fluxdo/pull/171)) by @RebornQ


### 🐛 修复

- 修复一些问题 by @Lingyan000

- 修复 IOS 编译问题 by @Lingyan000

- 修复 macOS 14 版本判断错误 ([#176](https://github.com/lingyan000/fluxdo/pull/176)) by @RebornQ

- 修复 macOS 滚轮/触控板滚动导致的吸附跳动 ([#173](https://github.com/lingyan000/fluxdo/pull/173)) by @RebornQ


### 🔧 其他

- 🚑️ 修复 Cookie 无法读取的问题 by @Lingyan000

- 🚀 CI 优化 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.56...v0.2.1

## [0.1.56] - 2026-03-23


### 🌟 新功能

- 功能优化 by @Lingyan000

- 优化下载附件文件名获取逻辑 by @Lingyan000

- AI助手未配置 API Key 时提示 by @Lingyan000

- Hcaptcha 无障碍支持，close [#166](https://github.com/lingyan000/fluxdo/issues/166) by @Lingyan000

- 优化桌面端登录按钮样式 by @Lingyan000

- 支持滑动关闭 PopupMenu by @Lingyan000

- Flatpak 构建测试 by @Lingyan000

- 优化 windows 关闭窗口流程 by @Lingyan000

- 取消登录失效二次验证，网络设置支持调整速率 by @Lingyan000

- 登录流程优化 by @Lingyan000

- 登录失效验证优化 by @Lingyan000

- Windows exe 安装包支持 by @Lingyan000


### 🐛 修复

- 修复含有 emoji 的链接无法点击跳转的问题，fix [#163](https://github.com/lingyan000/fluxdo/issues/163) by @Lingyan000

- 修复错误的日志记录 by @Lingyan000

- 修复通知面板骨架屏下移的问题 by @Lingyan000

- 尝试修复 windows 上登录完成之后不触发登录成功的问题 by @Lingyan000

- 修复个人页常用功能区域会溢出的问题 by @Lingyan000

- 加载新帖逻辑修复 by @Lingyan000

- 修复 windows 最大化异常问题 by @Lingyan000

- 通知面板显示修复，fix [#160](https://github.com/lingyan000/fluxdo/issues/160) by @Lingyan000


### 🔧 其他

- 🚀 部署优化 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/flatpak-wpe-layer-gnome48-v2...v0.1.56

## [0.1.55] - 2026-03-20


### 🌟 新功能

- 编辑器支持插入模板 by @Lingyan000

- Windows 兼容优化 by @Lingyan000

- 个人页布局优化 by @Lingyan000

- 请求并发控制优化 by @Lingyan000

- 优化 Cookie 同步逻辑 by @Lingyan000

- 提升内置浏览器体验，添加收藏能力，添加下载管理 by @Lingyan000

- 桌面端体验优化 by @Lingyan000

- 优化回复报错提示，close [#155](https://github.com/lingyan000/fluxdo/issues/155) by @Lingyan000

- 帖子详情和只看顶层实现，close [#153](https://github.com/lingyan000/fluxdo/issues/153) by @Lingyan000

- 用户登录失效判断优化 by @Lingyan000

- 过盾体验优化 by @Lingyan000

- 提高 rhttp 适配器稳定性 by @Lingyan000

- DOH 网关模式稳定性修复 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.54...v0.1.55

## [0.1.53] - 2026-03-17


### 🌟 新功能

- 支持邮箱链接登录 by @Lingyan000

- 支持切换字体，ref #152 by @Lingyan000

- AI 服务可跟随应用网络设置，close [#147](https://github.com/lingyan000/fluxdo/issues/147) by @Lingyan000

- 图片批量上传策略优化，close [#151](https://github.com/lingyan000/fluxdo/issues/151) by @Lingyan000

- 更新下载界面优化 by @Lingyan000

- 国际化支持 by @Lingyan000

- RHttp 适配器支持 by @Lingyan000


### 🐛 修复

- CF 验证相关问题修复 by @Lingyan000


### 🔧 其他

- 🚑️ 修复安卓无法启动 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.52...v0.1.53

## [0.1.52] - 2026-03-15


### 🌟 新功能

- 预览弹框可点击进入分类、标签列表 by @Lingyan000

- DOH 功能优化 by @Lingyan000

- 话题内头部信息分类、标签支持跳转，close [#146](https://github.com/lingyan000/fluxdo/issues/146) by @Lingyan000

- 表情面板功能优化 by @Lingyan000


### 🐛 修复

- 模糊剧透问题修复，fix [#150](https://github.com/lingyan000/fluxdo/issues/150) by @Lingyan000

- 修复创建或编辑话题时切换到预览无法发布的问题，fix [#116](https://github.com/lingyan000/fluxdo/issues/116) by @Lingyan000

- 修复 macOS 未声明相册权限导致的闪退，fix [#149](https://github.com/lingyan000/fluxdo/issues/149) by @Lingyan000

- 修复附件无法下载，fix [#141](https://github.com/lingyan000/fluxdo/issues/141) by @Lingyan000

- 修复了一些问题 by @Lingyan000


### 🔧 其他

- 🚀 CI 修复 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.51...v0.1.52

## [0.1.51] - 2026-03-13


### 🌟 新功能

- 表情包支持，感谢 @stevessr by @Lingyan000

- 提升网络请求稳定性 by @Lingyan000

- VPN 自动切换，close [#115](https://github.com/lingyan000/fluxdo/issues/115) by @Lingyan000

- DOH 支持复制地址、编辑，close [#138](https://github.com/lingyan000/fluxdo/issues/138)，close [#100](https://github.com/lingyan000/fluxdo/issues/100) by @Lingyan000

- 更新 doh_proxy by @Lingyan000

- FAB 子按钮支持 by @Lingyan000

- Improve upstream proxy support on android ([#125](https://github.com/lingyan000/fluxdo/pull/125)) by @RiftRays

- 帖子内容优化 by @Lingyan000

- 用户封禁显示，close [#139](https://github.com/lingyan000/fluxdo/issues/139) by @Lingyan000

- 支持图标切换 by @Lingyan000

- 图片批量上传，close [#130](https://github.com/lingyan000/fluxdo/issues/130) by @Lingyan000

- 图片查看器手势优化 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.50...v0.1.51

## [0.1.50] - 2026-03-12


### 🐛 修复

- 修复部分图片资源无法加载 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.49...v0.1.50

## [0.1.49] - 2026-03-12


### 🌟 新功能

- MacOS 图标优化 by @Lingyan000

- 图片链接提取优化 by @Lingyan000

- AI 助手界面优化，close [#136](https://github.com/lingyan000/fluxdo/issues/136) by @Lingyan000

- 帖子通知显示支持 by @Lingyan000


### 📝 文档

- README 更新 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.48...v0.1.49

## [0.1.48] - 2026-03-12


### 🌟 新功能

- 请求策略优化 by @Lingyan000

- 数据管理功能，refs #115 by @Lingyan000

- 优化书签列表显示效果 by @Lingyan000


### 🐛 修复

- 修复一些场景图片加载失效的问题 by @Lingyan000


### 🔧 其他

- 🚀 CI 修复 by @Lingyan000

- 🚀 MacOS 构建支持 by @Lingyan000

- 🚀 Altstore 支持，close [#135](https://github.com/lingyan000/fluxdo/issues/135) by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.47...v0.1.48

## [0.1.47] - 2026-03-11


### 🐛 修复

- 解决部分帖子无法点击查看大图的问题，fix [#134](https://github.com/lingyan000/fluxdo/issues/134) by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.46...v0.1.47

## [0.1.46] - 2026-03-10


### 🌟 新功能

- 优化书签卡片展示，refs #133 by @Lingyan000

- AI 助手导出图片功能，close [#132](https://github.com/lingyan000/fluxdo/issues/132) by @Lingyan000

- 优化回应弹框显示效果 by @Lingyan000

- 稍后阅读浮窗数量角标显示优化 by @Lingyan000

- AI 助手优化，close [#132](https://github.com/lingyan000/fluxdo/issues/132) by @Lingyan000

- 优化部分场景动画效果 by @Lingyan000

- 浮窗位置计算优化 by @Lingyan000

- 支持开关滚动收起导航栏 by @Lingyan000

- 启动页优化，防止一些极端场景卡启动页 by @Lingyan000

- 稍后阅读功能，refs #115 by @Lingyan000

- 书签功能优化，refs #115 by @Lingyan000

- SVG 渲染优化，close [#126](https://github.com/lingyan000/fluxdo/issues/126) by @Lingyan000

- 优化过盾逻辑 by @Lingyan000

- 异形屏横屏适配，close [#110](https://github.com/lingyan000/fluxdo/issues/110) by @Lingyan000

- Token 变更日志 by @Lingyan000

- 更详情的退出日志 by @Lingyan000


### 🐛 修复

- 修复邀请链接显示与限频提示 (#129) ([#129](https://github.com/lingyan000/fluxdo/pull/129)) by @N1nEmAn




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.45...v0.1.46

## [0.1.45] - 2026-03-10


### 🔧 其他

- 🚑️ 修复 CF 过盾异常 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.44...v0.1.45

## [0.1.44] - 2026-03-10


### 🐛 修复

- 修复话题详情到底还会继续触发加载的问题 by @Lingyan000


### 🔧 其他

- 🚑️ 修复 CF 盾后无法进入页面 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.43...v0.1.44

## [0.1.43] - 2026-03-09


### 🌟 新功能

- 一些功能优化 by @Lingyan000

- 元宇宙功能优化 by @Lingyan000

- 网络添加会话代守卫拦截器，提升应用稳定性 by @Lingyan000

- 过盾体验优化 by @Lingyan000


### 🐛 修复

- 修复了一些问题，ref #116 by @Lingyan000


### 🔧 其他

- Add invite links and remember AI model selection (#120) ([#120](https://github.com/lingyan000/fluxdo/pull/120)) by @N1nEmAn




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.42...v0.1.43

## [0.1.42] - 2026-03-07


### 🌟 新功能

- 应用日志功能优化 by @Lingyan000

- 请求相关问题优化 by @Lingyan000


### 🐛 修复

- 修复游客模式调用错误的 MessageBus 接口的问题 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.41...v0.1.42

## [0.1.41] - 2026-03-06


### 🌟 新功能

- 日志功能优化 by @Lingyan000

- 优化请求策略 by @Lingyan000

- 优化首页 tab 逻辑，避免同时请求 by @Lingyan000

- 请求相关优化 by @Lingyan000

- 网络断开提示 by @Lingyan000

- 优化 Toast 样式 by @Lingyan000

- 优化一些场景的请求 by @Lingyan000


### 🐛 修复

- 修复一些问题 by @Lingyan000

- 修复会通过主域名触发 MessageBus 的问题 by @Lingyan000

- 修复单栏创建话题时没有打开话题详情页面的问题 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.40...v0.1.41

## [0.1.40] - 2026-03-05


### 🌟 新功能

- 优化请求策略，避免频繁触发站点风控、掉登录等问题，close [#111](https://github.com/lingyan000/fluxdo/issues/111) #93 #75 #84 #60 by @Lingyan000

- 新话题/未读完计数展示 by @Lingyan000

- 优化通知计数自动归零的问题 by @Lingyan000


### 🐛 修复

- 修复话题更新提示功能的一些问题 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.39...v0.1.40

## [0.1.39] - 2026-03-05


### 🌟 新功能

- 优化话题更新提示和功能 by @Lingyan000

- 排序功能支持，close [#104](https://github.com/lingyan000/fluxdo/issues/104) #70 by @Lingyan000


### 🐛 修复

- 修复热门无法和其他筛选项组合的问题，fix [#107](https://github.com/lingyan000/fluxdo/issues/107) by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.38...v0.1.39

## [0.1.38] - 2026-03-03


### 🌟 新功能

- 应用样式焕新，取消绝大多数场景的卡片边框，更清爽 by @Lingyan000

- 轮播图查看支持 by @Lingyan000

- 文本选择修改为只能选择帖子内容 by @Lingyan000

- 日志集成设备信息，close [#92](https://github.com/lingyan000/fluxdo/issues/92) by @Lingyan000

- 应用日志功能实现 by @Lingyan000

- 首页向上滚动时 FAB 切换为刷新 by @Lingyan000

- 优化用户信息请求策略，回到前台时不再自动请求 by @Lingyan000

- 长按预览显示主贴，close [#98](https://github.com/lingyan000/fluxdo/issues/98) by @Lingyan000

- 优化图片上传功能，gif 不允许压缩 by @Lingyan000

- 优化内置浏览器体验，支持打开应用，close [#102](https://github.com/lingyan000/fluxdo/issues/102) by @Lingyan000

- 标签选择器逻辑优化，close [#103](https://github.com/lingyan000/fluxdo/issues/103) by @Lingyan000

- 优化 MessageBus 逻辑，更新为最新域名 by @Lingyan000

- 支持竖屏锁定 by @Lingyan000

- 集成 Firebase Crashlytics by @Lingyan000

- 优化响应式布局效果 by @Lingyan000

- 边界场景优化 by @Lingyan000

- 话题详情性能优化 by @Lingyan000

- 优化启动速度 by @Lingyan000

- 优化启动服务执行顺序 by @Lingyan000


### 🐛 修复

- 修复一些问题 by @Lingyan000

- 修复一处不影响使用的报错 by @Lingyan000


### 📝 文档

- 更新 README by @Lingyan000

- README 更新 by @Lingyan000


### 🔧 其他

- 🔧 追加 google-services.json by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.37...v0.1.38

## [0.1.37] - 2026-03-02


### 🔧 其他

- 🚑️ 回退 doh_proxy by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.36...v0.1.37

## [0.1.36] - 2026-03-02


### 🌟 新功能

- 网络错误场景优化 by @Lingyan000

- 更新 doh_proxy by @Lingyan000

- 优化一些边界场景的逻辑 by @Lingyan000

- 登录自动填充支持，close [#94](https://github.com/lingyan000/fluxdo/issues/94) by @Lingyan000

- 优化应用基础功能体验 by @Lingyan000

- 登录失效时弹框提示 by @Lingyan000


### 🐛 修复

- 修复首页不松手也会触发吸附显隐的问题 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.35...v0.1.36

## [0.1.35] - 2026-03-01


### 🌟 新功能

- 折叠帖子的显示，以及用户订阅功能实现 by @Lingyan000

- 混排优化功能优化，解决一些破坏 md 格式的问题 by @Lingyan000

- 元宇宙多卡片合并显示，close [#89](https://github.com/lingyan000/fluxdo/issues/89) by @Lingyan000

- AI 摘要渲染优化 by @Lingyan000


### 🐛 修复

- 修复首次打开更多菜单时打赏选项不显示的问题 by @Lingyan000

- 修复模糊剧透无法揭示的问题 by @Lingyan000


### ⚡ 性能

- ️ 长贴性能优化 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.34...v0.1.35

## [0.1.34] - 2026-02-28


### 🌟 新功能

- AI 助手交互优化，close [#83](https://github.com/lingyan000/fluxdo/issues/83) by @Lingyan000

- 图片缓存优化 by @Lingyan000

- 帖子内容渲染优化 by @Lingyan000

- 发帖审核提示，close [#86](https://github.com/lingyan000/fluxdo/issues/86) by @Lingyan000

- 实现打赏功能 by @Lingyan000

- 优化元宇宙相关功能显示逻辑 by @Lingyan000

- 图片支持长按打开菜单 by @Lingyan000

- DOH 逻辑优化 by @Lingyan000

- 模糊剧透的图片揭示之后可以点击查看大图 by @Lingyan000

- 支持输入楼层跳转，close [#80](https://github.com/lingyan000/fluxdo/issues/80) by @Lingyan000

- 离开 AI 页面时取消输入框焦点，防止返回时键盘意外弹出 by @Lingyan000


### 🐛 修复

- 修复 IOS 的一些异常情况 by @Lingyan000

- 修复贴内话题链接跳转异常问题 by @Lingyan000


### ⚡ 性能

- ️ 部分场景性能优化 by @Lingyan000


### 🔧 其他

- Create LICENSE by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.33...v0.1.34

## [0.1.33] - 2026-02-27


### 🌟 新功能

- 功能优化 by @Lingyan000

- 优化应用稳定性 by @Lingyan000

- 引用回复功能实现 by @Lingyan000

- 优化浏览分类弹框 UI by @Lingyan000

- 通知功能改版 by @Lingyan000

- 优化图片查看页面左右滑动 by @Lingyan000

- 图片查看器手势优化 by @Lingyan000

- DOH 日志完善 by @Lingyan000


### 🐛 修复

- 修复 AI 助手输入框聚焦时，帖子列表页面会弹出键盘的问题 by @Lingyan000

- 修复登录失效问题 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.32...v0.1.33

## [0.1.32] - 2026-02-26


### 🌟 新功能

- 优化 Cookie 读取逻辑 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.31...v0.1.32

## [0.1.31] - 2026-02-26


### 🌟 新功能

- 优化 AI 助手界面 UI，close [#74](https://github.com/lingyan000/fluxdo/issues/74) by @Lingyan000

- 优化后台通知逻辑 by @Lingyan000

- 通知卡片显示优化 by @Lingyan000

- 优化 MessageBus 代码逻辑 by @Lingyan000

- 优化 messageBus 429 重试逻辑 by @Lingyan000

- 时间显示优化 by @Lingyan000

- 通知列表分页支持 by @Lingyan000


### 🐛 修复

- 修复 IOS 保存图片闪退的问题，fix [#73](https://github.com/lingyan000/fluxdo/issues/73) by @Lingyan000

- 修复一些问题 by @Lingyan000

- 修复某些场景代码块显示异常 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.30...v0.1.31

## [0.1.30] - 2026-02-26


### 🐛 修复

- Cookie 问题修复 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.29...v0.1.30

## [0.1.29] - 2026-02-25


### 🐛 修复

- 修复 ci 异常 by @Lingyan000

- 修复 ios ci 编译异常 by @Lingyan000

- 修复一些问题 by @Lingyan000


### 🔧 其他

- 更新 CHANGELOG.md by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.28...v0.1.29

## [0.1.28] - 2026-02-24


### 🌟 新功能

- 编辑器图片上传前置 by @Lingyan000

- AI 助手集成 by @Lingyan000

- Cookie 同步逻辑优化 by @Lingyan000

- 元宇宙接入 CDK，close [#59](https://github.com/lingyan000/fluxdo/issues/59) by @Lingyan000

- 修复 callout 嵌套异常，fix [#69](https://github.com/lingyan000/fluxdo/issues/69) by @Lingyan000

- 优化图片显示 by @Lingyan000

- 优化图片查看体验 by @Lingyan000

- 图片查看页面显示图片名，close [#65](https://github.com/lingyan000/fluxdo/issues/65) by @Lingyan000

- 退出二次确认，close [#54](https://github.com/lingyan000/fluxdo/issues/54) by @Lingyan000

- 解决楼层数滚不到底的问题。 (#63) ([#63](https://github.com/lingyan000/fluxdo/pull/63)) by @Antman2023

- 优化小白条沉浸效果 by @Lingyan000


### 🐛 修复

- 修复 IOS 后台异常导致的重启 by @Lingyan000

- 修复底栏分享图标和其他图标颜色不一致的问题，fix [#68](https://github.com/lingyan000/fluxdo/issues/68) by @Lingyan000

- 修复模糊剧透显示到未展开 details 的问题，fix [#66](https://github.com/lingyan000/fluxdo/issues/66) by @Lingyan000

- 修复内置代理，webview 不被代理的问题，fix [#62](https://github.com/lingyan000/fluxdo/issues/62) by @Lingyan000


### ⚡ 性能

- ️ 优化内存占用 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.27...v0.1.28

## [0.1.27] - 2026-02-22


### 🌟 新功能

- 添加未浏览筛选项，close [#61](https://github.com/lingyan000/fluxdo/issues/61) by @Lingyan000

- 优化版主操作样式 by @Lingyan000


### 🐛 修复

- 修复表情选择器打开时，点击编辑器状态未切换的问题 by @Lingyan000


### ⚡ 性能

- ️ 缓存查询性能优化 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.26...v0.1.27

## [0.1.26] - 2026-02-22


### 🌟 新功能

- 回应支持查看回应人 by @Lingyan000

- 编辑器功能优化 by @Lingyan000


### 🐛 修复

- 修复进度指示器可能不准确的问题 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.25...v0.1.26

## [0.1.25] - 2026-02-21


### 🌟 新功能

- 长按预览支持更多页面，并支持快捷分享 by @Lingyan000

- 编辑器支持插入模糊剧透 by @Lingyan000

- 搜索结果包含 AI 结果，close [#52](https://github.com/lingyan000/fluxdo/issues/52) by @Lingyan000

- 话题列表排序持久化，close [#57](https://github.com/lingyan000/fluxdo/issues/57) by @Lingyan000

- 编辑器体验优化 by @Lingyan000

- 添加书签支持话题添加书签，close [#50](https://github.com/lingyan000/fluxdo/issues/50) by @Lingyan000

- 话题卡片更紧凑，并更新预览弹框显示更多信息，close [#58](https://github.com/lingyan000/fluxdo/issues/58) by @Lingyan000

- 优化全局提示效果 by @Lingyan000

- 后台通知优化 by @Lingyan000


### 🐛 修复

- 尝试修复自动混排和输入法自动括号冲突问题 by @Lingyan000

- 修复话题阅读数量不被统计的问题 by @Lingyan000

- 修复首贴不会被销毁的问题 by @Lingyan000

- 尝试修复横屏切换竖屏，布局不更新的问题，fix [#48](https://github.com/lingyan000/fluxdo/issues/48) by @Lingyan000

- 修复 IOS、MACOS 上的一些问题 by @Lingyan000

- 修复 ios 无法使用谷歌登录的问题，fix [#56](https://github.com/lingyan000/fluxdo/issues/56) by @Lingyan000

- 修复小白条沉浸问题，Fixes [#55](https://github.com/lingyan000/fluxdo/issues/55) by @Lingyan000

- 修复回复成功之后会回弹的问题 by @Lingyan000

- 修复我的页面的部分状态表情不显示的问题 by @Lingyan000

- 修复进入话题详情必须滑动才能触发阅读记录的问题 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.24...v0.1.25

## [0.1.24] - 2026-02-13


### 🌟 新功能

- 优化体验 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.23...v0.1.24

## [0.1.23] - 2026-02-12


### 🐛 修复

- 修复首页卡死 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.22...v0.1.23

## [0.1.22] - 2026-02-12


### 🌟 新功能

- 搜索功能优化 by @Lingyan000

- 用户资料页面优化，fix [#44](https://github.com/lingyan000/fluxdo/issues/44) by @Lingyan000

- 新、未读排序下可以一键已读，close [#42](https://github.com/lingyan000/fluxdo/issues/42) by @Lingyan000

- 优化体验 by @Lingyan000

- 首页焕新，全新的过滤交互，ref #43 by @Lingyan000

- 优化视频播放体验 by @Lingyan000

- 搜索功能优化 by @Lingyan000

- 用户资料页面优化，fix [#44](https://github.com/lingyan000/fluxdo/issues/44) by @Lingyan000

- 新、未读排序下可以一键已读，close [#42](https://github.com/lingyan000/fluxdo/issues/42) by @Lingyan000

- 优化体验 by @Lingyan000

- 首页焕新，全新的过滤交互，ref #43 by @Lingyan000

- 优化视频播放体验 by @Lingyan000


### 🐛 修复

- 修复一些问题 by @Lingyan000

- 修复一些问题 by @Lingyan000


### ♻️ 重构

- 重构图片粘贴实现 by @Lingyan000

- 重构图片粘贴实现 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.21...v0.1.22

## [0.1.21] - 2026-02-11


### 🌟 新功能

- 表情面板键盘切换效果优化 by @Lingyan000

- Connect UI 同步 by @Lingyan000

- 编辑体验优化，支持粘贴图片，refs #42 by @Lingyan000

- 链接确认打开弹框 by @Lingyan000

- 话题预览弹框样式优化 by @Lingyan000

- 生成图片分享功能优化 by @Lingyan000


### 🐛 修复

- 修复表情选择器无法切换 tab by @Lingyan000

- 修复了一些问题 by @Lingyan000

- 修复进度指示器部分场景不更新的问题 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.20...v0.1.21

## [0.1.19] - 2026-02-09


### 🌟 新功能

- 一些功能优化 by @Lingyan000

- 长贴性能优化 by @Lingyan000

- 新 connect 兼容 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.18...v0.1.19

## [0.1.18] - 2026-02-08


### 🐛 修复

- 转义 Telegram Markdown 特殊字符" by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.17...v0.1.18

## [0.1.17] - 2026-02-08


### 🌟 新功能

- 扫描性能优化 by @Lingyan000

- Code 表格内样式优化 by @Lingyan000

- 话题详情 Bar Actions 优化 by @Lingyan000

- 优化首页顶栏底栏隐藏逻辑，close [#39](https://github.com/lingyan000/fluxdo/issues/39) by @Lingyan000

- 话题内搜索 by @Lingyan000

- 我的书签、我的话题、浏览历史实现搜索功能 by @Lingyan000

- 优化扫描类背景的稳定性 by @Lingyan000

- 分享支持生成分享图片、导出文章功能，close [#38](https://github.com/lingyan000/fluxdo/issues/38) by @Lingyan000

- 帖子卡片显示更多的用户信息，close [#37](https://github.com/lingyan000/fluxdo/issues/37) by @Lingyan000

- Code 标签样式优化 by @Lingyan000


### 🐛 修复

- 修复分块渲染时没显示链接点击数 by @Lingyan000

- 修复搜索分页无效的问题 by @Lingyan000

- 修复 onebox 链接没有走通用链接跳转逻辑，fix [#40](https://github.com/lingyan000/fluxdo/issues/40) by @Lingyan000

- 修复图片高度显示异常 by @Lingyan000

- 修复某些场景提交完成之后不会正确删除草稿 by @Lingyan000

- 修复 image grid 画廊被隔离的问题 by @Lingyan000

- 修复引导页登录之后进入页面卡 loading 的问题 by @Lingyan000


### ♻️ 重构

- 重构 post_item by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.16...v0.1.17

## [0.1.12] - 2026-02-03


### 🌟 新功能

- 内联元素样式优化 by @Lingyan000

- 模糊剧透效果优化 by @Lingyan000

- 提升 iframe 浏览体验 by @Lingyan000

- DeepLink 逻辑优化 by @Lingyan000

- 支持图片网络显示/编辑 by @Lingyan000

- 有序/无序列表显示优化 by @Lingyan000

- 搜索记录排序记忆，Refs #31 by @Lingyan000

- 优化提及、内嵌代码块显示样式 by @Lingyan000

- Iframe 兼容性适配 by @Lingyan000

- 草稿功能体验优化 by @Lingyan000

- 响应式布局优化 by @Lingyan000

- 手动代理，close [#19](https://github.com/lingyan000/fluxdo/issues/19) by @Lingyan000

- 安卓动态图标实现，close [#33](https://github.com/lingyan000/fluxdo/issues/33) by @Lingyan000

- 草稿功能，close [#36](https://github.com/lingyan000/fluxdo/issues/36) by @Lingyan000

- 内容字体大小调节，close [#35](https://github.com/lingyan000/fluxdo/issues/35) by @Lingyan000

- 优化 iframe 实现，close [#34](https://github.com/lingyan000/fluxdo/issues/34) by @Lingyan000

- 内嵌网页版编辑个人信息，close [#27](https://github.com/lingyan000/fluxdo/issues/27) by @Lingyan000

- 页面错误提示优化 by @Lingyan000

- 支持应用链接，close [#26](https://github.com/lingyan000/fluxdo/issues/26) by @Lingyan000

- 头像显示优化 by @Lingyan000

- 链接点击数优化 by @Lingyan000

- X 卡片样式优化 by @Lingyan000

- 话题筛选功能优化，close [#29](https://github.com/lingyan000/fluxdo/issues/29) by @Lingyan000

- 应用内更新，close [#25](https://github.com/lingyan000/fluxdo/issues/25) by @Lingyan000

- 标签样式更新 by @Lingyan000

- 通知列表 emoji 显示 by @Lingyan000

- 偏好设置提供外部链接使用内置浏览器开关 by @Lingyan000

- 页面 loading 统一使用骨架屏 by @Lingyan000


### 🐛 修复

- 修复话题详情浅色模式骨架屏显示问题 by @Lingyan000

- 修复回应列表不能加载更多 by @Lingyan000

- 修复部分场景话题详情无法向下加载 by @Lingyan000

- 修复无法话题浏览器打开功能失效 by @Lingyan000

- 修复回应列表不能加载更多 by @Lingyan000

- 修复话题详情页面异常场景循环构建的问题 by @Lingyan000

- 修复部分场景跳转白屏问题 by @Lingyan000


### ⚡ 性能

- ️ 提升话题详情页滑动流畅性 by @Lingyan000


### ♻️ 重构

- 重构话题详情代码 by @Lingyan000

- 分页加载统一管理，fix [#27](https://github.com/lingyan000/fluxdo/issues/27) by @Lingyan000

- 通知列表标题优先展示纯文本，fix [#30](https://github.com/lingyan000/fluxdo/issues/30) by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.11...v0.1.12

## [0.1.11] - 2026-02-02


### 🌟 新功能

- Callout 显示优化 by @Lingyan000

- 话题头部排版优化 by @Lingyan000

- 首页底栏顶栏显示隐藏优化 by @Lingyan000

- 相关链接显示 by @Lingyan000

- 恢复完整的 pangu，提供降标安全保护，close [#18](https://github.com/lingyan000/fluxdo/issues/18) by @Lingyan000

- 切图体验优化 by @Lingyan000

- 搜索记录显示，错误消息处理，fix 23，close [#24](https://github.com/lingyan000/fluxdo/issues/24) by @Lingyan000

- 排版优化简化 by @Lingyan000

- 构建 ipa by @Lingyan000


### 🐛 修复

- 修复投票不显示查看结果按钮，fix [#13](https://github.com/lingyan000/fluxdo/issues/13) by @Lingyan000

- Tag 兼容补充 by @Lingyan000


### ⚡ 性能

- ️ 提升滑动流畅度 by @Lingyan000


### ♻️ 重构

- DiscourseService 重构 by @Lingyan000

- 代码警告消除 by @Lingyan000


### 🔧 其他

- CI 修复 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.10...v0.1.11

## [0.1.10] - 2026-02-02


### 🌟 新功能

- 图片查看器图片过渡显示优化 by @Lingyan000

- 底栏滑动自动隐藏 by @Lingyan000

- 骨架屏显示优化 by @Lingyan000

- 长按预览功能 by @Lingyan000


### 🐛 修复

- 修复话题详情嵌套视图滚动会显示隐藏底栏的问题 by @Lingyan000


### 🔧 其他

- 🚑️ 兼容新的 api 结构，解决无法显示话题详情的问题（fix [#20](https://github.com/lingyan000/fluxdo/issues/20)） by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.9...v0.1.10

## [0.1.9] - 2026-02-01


### 🌟 新功能

- 匿名分享功能实现，(close [#15](https://github.com/lingyan000/fluxdo/issues/15)) by @Lingyan000

- 话题编辑功能，(close [#17](https://github.com/lingyan000/fluxdo/issues/17)) by @Lingyan000

- 支持混排优化，(close [#16](https://github.com/lingyan000/fluxdo/issues/16)) by @Lingyan000

- 修改回复主贴为等同回复话题，(close [#14](https://github.com/lingyan000/fluxdo/issues/14)) by @Lingyan000

- 支持删除线编辑，(close [#10](https://github.com/lingyan000/fluxdo/issues/10)) by @Lingyan000

- 时间解析优化，(fix [#10](https://github.com/lingyan000/fluxdo/issues/10)) by @Lingyan000

- 兼容聊天记录引用卡片 by @Lingyan000

- 登录登出体验优化 by @Lingyan000

- 采用更真实的设备 ua by @Lingyan000

- 图片查看优化 by @Lingyan000

- 公式内容显示支持 by @Lingyan000

- 图片上传体验优化，(close [#8](https://github.com/lingyan000/fluxdo/issues/8)) by @Lingyan000

- 帖子删除功能，(close [#6](https://github.com/lingyan000/fluxdo/issues/6)) by @Lingyan000

- 快问快答话题兼容 by @Lingyan000

- 优化图片查看页面状态栏显示 by @Lingyan000

- 优化过盾流程，仅不影响操作的放到后台过盾，并在网络设置中支持手动过盾 by @Lingyan000


### 🐛 修复

- 话题详情页面 bar 背景颜色切换错误修复 by @Lingyan000

- 修复 LDC 余额显示错误，(fix [#12](https://github.com/lingyan000/fluxdo/issues/12)) by @Lingyan000

- 修复相对路径图片不加载的问题，(fix [#3](https://github.com/lingyan000/fluxdo/issues/3)) by @Lingyan000


### 📝 文档

- 添加项目提示词 by @Lingyan000


### 📦 依赖更新

- ️ 依赖更新 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.8...v0.1.9

## [0.1.8] - 2026-01-31


### 🌟 新功能

- 添加 CIRA Canadian Shield 为内置 DOH 服务，（close [#5](https://github.com/lingyan000/fluxdo/issues/5)） by @Lingyan000

- 热门回复/只看题主体验优化 by @Lingyan000

- 大屏显示优化 by @Lingyan000


### 🔧 其他

- 🚑️ CF 过盾体验优化，解决启动时遇到盾会无法启动的问题 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.7...v0.1.8

## [0.1.7] - 2026-01-30


### 🌟 新功能

- UA 修改静态值，修复无法使用谷歌登录 by @Lingyan000

- 代码块显示优化 by @Lingyan000

- 只看题主功能实现 by @Lingyan000


### 🐛 修复

- 修复发送提示不会自动消失，(fixes [#2](https://github.com/lingyan000/fluxdo/issues/2)) by @Lingyan000

- 跳转问题修复 by @Lingyan000

- Mac 构建修复 by @Lingyan000


### ⚡ 性能

- ️ CF 过盾优化与日志导出 by @Lingyan000

- ️ 优化大屏使用体验 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.6...v0.1.7

## [0.1.6] - 2026-01-29


### 🌟 新功能

- 大图查看支持隐藏功能按钮、状态栏 by @Lingyan000

- 贴内图片支持分享 by @Lingyan000

- 优化大图查看体验 by @Lingyan000

- 用户资料页面头像支持大图查看 by @Lingyan000

- 优化提及块样式 by @Lingyan000

- 热门回复功能 by @Lingyan000

- 显示题主[主]，本人[我]的标识 by @Lingyan000


### 🐛 修复

- 修复分享完成后不能回到当前应用的问题 by @Lingyan000

- Onebox 显示优化 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.5...v0.1.6

## [0.1.5] - 2026-01-28


### 🌟 新功能

- 新的代码高亮实现 by @Lingyan000

- Bar 点击标题展开 header by @Lingyan000

- 追踪链接点击 by @Lingyan000

- OneBox 更多类型展示 by @Lingyan000

- 话题订阅功能 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.4...v0.1.5

## [0.1.4] - 2026-01-27


### 🌟 新功能

- 支持帖子编辑功能和编辑时支持提及（@触发） by @Lingyan000


### 🐛 修复

- 修复话题投票时会直接刷新整个详情的问题 by @Lingyan000

- 修复回到顶部概率触发刷新 by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.3...v0.1.4

## [0.1.3] - 2026-01-26


### 🌟 新功能

- Add PreloadedDataService for efficient initial data loading and configure Android build with ABI filtering. by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.2...v0.1.3

## [0.1.2] - 2026-01-25


### 🌟 新功能

- Implement topic detail page with scroll management, post display, and visibility tracking. by @Lingyan000

- Add Discourse HTML content rendering with custom builders for various elements, including quote cards. by @Lingyan000

- Implement Discourse poll rendering and voting, and configure Android build with signing and desugaring. by @Lingyan000

- Add user profile page with login/logout, user settings, and initial Android build configuration. by @Lingyan000

- Implement topic detail page with dynamic post loading, scrolling, and user activity tracking. by @Lingyan000

- Implement core Discourse API service and topic detail page, including authentication, network handling, and screen tracking. by @Lingyan000

- Initialize Android build configuration and Flutter app entry point with service setup, theming, and localization. by @Lingyan000

- Implement topic creation flow with floating action button, navigation, and list refresh. by @Lingyan000

- Implement topic detail page with bi-directional post loading and new reply updates. by @Lingyan000

- Add GitHub Actions workflow for automated Android build, release, and changelog generation, including supporting scripts. by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.1...v0.1.2

## [0.1.1] - 2026-01-25


### 🌟 新功能

- Implement comprehensive CI/CD pipeline for Android builds, including Rust DOH proxy compilation, artifact generation, changelog, and release automation. by @Lingyan000




**Full Changelog**: https://github.com/lingyan000/fluxdo/compare/v0.1.0...v0.1.1

## [0.1.0] - 2026-01-24


### 🔧 其他

- Mvp by @Lingyan000




