import 'dart:convert';
import 'dart:io';

Map<String, dynamic> loadJson(String relativePath) {
  final file = File(relativePath);
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

Iterable<String> rankingFixturePaths({
  String fixturesDir = 'docs/backend/examples',
}) sync* {
  final examplesDir = Directory(fixturesDir);
  final files =
      examplesDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.contains('ranking_case.'))
          .map((file) => file.path)
          .toList()
        ..sort();
  yield* files;
}

Object? readPath(Map<String, dynamic> source, String path) {
  Object? current = source;
  for (final part in path.split('.')) {
    if (current is! Map<String, dynamic>) {
      return null;
    }
    current = current[part];
  }
  return current;
}

List<String> stringList(Object? raw) =>
    raw is List<dynamic> ? raw.whereType<String>().toList() : const [];

List<int> intList(Object? raw) =>
    raw is List<dynamic>
        ? raw.whereType<num>().map((value) => value.toInt()).toList()
        : const [];

Map<String, int> intMap(Map<String, dynamic> json) =>
    json.map((key, value) => MapEntry(key, (value as num).toInt()));
