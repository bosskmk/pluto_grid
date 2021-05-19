import 'dart:developer' as developer;

enum PlutoLogType {
  warning,
  exception,
  error,
  todo,
  info,
}

extension PlutoLogTypeExtension on PlutoLogType {
  String toShortString() {
    return toString().split('.').last;
  }
}

class PlutoLog {
  PlutoLog(
    String message, {
    PlutoLogType type = PlutoLogType.info,
    Object? error,
  }) {
    developer.log(
      '[${type.toShortString()}] $message',
      error: error,
    );
  }
}
