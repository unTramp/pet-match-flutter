import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/backend_specs/catalog_validator.dart';

void main() {
  group('catalog validator', () {
    test('current backend catalog is valid', () {
      final report =
          CatalogValidator(
            catalogPath: 'docs/backend/examples/catalog.v1.json',
            scoringConfigPath: 'docs/backend/config/scoring_config.v2.json',
          ).validate();

      expect(report.errors, isEmpty);
    });

    test('detects broken breed attributes and missing file', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'petwise_catalog_test',
      );
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final examplesDir = Directory('${tempDir.path}/examples')..createSync();
      final configDir = Directory('${tempDir.path}/config')..createSync();

      File('${configDir.path}/scoring_config.v2.json').writeAsStringSync('''
{
  "version": 1,
  "baseWeights": { "size": 4, "exerciseNeeds": 5, "apartmentSuitability": 5 },
  "priorityWeightBoosts": {},
  "priorityTargetValues": {},
  "criticalCaps": [],
  "priorityBonusRules": [],
  "displayCap": 96
}
''');

      File('${examplesDir.path}/catalog.v1.json').writeAsStringSync('''
{
  "catalogVersion": 1,
  "petType": "dog",
  "breeds": [
    { "breedId": "broken_breed", "file": "breed.broken_breed.json" },
    { "breedId": "missing_breed", "file": "breed.missing_breed.json" }
  ]
}
''');

      File('${examplesDir.path}/breed.broken_breed.json').writeAsStringSync('''
{
  "breedId": "broken_breed",
  "petType": "dog",
  "name": "Broken Breed",
  "attributes": {
    "size": 6,
    "exerciseNeeds": 3
  },
  "flags": {
    "isVocal": true,
    "isHighPreyDrive": false,
    "isSensitive": false,
    "isEscapeProne": false,
    "isSuitableForFirstTimeOwners": true
  },
  "content": {
    "summaryShort": "",
    "strengths": [],
    "watchouts": ["x"],
    "adaptationTips": ["y"]
  },
  "quality": {
    "confidenceScore": 1.2,
    "sourceCount": 0,
    "sourceNotes": [],
    "needsReview": false,
    "version": 1
  }
}
''');

      final report =
          CatalogValidator(
            catalogPath: '${examplesDir.path}/catalog.v1.json',
            scoringConfigPath: '${configDir.path}/scoring_config.v2.json',
          ).validate();

      expect(report.isValid, isFalse);
      expect(
        report.errors.any(
          (error) =>
              error.contains('missing required attribute apartmentSuitability'),
        ),
        isTrue,
      );
      expect(
        report.errors.any(
          (error) => error.contains('out-of-range attribute size=6'),
        ),
        isTrue,
      );
      expect(
        report.errors.any(
          (error) => error.contains('Breed file not found for missing_breed'),
        ),
        isTrue,
      );
    });
  });
}
