import 'spec_json.dart';
import 'spec_models.dart';

class QuestionnaireAnswer {
  const QuestionnaireAnswer({required this.questionId, required this.optionId});

  factory QuestionnaireAnswer.fromJson(Map<String, dynamic> json) {
    return QuestionnaireAnswer(
      questionId: json['questionId'] as String,
      optionId: json['optionId'] as String,
    );
  }

  final String questionId;
  final String optionId;
}

class ProfileBuildResult {
  const ProfileBuildResult({
    required this.questionnaireVersion,
    required this.userProfile,
  });

  final int questionnaireVersion;
  final Map<String, dynamic> userProfile;
}

class ProfileBuildValidationError implements Exception {
  const ProfileBuildValidationError(this.messages);

  final List<String> messages;

  @override
  String toString() => 'ProfileBuildValidationError(${messages.join('; ')})';
}

class ProfileBuilderDefinition {
  const ProfileBuilderDefinition({
    required this.questionnaire,
    required this.mapping,
    required this.scoringConfig,
  });

  factory ProfileBuilderDefinition.fromJson({
    required Map<String, dynamic> questionnaireJson,
    required Map<String, dynamic> mappingJson,
    required Map<String, dynamic> scoringConfigJson,
  }) {
    return ProfileBuilderDefinition(
      questionnaire: _QuestionnaireDefinition.fromJson(questionnaireJson),
      mapping: _MappingDefinition.fromJson(mappingJson),
      scoringConfig: ScoringConfig.fromJson(scoringConfigJson),
    );
  }

  final _QuestionnaireDefinition questionnaire;
  final _MappingDefinition mapping;
  final ScoringConfig scoringConfig;
}

class QuestionnaireProfileBuilder {
  QuestionnaireProfileBuilder(this._definition);

  final ProfileBuilderDefinition _definition;

  ProfileBuildResult buildFromJson(Map<String, dynamic> payload) {
    final version = (payload['questionnaireVersion'] as num?)?.toInt() ?? -1;
    final answers =
        (payload['answers'] as List<dynamic>? ?? const [])
            .map(
              (item) =>
                  QuestionnaireAnswer.fromJson(item as Map<String, dynamic>),
            )
            .toList();
    return build(questionnaireVersion: version, answers: answers);
  }

  ProfileBuildResult build({
    required int questionnaireVersion,
    required List<QuestionnaireAnswer> answers,
  }) {
    final errors = _validateAnswers(
      questionnaireVersion: questionnaireVersion,
      answers: answers,
    );
    if (errors.isNotEmpty) {
      throw ProfileBuildValidationError(errors);
    }

    final state = _ProfileState();

    for (final answer in answers) {
      final effects =
          _definition.mapping.effectsByQuestionAndOption[answer
              .questionId]?[answer.optionId] ??
          const <_EffectDefinition>[];
      for (final effect in effects) {
        _applyEffect(state, effect);
      }
    }

    final profile = state.toUserProfile();
    _hydratePriorityTargetValues(profile);

    return ProfileBuildResult(
      questionnaireVersion: _definition.questionnaire.version,
      userProfile: profile,
    );
  }

  List<String> _validateAnswers({
    required int questionnaireVersion,
    required List<QuestionnaireAnswer> answers,
  }) {
    final errors = <String>[];

    if (questionnaireVersion != _definition.questionnaire.version) {
      errors.add(
        'Questionnaire version mismatch: payload=$questionnaireVersion, expected=${_definition.questionnaire.version}',
      );
    }

    final answersByQuestion = <String, List<QuestionnaireAnswer>>{};

    for (final answer in answers) {
      final question =
          _definition.questionnaire.questionsById[answer.questionId];
      if (question == null) {
        errors.add('Unknown questionId ${answer.questionId}');
        continue;
      }
      if (!question.optionIds.contains(answer.optionId)) {
        errors.add(
          'Unknown optionId ${answer.optionId} for question ${answer.questionId}',
        );
      }
      answersByQuestion
          .putIfAbsent(answer.questionId, () => <QuestionnaireAnswer>[])
          .add(answer);
    }

    for (final question in _definition.questionnaire.questionsById.values) {
      final questionAnswers =
          answersByQuestion[question.id] ?? const <QuestionnaireAnswer>[];
      if (question.required && questionAnswers.isEmpty) {
        errors.add('Missing required answer for question ${question.id}');
      }
      if (question.kind == 'single_choice' && questionAnswers.length > 1) {
        errors.add('Question ${question.id} accepts only one answer');
      }
      if (question.kind == 'multi_choice' &&
          question.maxSelections != null &&
          questionAnswers.length > question.maxSelections!) {
        errors.add(
          'Question ${question.id} exceeds maxSelections=${question.maxSelections}',
        );
      }
      final optionIds =
          questionAnswers.map((answer) => answer.optionId).toList();
      if (optionIds.toSet().length != optionIds.length) {
        errors.add('Question ${question.id} contains duplicate option answers');
      }
    }

    return errors;
  }

  void _applyEffect(_ProfileState state, _EffectDefinition effect) {
    switch (effect.operator) {
      case 'set':
        state.set(effect.field, effect.value);
      case 'allow':
        state.allow(effect.field, List<dynamic>.from(effect.value as List));
      case 'cap_max':
        state.capMax(effect.field, (effect.value as num).toInt());
      case 'cap_min':
        state.capMin(effect.field, (effect.value as num).toInt());
      case 'append':
        state.append(effect.field, effect.value);
    }
  }

  void _hydratePriorityTargetValues(Map<String, dynamic> profile) {
    final priorities = stringList(profile['priorities']);
    for (final priority in priorities) {
      final targetValues =
          _definition.scoringConfig.priorityTargetValues[priority];
      if (targetValues == null) {
        continue;
      }
      targetValues.forEach((field, value) {
        if (field == 'size') {
          return;
        }
        profile.putIfAbsent(field, () => value);
      });
    }
  }
}

class _ProfileState {
  final Map<String, dynamic> _values = <String, dynamic>{};
  final Map<String, int> _maxCaps = <String, int>{};
  final Map<String, int> _minCaps = <String, int>{};
  final Map<String, List<int>> _allowedLists = <String, List<int>>{};

  void set(String field, Object? value) {
    if (_allowedLists.containsKey(field) && value is List) {
      allow(field, value);
      return;
    }

    if (value is num) {
      var intValue = value.toInt();
      final minCap = _minCaps[field];
      final maxCap = _maxCaps[field];
      if (minCap != null && intValue < minCap) {
        intValue = minCap;
      }
      if (maxCap != null && intValue > maxCap) {
        intValue = maxCap;
      }
      _values[field] = intValue;
      return;
    }

    _values[field] = value;
  }

  void allow(String field, List<dynamic> values) {
    final normalized =
        values.whereType<num>().map((value) => value.toInt()).toSet().toList()
          ..sort();
    final existing = _allowedLists[field];
    if (existing == null) {
      _allowedLists[field] = normalized;
    } else {
      _allowedLists[field] =
          existing.where((value) => normalized.contains(value)).toList()
            ..sort();
    }
    _values[field] = _allowedLists[field];
  }

  void capMax(String field, int value) {
    final existing = _maxCaps[field];
    _maxCaps[field] =
        existing == null ? value : (existing < value ? existing : value);
    final current = _values[field];
    if (current is num && current.toInt() > _maxCaps[field]!) {
      _values[field] = _maxCaps[field];
    }
  }

  void capMin(String field, int value) {
    final existing = _minCaps[field];
    _minCaps[field] =
        existing == null ? value : (existing > value ? existing : value);
    final current = _values[field];
    if (current is num && current.toInt() < _minCaps[field]!) {
      _values[field] = _minCaps[field];
    }
  }

  void append(String field, Object? value) {
    final list = List<dynamic>.from(
      _values[field] as List<dynamic>? ?? const [],
    );
    if (!list.contains(value)) {
      list.add(value);
    }
    _values[field] = list;
  }

  Map<String, dynamic> toUserProfile() {
    final profile = Map<String, dynamic>.from(_values);
    if (!profile.containsKey('criticalContext')) {
      final contextKeys =
          _values.keys
              .where((key) => key.startsWith('criticalContext.'))
              .toList();
      if (contextKeys.isNotEmpty) {
        profile['criticalContext'] = <String, dynamic>{};
      }
    }

    for (final entry in _values.entries) {
      if (!entry.key.startsWith('criticalContext.')) {
        continue;
      }
      final nested =
          profile.putIfAbsent('criticalContext', () => <String, dynamic>{})
              as Map<String, dynamic>;
      nested[entry.key.split('.').last] = entry.value;
      profile.remove(entry.key);
    }

    return profile;
  }
}

class _QuestionnaireDefinition {
  const _QuestionnaireDefinition({
    required this.version,
    required this.questionsById,
  });

  factory _QuestionnaireDefinition.fromJson(Map<String, dynamic> json) {
    final questions =
        (json['questions'] as List<dynamic>)
            .map(
              (item) =>
                  _QuestionDefinition.fromJson(item as Map<String, dynamic>),
            )
            .toList();
    return _QuestionnaireDefinition(
      version: (json['questionnaireVersion'] as num).toInt(),
      questionsById: {for (final question in questions) question.id: question},
    );
  }

  final int version;
  final Map<String, _QuestionDefinition> questionsById;
}

class _QuestionDefinition {
  const _QuestionDefinition({
    required this.id,
    required this.kind,
    required this.required,
    required this.maxSelections,
    required this.optionIds,
  });

  factory _QuestionDefinition.fromJson(Map<String, dynamic> json) {
    return _QuestionDefinition(
      id: json['id'] as String,
      kind: json['kind'] as String,
      required: json['required'] as bool? ?? true,
      maxSelections: (json['maxSelections'] as num?)?.toInt(),
      optionIds:
          (json['options'] as List<dynamic>? ?? const [])
              .map((item) => (item as Map<String, dynamic>)['id'] as String)
              .toSet(),
    );
  }

  final String id;
  final String kind;
  final bool required;
  final int? maxSelections;
  final Set<String> optionIds;
}

class _MappingDefinition {
  const _MappingDefinition({required this.effectsByQuestionAndOption});

  factory _MappingDefinition.fromJson(Map<String, dynamic> json) {
    final effectsByQuestionAndOption =
        <String, Map<String, List<_EffectDefinition>>>{};
    for (final raw in json['mappings'] as List<dynamic>) {
      final item = raw as Map<String, dynamic>;
      final questionId = item['questionId'] as String;
      final optionId = item['optionId'] as String;
      final effects =
          (item['effects'] as List<dynamic>? ?? const [])
              .map(
                (effect) =>
                    _EffectDefinition.fromJson(effect as Map<String, dynamic>),
              )
              .toList();
      effectsByQuestionAndOption.putIfAbsent(
            questionId,
            () => <String, List<_EffectDefinition>>{},
          )[optionId] =
          effects;
    }

    return _MappingDefinition(
      effectsByQuestionAndOption: effectsByQuestionAndOption,
    );
  }

  final Map<String, Map<String, List<_EffectDefinition>>>
  effectsByQuestionAndOption;
}

class _EffectDefinition {
  const _EffectDefinition({
    required this.field,
    required this.operator,
    required this.value,
  });

  factory _EffectDefinition.fromJson(Map<String, dynamic> json) {
    return _EffectDefinition(
      field: json['field'] as String,
      operator: json['operator'] as String,
      value: json['value'],
    );
  }

  final String field;
  final String operator;
  final Object? value;
}
