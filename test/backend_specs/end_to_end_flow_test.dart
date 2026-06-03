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
        scoringConfigPath: 'docs/backend/config/scoring_config.v1.json',
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
        contains('labrador_retriever'),
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
        contains('cavalier_king_charles_spaniel'),
      );
    });
  });
}

Map<String, dynamic> _loadJson(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
