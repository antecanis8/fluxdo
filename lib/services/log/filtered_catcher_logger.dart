import 'package:catcher_2/catcher_2.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

/// Catcher2 默认 logger 会把 logging 根级别设为 ALL，并打印所有包的日志。
/// flutter_widget_from_html 的 `fwfh.*` logger 在 FINE/FINEST 下非常高频，
/// 所以这里保留 Catcher 自身日志，同时让第三方包默认只输出 warning+。
class FilteredCatcherLogger extends Catcher2Logger {
  static bool _configured = false;

  @override
  void setup() {
    if (_configured) return;
    _configured = true;

    hierarchicalLoggingEnabled = true;
    Logger.root.level = Level.WARNING;
    Logger('Catcher 2').level = Level.ALL;

    Logger.root.onRecord.listen((record) {
      final isCatcherLog = record.loggerName == 'Catcher 2';
      if (!isCatcherLog && record.level < Level.WARNING) return;

      debugPrint(
        '[${record.time} | ${record.loggerName} | ${record.level.name}] '
        '${record.message}',
      );
      final error = record.error;
      if (error != null) {
        debugPrint('  Error: $error');
      }
      final stackTrace = record.stackTrace;
      if (stackTrace != null) {
        debugPrint('  StackTrace: $stackTrace');
      }
    });
  }
}
