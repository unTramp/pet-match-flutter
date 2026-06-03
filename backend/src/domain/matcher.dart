import 'spec_json.dart';
import 'spec_models.dart';

class ReferenceMatcher implements MatchScoringEngine {
  ReferenceMatcher({required this.config, required this.breeds});

  final ScoringConfig config;
  final List<BreedFixture> breeds;

  @override
  List<MatchResult> rank(Map<String, dynamic> userProfile) {
    final results =
        breeds.map((breed) => _scoreBreed(userProfile, breed)).toList()
          ..sort((left, right) {
            final byPercent = right.matchPercent.compareTo(left.matchPercent);
            if (byPercent != 0) {
              return byPercent;
            }
            final byRawScore = right.rawScore.compareTo(left.rawScore);
            if (byRawScore != 0) {
              return byRawScore;
            }
            return left.breedId.compareTo(right.breedId);
          });
    return results;
  }

  MatchResult _scoreBreed(
    Map<String, dynamic> userProfile,
    BreedFixture breed,
  ) {
    final effectiveWeights = Map<String, int>.from(config.baseWeights);
    for (final priority in stringList(userProfile['priorities'])) {
      final boosts = config.priorityWeightBoosts[priority];
      if (boosts == null) {
        continue;
      }
      boosts.forEach((field, boost) {
        effectiveWeights[field] = (effectiveWeights[field] ?? 0) + boost;
      });
    }

    var weightedPenalty = 0.0;
    var maxPossiblePenalty = 0.0;

    for (final entry in effectiveWeights.entries) {
      final field = entry.key;
      final weight = entry.value.toDouble();

      if (field == 'size') {
        final sizePreference = intList(userProfile['sizePreference']);
        if (sizePreference.isEmpty) {
          continue;
        }
        final breedValue = breed.attributes[field]!;
        final distance = sizePreference
            .map((preferredSize) => (preferredSize - breedValue).abs())
            .reduce((left, right) => left < right ? left : right);
        weightedPenalty += distance * weight;
        maxPossiblePenalty += 4 * weight;
        continue;
      }

      final userValue = _resolveUserTargetValue(userProfile, field);
      final breedValue = breed.attributes[field];

      if (userValue == null || breedValue == null) {
        continue;
      }

      weightedPenalty += (userValue - breedValue).abs() * weight;
      maxPossiblePenalty += 4 * weight;
    }

    final baseScore =
        maxPossiblePenalty == 0
            ? 0.0
            : 1 - (weightedPenalty / maxPossiblePenalty);
    final priorityBonus = _calculatePriorityBonus(userProfile, breed);
    final rawScore = (baseScore + priorityBonus).clamp(0.0, 1.0);
    final rawPercent = (rawScore * 100).clamp(
      0.0,
      config.displayCap.toDouble(),
    );
    final cappedPercent = _applyCriticalCaps(
      userProfile: userProfile,
      breed: breed,
      rawPercent: rawPercent,
    );

    return MatchResult(
      breedId: breed.breedId,
      rawScore: rawScore,
      matchPercent: cappedPercent.round(),
    );
  }

  double _calculatePriorityBonus(
    Map<String, dynamic> userProfile,
    BreedFixture breed,
  ) {
    var bonus = 0.0;
    final priorities = stringList(userProfile['priorities']);
    for (final rule in config.priorityBonusRules) {
      if (!priorities.contains(rule.priority)) {
        continue;
      }
      final breedValue = breed.attributes[rule.breedField];
      if (breedValue == null) {
        continue;
      }
      final isMatch =
          (rule.gte != null && breedValue >= rule.gte!) ||
          (rule.lte != null && breedValue <= rule.lte!);
      if (isMatch) {
        bonus += rule.bonus;
      }
    }
    return bonus;
  }

  double _applyCriticalCaps({
    required Map<String, dynamic> userProfile,
    required BreedFixture breed,
    required double rawPercent,
  }) {
    var result = rawPercent;
    for (final capRule in config.criticalCaps) {
      final userValue = readPath(userProfile, capRule.userField);
      final breedValue = breed.attributes[capRule.breedField];
      if (breedValue == null) {
        continue;
      }

      var matches = true;
      if (capRule.equals != null) {
        matches = matches && userValue == capRule.equals;
      }
      if (capRule.userGte != null) {
        matches =
            matches && (userValue is num) && userValue >= capRule.userGte!;
      }
      if (capRule.breedLte != null) {
        matches = matches && breedValue <= capRule.breedLte!;
      }

      if (matches) {
        result = result > capRule.cap ? capRule.cap.toDouble() : result;
      }
    }
    return result > config.displayCap ? config.displayCap.toDouble() : result;
  }

  int? _resolveUserTargetValue(Map<String, dynamic> userProfile, String field) {
    final explicitValue = userProfile[field];
    if (explicitValue is num) {
      return explicitValue.toInt();
    }

    final targets = <int>[];
    for (final priority in stringList(userProfile['priorities'])) {
      final priorityTargets = config.priorityTargetValues[priority];
      final targetValue = priorityTargets?[field];
      if (targetValue != null) {
        targets.add(targetValue);
      }
    }

    if (targets.isEmpty) {
      return null;
    }
    final average =
        targets.reduce((left, right) => left + right) / targets.length;
    return average.round();
  }
}
