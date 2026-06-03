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
        scoringConfigPath: 'docs/backend/config/scoring_config.v1.json',
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
  });
}
