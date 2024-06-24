import 'package:firestore_helper/src/logging_service.dart';
import 'package:firestore_helper/src/log_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../utils/mocked_classes.mocks.dart';

void main() {
  final MockLogger mockLogger = MockLogger();

  late LoggingService loggingService;

  setUp(() {
    loggingService = LoggingService(true, logger: mockLogger);
  });

  tearDown(() {
    reset(mockLogger);
  });

  test('LoggingService', () {
    loggingService = LoggingService(false);

    expect(loggingService.isEnabled, isFalse);
  });

  group('log', () {
    test('${LogType.debug}', () {
      loggingService.log('message');
      if (loggingService.isEnabled) {
        verify(mockLogger.d('message')).called(1);
      } else {
        verifyNever(mockLogger.d('message')).called(1);
      }
    });

    test('${LogType.debug}', () {
      loggingService.log('message', logType: LogType.debug);
      if (loggingService.isEnabled) {
        verify(mockLogger.d('message')).called(1);
      } else {
        verifyNever(mockLogger.d('message'));
      }
    });

    test('${LogType.warning}', () {
      loggingService.log('message', logType: LogType.warning);
      if (loggingService.isEnabled) {
        verify(mockLogger.w('message')).called(1);
      } else {
        verifyNever(mockLogger.w('message'));
      }
    });

    test('${LogType.error}', () {
      loggingService.log('message', logType: LogType.error);
      if (loggingService.isEnabled) {
        verify(mockLogger.e('message')).called(1);
      } else {
        verifyNever(mockLogger.e('message'));
      }
    });
  });
}
