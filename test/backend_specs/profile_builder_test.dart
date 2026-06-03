import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/backend_specs/profile_builder.dart';

void main() {
  group('reference profile builder', () {
    late ReferenceProfileBuilder builder;

    setUpAll(() {
      builder = ReferenceProfileBuilder(
        questionnairePath:
            'docs/backend/examples/questionnaire_definition.v1.json',
        mappingPath: 'docs/backend/config/answer_to_profile_mapping.v1.json',
        scoringConfigPath: 'docs/backend/config/scoring_config.v2.json',
      );
    });

    test('builds expected profile from example answers', () {
      final payload =
          jsonDecode(
                File(
                  'docs/backend/examples/answers.apartment_quiet_beginner.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final expected =
          jsonDecode(
                File(
                  'docs/backend/examples/profile_from_answers.apartment_quiet_beginner.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;

      final result = builder.buildFromJson(payload);

      expect(result.questionnaireVersion, 1);
      expect(result.userProfile, expected);
    });

    test('throws on duplicate single-choice answers', () {
      expect(
        () => builder.build(
          questionnaireVersion: 1,
          answers: const <QuestionnaireAnswer>[
            QuestionnaireAnswer(questionId: 'pet_type', optionId: 'dog'),
            QuestionnaireAnswer(questionId: 'pet_type', optionId: 'cat'),
            QuestionnaireAnswer(questionId: 'home_type', optionId: 'apartment'),
            QuestionnaireAnswer(
              questionId: 'daily_activity',
              optionId: '30_60',
            ),
            QuestionnaireAnswer(questionId: 'alone_time', optionId: '4_8'),
            QuestionnaireAnswer(questionId: 'children', optionId: 'no'),
            QuestionnaireAnswer(questionId: 'other_pets', optionId: 'cat'),
            QuestionnaireAnswer(
              questionId: 'grooming_tolerance',
              optionId: 'minimal',
            ),
            QuestionnaireAnswer(
              questionId: 'shedding_tolerance',
              optionId: 'hate_it',
            ),
          ],
        ),
        throwsA(
          isA<ProfileBuildValidationError>().having(
            (error) => error.messages.join(' | '),
            'messages',
            contains('accepts only one answer'),
          ),
        ),
      );
    });

    test('does not force petType when user selects unknown', () {
      final result = builder.build(
        questionnaireVersion: 1,
        answers: const <QuestionnaireAnswer>[
          QuestionnaireAnswer(questionId: 'pet_type', optionId: 'unknown'),
          QuestionnaireAnswer(questionId: 'home_type', optionId: 'apartment'),
          QuestionnaireAnswer(questionId: 'daily_activity', optionId: '30_60'),
          QuestionnaireAnswer(questionId: 'alone_time', optionId: '4_8'),
          QuestionnaireAnswer(questionId: 'children', optionId: 'no'),
          QuestionnaireAnswer(questionId: 'other_pets', optionId: 'none'),
          QuestionnaireAnswer(
            questionId: 'grooming_tolerance',
            optionId: 'minimal',
          ),
          QuestionnaireAnswer(
            questionId: 'shedding_tolerance',
            optionId: 'a_little_ok',
          ),
        ],
      );

      expect(result.userProfile.containsKey('petType'), isFalse);
    });

    test('records profile conflicts for contradictory constraints', () {
      final result = builder.build(
        questionnaireVersion: 1,
        answers: const <QuestionnaireAnswer>[
          QuestionnaireAnswer(questionId: 'pet_type', optionId: 'dog'),
          QuestionnaireAnswer(questionId: 'home_type', optionId: 'apartment'),
          QuestionnaireAnswer(
            questionId: 'daily_activity',
            optionId: '120_plus',
          ),
          QuestionnaireAnswer(questionId: 'alone_time', optionId: '4_8'),
          QuestionnaireAnswer(questionId: 'children', optionId: 'no'),
          QuestionnaireAnswer(questionId: 'other_pets', optionId: 'none'),
          QuestionnaireAnswer(
            questionId: 'grooming_tolerance',
            optionId: 'minimal',
          ),
          QuestionnaireAnswer(
            questionId: 'shedding_tolerance',
            optionId: 'a_little_ok',
          ),
          QuestionnaireAnswer(questionId: 'preferred_size', optionId: 'large'),
        ],
      );

      expect(result.userProfile['exerciseNeeds'], 3);
      expect(result.userProfile['sizePreference'], isEmpty);

      final diagnostics =
          result.userProfile['profileDiagnostics'] as Map<String, dynamic>;
      expect(diagnostics['hasConflicts'], isTrue);
      final conflicts = diagnostics['conflicts'] as List<dynamic>;
      expect(
        conflicts.map((item) => (item as Map<String, dynamic>)['code']),
        contains('value_capped_by_constraint'),
      );
      expect(
        conflicts.map((item) => (item as Map<String, dynamic>)['code']),
        contains('no_allowed_values_overlap'),
      );
    });
  });
}
