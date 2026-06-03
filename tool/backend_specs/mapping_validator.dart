import 'reference_matcher.dart';

const Set<String> _supportedQuestionKinds = <String>{
  'single_choice',
  'multi_choice',
};

const Set<String> _supportedOperators = <String>{
  'set',
  'allow',
  'cap_max',
  'cap_min',
  'append',
};

const Set<String> _knownProfileFields = <String>{
  'petType',
  'sizePreference',
  'exerciseNeeds',
  'apartmentSuitability',
  'aloneTolerance',
  'goodWithChildren',
  'goodWithOtherPets',
  'groomingNeeds',
  'sheddingLevel',
  'beginnerFriendly',
  'maintenanceCost',
  'noiseLevel',
  'priorities',
};

const Set<String> _knownContextFields = <String>{
  'criticalContext.livesInApartment',
  'criticalContext.hasYoungChildren',
  'criticalContext.hasOtherPets',
};

const Set<String> _uxOnlyQuestions = <String>{'refinement_gate'};

class MappingValidationReport {
  const MappingValidationReport({
    required this.questionnaireVersion,
    required this.mappingVersion,
    required this.questionCount,
    required this.mappingCount,
    required this.errors,
    required this.warnings,
  });

  final int questionnaireVersion;
  final int mappingVersion;
  final int questionCount;
  final int mappingCount;
  final List<String> errors;
  final List<String> warnings;

  bool get isValid => errors.isEmpty;
}

class MappingValidator {
  MappingValidator({
    required this.questionnairePath,
    required this.mappingPath,
    required this.scoringConfigPath,
  });

  final String questionnairePath;
  final String mappingPath;
  final String scoringConfigPath;

  MappingValidationReport validate() {
    final errors = <String>[];
    final warnings = <String>[];

    final questionnaire = loadJson(questionnairePath);
    final mapping = loadJson(mappingPath);
    final scoringConfig = ScoringConfig.fromJson(loadJson(scoringConfigPath));

    final questionnaireVersion =
        (questionnaire['questionnaireVersion'] as num?)?.toInt() ?? -1;
    final mappingVersion =
        (mapping['questionnaireVersion'] as num?)?.toInt() ?? -1;

    if (questionnaireVersion != mappingVersion) {
      errors.add(
        'Version mismatch: questionnaireVersion=$questionnaireVersion, mappingVersion=$mappingVersion',
      );
    }

    final questions = List<Map<String, dynamic>>.from(
      questionnaire['questions'] as List<dynamic>? ?? const [],
    );
    final mappings = List<Map<String, dynamic>>.from(
      mapping['mappings'] as List<dynamic>? ?? const [],
    );

    final questionsById = <String, _QuestionShape>{};
    final orders = <int>{};

    for (final rawQuestion in questions) {
      final question = _QuestionShape.fromJson(rawQuestion);
      if (!questionsById.containsKey(question.id)) {
        questionsById[question.id] = question;
      } else {
        errors.add('Duplicate question id: ${question.id}');
      }
      if (!orders.add(question.order)) {
        errors.add('Duplicate question order: ${question.order}');
      }
      if (!_supportedQuestionKinds.contains(question.kind)) {
        errors.add(
          'Unsupported question kind ${question.kind} for ${question.id}',
        );
      }

      final optionIds = <String>{};
      for (final option in question.options) {
        if (!optionIds.add(option.id)) {
          errors.add(
            'Duplicate option id ${option.id} in question ${question.id}',
          );
        }
      }

      if (question.kind == 'multi_choice') {
        if (question.maxSelections == null || question.maxSelections! < 1) {
          errors.add(
            'Question ${question.id} must define maxSelections for multi_choice',
          );
        }
      }
      if (question.kind == 'single_choice' && question.maxSelections != null) {
        warnings.add(
          'Question ${question.id} is single_choice but defines maxSelections=${question.maxSelections}',
        );
      }
    }

    final scoringPriorities = <String>{
      ...scoringConfig.priorityWeightBoosts.keys,
      ...scoringConfig.priorityTargetValues.keys,
      ...scoringConfig.priorityBonusRules.map((rule) => rule.priority),
    };

    final mappingKeys = <String>{};
    final mappedOptionsByQuestion = <String, Set<String>>{};

    for (final rawMapping in mappings) {
      final entry = _MappingEntry.fromJson(rawMapping);
      final key = '${entry.questionId}::${entry.optionId}';
      if (!mappingKeys.add(key)) {
        errors.add('Duplicate mapping entry for $key');
      }

      final question = questionsById[entry.questionId];
      if (question == null) {
        errors.add('Mapping references unknown questionId ${entry.questionId}');
        continue;
      }
      if (!question.optionIds.contains(entry.optionId)) {
        errors.add(
          'Mapping references unknown optionId ${entry.optionId} for question ${entry.questionId}',
        );
      }

      mappedOptionsByQuestion
          .putIfAbsent(entry.questionId, () => <String>{})
          .add(entry.optionId);

      if (entry.effects.isEmpty) {
        errors.add('Mapping $key must contain at least one effect');
      }

      for (final effect in entry.effects) {
        _validateEffect(
          questionId: entry.questionId,
          optionId: entry.optionId,
          effect: effect,
          scoringPriorities: scoringPriorities,
          errors: errors,
          warnings: warnings,
        );
      }
    }

    for (final question in questionsById.values) {
      final mappedOptions =
          mappedOptionsByQuestion[question.id] ?? const <String>{};
      final expectedOptions = question.optionIds;

      if (_uxOnlyQuestions.contains(question.id)) {
        if (mappedOptions.isNotEmpty) {
          warnings.add(
            'UX-only question ${question.id} has mappings, expected none',
          );
        }
        continue;
      }

      for (final optionId in expectedOptions) {
        if (!mappedOptions.contains(optionId)) {
          errors.add('Question ${question.id} option $optionId has no mapping');
        }
      }

      for (final mappedOption in mappedOptions) {
        if (!expectedOptions.contains(mappedOption)) {
          errors.add(
            'Question ${question.id} has mapping for unknown option $mappedOption',
          );
        }
      }
    }

    return MappingValidationReport(
      questionnaireVersion: questionnaireVersion,
      mappingVersion: mappingVersion,
      questionCount: questions.length,
      mappingCount: mappings.length,
      errors: errors,
      warnings: warnings,
    );
  }

  void _validateEffect({
    required String questionId,
    required String optionId,
    required _EffectShape effect,
    required Set<String> scoringPriorities,
    required List<String> errors,
    required List<String> warnings,
  }) {
    final key = '$questionId::$optionId';

    if (!_supportedOperators.contains(effect.operator)) {
      errors.add('Mapping $key uses unsupported operator ${effect.operator}');
      return;
    }

    final isKnownField =
        _knownProfileFields.contains(effect.field) ||
        _knownContextFields.contains(effect.field);
    if (!isKnownField) {
      errors.add('Mapping $key uses unknown field ${effect.field}');
    }

    switch (effect.operator) {
      case 'set':
        _validateSetEffect(key: key, effect: effect, errors: errors);
      case 'allow':
        _validateAllowEffect(key: key, effect: effect, errors: errors);
      case 'cap_max':
      case 'cap_min':
        _validateCapEffect(key: key, effect: effect, errors: errors);
      case 'append':
        _validateAppendEffect(
          key: key,
          effect: effect,
          scoringPriorities: scoringPriorities,
          errors: errors,
          warnings: warnings,
        );
    }
  }

  void _validateSetEffect({
    required String key,
    required _EffectShape effect,
    required List<String> errors,
  }) {
    if (effect.field == 'petType') {
      if (effect.value is! String) {
        errors.add('Mapping $key must set petType to a string');
      }
      return;
    }

    if (_knownContextFields.contains(effect.field)) {
      if (effect.value is! bool) {
        errors.add('Mapping $key must set ${effect.field} to a bool');
      }
      return;
    }

    if (effect.field == 'goodWithChildren' ||
        effect.field == 'goodWithOtherPets') {
      if (effect.value != null && !_isScaleValue(effect.value)) {
        errors.add('Mapping $key must set ${effect.field} to null or 1..5');
      }
      return;
    }

    if (effect.field == 'priorities' || effect.field == 'sizePreference') {
      errors.add('Mapping $key should not use set for ${effect.field}');
      return;
    }

    if (!_isScaleValue(effect.value)) {
      errors.add('Mapping $key must set ${effect.field} to a 1..5 value');
    }
  }

  void _validateAllowEffect({
    required String key,
    required _EffectShape effect,
    required List<String> errors,
  }) {
    if (effect.field != 'sizePreference') {
      errors.add(
        'Mapping $key uses allow for unsupported field ${effect.field}',
      );
    }
    if (effect.value is! List) {
      errors.add('Mapping $key must use a list for allow');
      return;
    }
    final values = List<dynamic>.from(effect.value as List);
    if (values.isEmpty) {
      errors.add('Mapping $key must use a non-empty list for allow');
    }
    for (final value in values) {
      if (!_isScaleValue(value)) {
        errors.add('Mapping $key has invalid allow value $value');
      }
    }
  }

  void _validateCapEffect({
    required String key,
    required _EffectShape effect,
    required List<String> errors,
  }) {
    if (!_isScaleValue(effect.value)) {
      errors.add('Mapping $key must use a 1..5 value for ${effect.operator}');
    }
  }

  void _validateAppendEffect({
    required String key,
    required _EffectShape effect,
    required Set<String> scoringPriorities,
    required List<String> errors,
    required List<String> warnings,
  }) {
    if (effect.field != 'priorities') {
      errors.add(
        'Mapping $key uses append for unsupported field ${effect.field}',
      );
      return;
    }
    if (effect.value is! String) {
      errors.add('Mapping $key must append a string priority value');
      return;
    }
    if (!scoringPriorities.contains(effect.value)) {
      warnings.add(
        'Mapping $key appends priority ${effect.value} which is not present in scoring config',
      );
    }
  }
}

bool _isScaleValue(Object? value) {
  if (value is! num) {
    return false;
  }
  final intValue = value.toInt();
  return value == intValue && intValue >= 1 && intValue <= 5;
}

class _QuestionShape {
  const _QuestionShape({
    required this.id,
    required this.order,
    required this.kind,
    required this.maxSelections,
    required this.options,
  });

  factory _QuestionShape.fromJson(Map<String, dynamic> json) {
    return _QuestionShape(
      id: json['id'] as String,
      order: (json['order'] as num).toInt(),
      kind: json['kind'] as String,
      maxSelections: (json['maxSelections'] as num?)?.toInt(),
      options:
          (json['options'] as List<dynamic>)
              .map(
                (item) => _OptionShape.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  final String id;
  final int order;
  final String kind;
  final int? maxSelections;
  final List<_OptionShape> options;

  Set<String> get optionIds => options.map((option) => option.id).toSet();
}

class _OptionShape {
  const _OptionShape({required this.id});

  factory _OptionShape.fromJson(Map<String, dynamic> json) {
    return _OptionShape(id: json['id'] as String);
  }

  final String id;
}

class _MappingEntry {
  const _MappingEntry({
    required this.questionId,
    required this.optionId,
    required this.effects,
  });

  factory _MappingEntry.fromJson(Map<String, dynamic> json) {
    return _MappingEntry(
      questionId: json['questionId'] as String,
      optionId: json['optionId'] as String,
      effects:
          (json['effects'] as List<dynamic>)
              .map(
                (item) => _EffectShape.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  final String questionId;
  final String optionId;
  final List<_EffectShape> effects;
}

class _EffectShape {
  const _EffectShape({
    required this.field,
    required this.operator,
    required this.value,
  });

  factory _EffectShape.fromJson(Map<String, dynamic> json) {
    return _EffectShape(
      field: json['field'] as String,
      operator: json['operator'] as String,
      value: json['value'],
    );
  }

  final String field;
  final String operator;
  final Object? value;
}
