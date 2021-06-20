import 'package:firestore_helper/models/log_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

class LoggingService {
  final Logger _logger;
  final bool _isEnabled;

  @visibleForTesting
  bool get isEnabled => _isEnabled;

  LoggingService(
    this._isEnabled, {
    Logger? logger,
  }) : this._logger = logger ?? Logger(printer: PrettyPrinter(methodCount: 2));

  /// Fires logging to the console.
  ///
  /// [message] is the message of the log.
  /// [logType] defines log severity. Different level will have different
  /// representation in the console
  void log(String message, {LogType logType = LogType.debug}) {
    if (isEnabled) {
      switch (logType) {
        case LogType.debug:
          _logger.d(message);
          break;
        case LogType.warning:
          _logger.w(message);
          break;
        case LogType.error:
          _logger.e(message);
          break;
      }
    }
  }
}
