import 'spec_json.dart';

class MatchResult {
  const MatchResult({
    required this.breedId,
    required this.rawScore,
    required this.matchPercent,
    required this.triggeredCapReasons,
    required this.triggeredProfileReasons,
    required this.contributions,
  });

  final String breedId;
  final double rawScore;
  final int matchPercent;
  final List<String> triggeredCapReasons;
  final List<String> triggeredProfileReasons;
  final List<FieldContribution> contributions;
}

abstract interface class MatchScoringEngine {
  List<MatchResult> rank(Map<String, dynamic> userProfile);
}

class BreedFixture {
  const BreedFixture({
    required this.breedId,
    required this.petType,
    required this.attributes,
  });

  factory BreedFixture.fromJson(Map<String, dynamic> json) {
    return BreedFixture(
      breedId: json['breedId'] as String,
      petType: json['petType'] as String?,
      attributes: intMap(json['attributes'] as Map<String, dynamic>),
    );
  }

  final String breedId;
  final String? petType;
  final Map<String, int> attributes;
}

class RankingFixture {
  const RankingFixture({
    required this.fixtureId,
    required this.description,
    required this.scoringVersion,
    required this.inputUserProfile,
    required this.expected,
  });

  factory RankingFixture.fromJson(Map<String, dynamic> json) {
    return RankingFixture(
      fixtureId: json['fixtureId'] as String,
      description:
          json['description'] as String? ?? json['fixtureId'] as String,
      scoringVersion: (json['scoringVersion'] as num).toInt(),
      inputUserProfile: Map<String, dynamic>.from(
        json['inputUserProfile'] as Map,
      ),
      expected: FixtureExpectation.fromJson(
        json['expected'] as Map<String, dynamic>,
      ),
    );
  }

  final String fixtureId;
  final String description;
  final int scoringVersion;
  final Map<String, dynamic> inputUserProfile;
  final FixtureExpectation expected;
}

class FixtureExpectation {
  const FixtureExpectation({
    required this.topBreedId,
    required this.topMatchPercentMin,
    required this.topMatchPercentMax,
    required this.acceptableTop3,
    required this.mustRankAbove,
  });

  factory FixtureExpectation.fromJson(Map<String, dynamic> json) {
    final range = json['topMatchPercentRange'] as Map<String, dynamic>;
    return FixtureExpectation(
      topBreedId: json['topBreedId'] as String,
      topMatchPercentMin: (range['min'] as num).toInt(),
      topMatchPercentMax: (range['max'] as num).toInt(),
      acceptableTop3: stringList(json['acceptableTop3']),
      mustRankAbove:
          (json['mustRankAbove'] as List<dynamic>)
              .map((item) => RankingPair.fromJson(item as Map<String, dynamic>))
              .toList(),
    );
  }

  final String topBreedId;
  final int topMatchPercentMin;
  final int topMatchPercentMax;
  final List<String> acceptableTop3;
  final List<RankingPair> mustRankAbove;
}

class RankingPair {
  const RankingPair({required this.higher, required this.lower});

  factory RankingPair.fromJson(Map<String, dynamic> json) {
    return RankingPair(
      higher: json['higher'] as String,
      lower: json['lower'] as String,
    );
  }

  final String higher;
  final String lower;
}

class ScoringConfig {
  const ScoringConfig({
    required this.version,
    required this.baseWeights,
    required this.comparators,
    required this.fieldLabels,
    required this.capReasonMessages,
    required this.profileConflictCap,
    required this.profileConflictReasonCode,
    required this.profileConflictMessage,
    required this.priorityWeightBoosts,
    required this.priorityTargetValues,
    required this.criticalCaps,
    required this.priorityBonusRules,
    required this.displayCap,
  });

  factory ScoringConfig.fromJson(Map<String, dynamic> json) {
    return ScoringConfig(
      version: (json['version'] as num).toInt(),
      baseWeights: intMap(json['baseWeights'] as Map<String, dynamic>),
      comparators: (json['comparators'] as Map<String, dynamic>? ?? const {})
          .map((key, value) => MapEntry(key, value as String)),
      fieldLabels: (json['fieldLabels'] as Map<String, dynamic>? ?? const {})
          .map((key, value) => MapEntry(key, value as String)),
      capReasonMessages:
          (json['capReasonMessages'] as Map<String, dynamic>? ?? const {}).map(
            (key, value) => MapEntry(key, value as String),
          ),
      profileConflictCap: (json['profileConflictCap'] as num?)?.toInt() ?? 88,
      profileConflictReasonCode:
          json['profileConflictReasonCode'] as String? ??
          'contradictory_answers',
      profileConflictMessage:
          json['profileConflictMessage'] as String? ??
          'Some answers conflict with each other.',
      priorityWeightBoosts:
          (json['priorityWeightBoosts'] as Map<String, dynamic>).map(
            (key, value) =>
                MapEntry(key, intMap(value as Map<String, dynamic>)),
          ),
      priorityTargetValues:
          (json['priorityTargetValues'] as Map<String, dynamic>).map(
            (key, value) =>
                MapEntry(key, intMap(value as Map<String, dynamic>)),
          ),
      criticalCaps:
          (json['criticalCaps'] as List<dynamic>)
              .map(
                (item) =>
                    CriticalCapRule.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      priorityBonusRules:
          (json['priorityBonusRules'] as List<dynamic>)
              .map(
                (item) =>
                    PriorityBonusRule.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      displayCap: (json['displayCap'] as num).toInt(),
    );
  }

  final int version;
  final Map<String, int> baseWeights;
  final Map<String, String> comparators;
  final Map<String, String> fieldLabels;
  final Map<String, String> capReasonMessages;
  final int profileConflictCap;
  final String profileConflictReasonCode;
  final String profileConflictMessage;
  final Map<String, Map<String, int>> priorityWeightBoosts;
  final Map<String, Map<String, int>> priorityTargetValues;
  final List<CriticalCapRule> criticalCaps;
  final List<PriorityBonusRule> priorityBonusRules;
  final int displayCap;
}

class CriticalCapRule {
  const CriticalCapRule({
    required this.userField,
    required this.breedField,
    required this.cap,
    required this.reason,
    this.equals,
    this.userGte,
    this.breedLte,
  });

  factory CriticalCapRule.fromJson(Map<String, dynamic> json) {
    final when = json['when'] as Map<String, dynamic>;
    return CriticalCapRule(
      userField: when['userField'] as String,
      breedField: when['breedField'] as String,
      cap: (json['cap'] as num).toInt(),
      reason: json['reason'] as String? ?? 'unspecified_cap_reason',
      equals: when['equals'],
      userGte: (when['gte'] as num?)?.toInt(),
      breedLte: (when['lte'] as num?)?.toInt(),
    );
  }

  final String userField;
  final String breedField;
  final int cap;
  final String reason;
  final Object? equals;
  final int? userGte;
  final int? breedLte;
}

class FieldContribution {
  const FieldContribution({
    required this.field,
    required this.penalty,
    required this.weight,
    required this.maxPenalty,
  });

  final String field;
  final double penalty;
  final double weight;
  final double maxPenalty;

  double get weightedPenalty => penalty * weight;
}

class PriorityBonusRule {
  const PriorityBonusRule({
    required this.priority,
    required this.breedField,
    required this.bonus,
    this.gte,
    this.lte,
  });

  factory PriorityBonusRule.fromJson(Map<String, dynamic> json) {
    return PriorityBonusRule(
      priority: json['priority'] as String,
      breedField: json['breedField'] as String,
      bonus: (json['bonus'] as num).toDouble(),
      gte: (json['gte'] as num?)?.toInt(),
      lte: (json['lte'] as num?)?.toInt(),
    );
  }

  final String priority;
  final String breedField;
  final double bonus;
  final int? gte;
  final int? lte;
}
