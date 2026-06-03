import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/backend_specs/profile_builder.dart';
import '../../tool/backend_specs/reference_matcher.dart';

void main() {
  group('backend specs end-to-end flow', () {
    late ReferenceProfileBuilder profileBuilder;
    late ReferenceSpecBundle bundle;
    late ReferenceMatcher matcher;

    setUpAll(() {
      profileBuilder = ReferenceProfileBuilder(
        questionnairePath:
            'docs/backend/examples/questionnaire_definition.v1.json',
        mappingPath: 'docs/backend/config/answer_to_profile_mapping.v1.json',
        scoringConfigPath: 'docs/backend/config/scoring_config.v2.json',
      );
      bundle = ReferenceSpecBundle.load();
      matcher = ReferenceMatcher(
        config: bundle.config,
        breeds: bundle.breeds.values.toList(),
      );
    });

    test('apartment_quiet_beginner answers -> profile -> ranking', () {
      final payload = _loadJson(
        'docs/backend/examples/answers.apartment_quiet_beginner.json',
      );
      final profile = profileBuilder.buildFromJson(payload).userProfile;
      final results = matcher.rank(profile);

      expect(results.first.breedId, 'whippet');
      expect(results.first.matchPercent, inInclusiveRange(82, 92));
    });

    test('active_trainable answers -> profile -> ranking', () {
      final payload = _loadJson(
        'docs/backend/examples/answers.active_trainable.json',
      );
      final profile = profileBuilder.buildFromJson(payload).userProfile;
      final results = matcher.rank(profile);

      expect(results.first.breedId, 'border_collie');
      expect(results.first.matchPercent, inInclusiveRange(84, 96));
      expect(
        results.take(3).map((result) => result.breedId),
        containsAll(<String>['australian_shepherd', 'german_shepherd']),
      );
    });

    test('family_friendly answers -> profile -> ranking', () {
      final payload = _loadJson(
        'docs/backend/examples/answers.family_friendly.json',
      );
      final profile = profileBuilder.buildFromJson(payload).userProfile;
      final results = matcher.rank(profile);

      expect(results.first.breedId, 'labrador_retriever');
      expect(results.first.matchPercent, inInclusiveRange(84, 96));
      expect(
        results.take(3).map((result) => result.breedId),
        contains('boxer'),
      );
    });

    test(
      'matcher resolves priority target values without builder hydration',
      () {
        final payload = _loadJson(
          'docs/backend/examples/answers.apartment_quiet_beginner.json',
        );
        final rawProfile = profileBuilder.buildFromJson(payload).userProfile;
        final explicitlyHydratedProfile = <String, dynamic>{
          ...rawProfile,
          'noiseLevel': 1,
          'temperamentCalm': 5,
        };

        final rawResults = matcher.rank(rawProfile);
        final hydratedResults = matcher.rank(explicitlyHydratedProfile);

        expect(
          rawResults.take(5).map((result) => result.breedId).toList(),
          hydratedResults.take(5).map((result) => result.breedId).toList(),
        );
        expect(
          rawResults.take(5).map((result) => result.matchPercent).toList(),
          hydratedResults.take(5).map((result) => result.matchPercent).toList(),
        );
      },
    );

    test('constraint capping alone does not apply confidence cap', () {
      final normalizedProfile = <String, dynamic>{
        'petType': 'dog',
        'apartmentSuitability': 5,
        'exerciseNeeds': 3,
        'beginnerFriendly': 5,
        'priorities': <String>['apartment_friendly', 'quiet'],
        'criticalContext': <String, dynamic>{
          'livesInApartment': true,
          'hasYoungChildren': false,
          'hasOtherPets': false,
        },
        'profileDiagnostics': <String, dynamic>{
          'hasConflicts': true,
          'conflicts': <Map<String, dynamic>>[
            <String, dynamic>{
              'field': 'exerciseNeeds',
              'code': 'value_capped_by_constraint',
              'message':
                  'Поле "Активность" было ограничено другим ответом пользователя.',
            },
          ],
        },
      };

      final cleanProfile = <String, dynamic>{...normalizedProfile}
        ..remove('profileDiagnostics');

      final normalizedResults = matcher.rank(normalizedProfile);
      final cleanResults = matcher.rank(cleanProfile);

      expect(normalizedResults.first.triggeredProfileReasons, isEmpty);
      expect(
        normalizedResults.first.matchPercent,
        cleanResults.first.matchPercent,
      );
    });

    test('true contradictions still apply confidence cap', () {
      final conflictedProfile = <String, dynamic>{
        'petType': 'dog',
        'apartmentSuitability': 5,
        'exerciseNeeds': 3,
        'beginnerFriendly': 5,
        'sizePreference': <int>[],
        'priorities': <String>['apartment_friendly', 'quiet'],
        'criticalContext': <String, dynamic>{
          'livesInApartment': true,
          'hasYoungChildren': false,
          'hasOtherPets': false,
        },
        'profileDiagnostics': <String, dynamic>{
          'hasConflicts': true,
          'conflicts': <Map<String, dynamic>>[
            <String, dynamic>{
              'field': 'sizePreference',
              'code': 'no_allowed_values_overlap',
              'message':
                  'Ответы сузили допустимые значения для поля "Размер" до пустого набора.',
            },
          ],
        },
      };

      final cleanProfile = <String, dynamic>{...conflictedProfile}
        ..remove('profileDiagnostics');

      final conflictedResults = matcher.rank(conflictedProfile);
      final cleanResults = matcher.rank(cleanProfile);

      expect(
        conflictedResults.first.triggeredProfileReasons,
        contains(bundle.config.profileConflictReasonCode),
      );
      expect(
        conflictedResults.first.matchPercent,
        lessThanOrEqualTo(bundle.config.profileConflictCap),
      );
      expect(
        conflictedResults.first.matchPercent,
        lessThanOrEqualTo(cleanResults.first.matchPercent),
      );
    });
  });
}

Map<String, dynamic> _loadJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
