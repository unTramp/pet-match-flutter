import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/backend_specs/mapping_validator.dart';

void main() {
  group('mapping validator', () {
    test('current questionnaire and mapping are valid', () {
      final report =
          MappingValidator(
            questionnairePath:
                'docs/backend/examples/questionnaire_definition.v1.json',
            mappingPath:
                'docs/backend/config/answer_to_profile_mapping.v1.json',
            scoringConfigPath: 'docs/backend/config/scoring_config.v1.json',
          ).validate();

      expect(report.errors, isEmpty);
    });

    test('detects broken references and invalid effects', () {
      final tempDir = Directory.systemTemp.createTempSync(
        'petwise_mapping_test',
      );
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final examplesDir = Directory('${tempDir.path}/examples')..createSync();
      final configDir = Directory('${tempDir.path}/config')..createSync();

      File(
        '${examplesDir.path}/questionnaire_definition.v1.json',
      ).writeAsStringSync('''
{
  "questionnaireVersion": 1,
  "questions": [
    {
      "id": "q1",
      "order": 1,
      "kind": "single_choice",
      "required": true,
      "title": "Q1",
      "description": null,
      "maxSelections": null,
      "options": [
        { "id": "a", "label": "A" },
        { "id": "b", "label": "B" }
      ]
    }
  ]
}
''');

      File('${configDir.path}/scoring_config.v1.json').writeAsStringSync('''
{
  "version": 1,
  "baseWeights": { "exerciseNeeds": 5 },
  "priorityWeightBoosts": { "quiet": { "noiseLevel": 2 } },
  "priorityTargetValues": { "quiet": { "noiseLevel": 1 } },
  "criticalCaps": [],
  "priorityBonusRules": [],
  "displayCap": 96
}
''');

      File(
        '${configDir.path}/answer_to_profile_mapping.v1.json',
      ).writeAsStringSync('''
{
  "questionnaireVersion": 2,
  "mappings": [
    {
      "questionId": "q1",
      "optionId": "a",
      "effects": [
        { "field": "unknownField", "operator": "set", "value": 6 }
      ]
    },
    {
      "questionId": "q1",
      "optionId": "missing_option",
      "effects": [
        { "field": "priorities", "operator": "append", "value": "not_in_scoring" }
      ]
    }
  ]
}
''');

      final report =
          MappingValidator(
            questionnairePath:
                '${examplesDir.path}/questionnaire_definition.v1.json',
            mappingPath: '${configDir.path}/answer_to_profile_mapping.v1.json',
            scoringConfigPath: '${configDir.path}/scoring_config.v1.json',
          ).validate();

      expect(report.isValid, isFalse);
      expect(
        report.errors.any((error) => error.contains('Version mismatch')),
        isTrue,
      );
      expect(
        report.errors.any(
          (error) => error.contains('unknown field unknownField'),
        ),
        isTrue,
      );
      expect(
        report.errors.any(
          (error) => error.contains('unknown optionId missing_option'),
        ),
        isTrue,
      );
      expect(
        report.errors.any((error) => error.contains('option b has no mapping')),
        isTrue,
      );
      expect(
        report.warnings.any(
          (warning) => warning.contains('not present in scoring config'),
        ),
        isTrue,
      );
    });
  });
}
