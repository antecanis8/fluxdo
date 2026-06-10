/// 包内日志桥接。主应用启动时注入 [AiPackageLogger.handler] 把
/// AI 模块的诊断日志转到 `AppLogger`,从而能写到应用日志文件里
/// (release 模式下 `debugPrint` 不可见,必须走 file logger)。
///
/// 未注入时退化为空操作,不影响包的独立性。
typedef AiLogHandler = void Function(String level, String tag, String message);

class AiPackageLogger {
  AiPackageLogger._();

  static AiLogHandler? handler;

  static void info(String tag, String message) {
    handler?.call('info', tag, message);
  }

  static void warning(String tag, String message) {
    handler?.call('warning', tag, message);
  }

  static void error(String tag, String message) {
    handler?.call('error', tag, message);
  }
}
