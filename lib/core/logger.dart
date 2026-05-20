import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final Logger appLogger = Logger(
  level: kDebugMode ? Level.debug : Level.warning,
  printer: PrettyPrinter(methodCount: 0, colors: false, printEmojis: false),
);
