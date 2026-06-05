import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('backend example JSON fixtures', () {
    test('all docs/backend/examples files are valid JSON', () {
      final examplesDir = Directory('docs/backend/examples');
      expect(examplesDir.existsSync(), isTrue);

      final jsonFiles =
          examplesDir
              .listSync()
              .whereType<File>()
              .where((file) => file.path.endsWith('.json'))
              .toList()
            ..sort((left, right) => left.path.compareTo(right.path));

      expect(jsonFiles, isNotEmpty);

      for (final file in jsonFiles) {
        final text = file.readAsStringSync();
        dynamic decoded;

        expect(
          () => decoded = jsonDecode(text),
          returnsNormally,
          reason: 'Expected valid JSON in ${file.path}',
        );
        expect(
          decoded,
          isA<Map<String, dynamic>>(),
          reason: 'Expected top-level JSON object in ${file.path}',
        );
      }
    });
  });

  group('backend import candidate JSON fixtures', () {
    test('all docs/backend/import_candidates JSON files are valid JSON', () {
      final candidatesDir = Directory('docs/backend/import_candidates');
      expect(candidatesDir.existsSync(), isTrue);

      final jsonFiles =
          candidatesDir
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.json'))
              .toList()
            ..sort((left, right) => left.path.compareTo(right.path));

      expect(jsonFiles, isNotEmpty);

      for (final file in jsonFiles) {
        final text = file.readAsStringSync();
        dynamic decoded;

        expect(
          () => decoded = jsonDecode(text),
          returnsNormally,
          reason: 'Expected valid JSON in ${file.path}',
        );
        expect(
          decoded,
          isA<Map<String, dynamic>>(),
          reason: 'Expected top-level JSON object in ${file.path}',
        );
      }
    });
  });
}
