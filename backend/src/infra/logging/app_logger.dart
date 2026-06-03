import 'dart:convert';
import 'dart:io';

import '../../config/runtime_config.dart';

class AppLogger {
  AppLogger({required this.level, required this.serviceName});

  final LogLevel level;
  final String serviceName;

  void debug(String event, {Map<String, Object?> fields = const {}}) {
    _log(LogLevel.debug, event, fields: fields);
  }

  void info(String event, {Map<String, Object?> fields = const {}}) {
    _log(LogLevel.info, event, fields: fields);
  }

  void warn(String event, {Map<String, Object?> fields = const {}}) {
    _log(LogLevel.warn, event, fields: fields);
  }

  void error(
    String event, {
    Map<String, Object?> fields = const {},
    Object? error,
    StackTrace? stackTrace,
  }) {
    final payload = <String, Object?>{
      ...fields,
      if (error != null) 'error': '$error',
      if (stackTrace != null) 'stackTrace': '$stackTrace',
    };
    _log(LogLevel.error, event, fields: payload, sink: stderr);
  }

  void _log(
    LogLevel messageLevel,
    String event, {
    required Map<String, Object?> fields,
    IOSink? sink,
  }) {
    if (messageLevel.index < level.index) {
      return;
    }

    final record = <String, Object?>{
      'ts': DateTime.now().toUtc().toIso8601String(),
      'level': messageLevel.name,
      'service': serviceName,
      'event': event,
      ...fields,
    };

    (sink ?? stdout).writeln(jsonEncode(_sanitize(record)));
  }

  Object? _sanitize(Object? value) {
    if (value == null || value is num || value is bool || value is String) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, nestedValue) => MapEntry('$key', _sanitize(nestedValue)),
      );
    }
    if (value is Iterable) {
      return value.map(_sanitize).toList();
    }
    return '$value';
  }
}
