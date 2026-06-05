import '../../core/cache/questionnaire_draft_cache.dart';
import '../../core/failures.dart';
import '../../domain/entities/answer.dart';
import '../../domain/entities/compatibility.dart';
import '../../domain/entities/option.dart';
import '../../domain/entities/progress.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/session.dart';
import '../../domain/repositories/questionnaire_repository.dart';
import '../dto/compatibility_dto.dart';
import '../dto/petwise_profile_dto.dart';
import '../dto/petwise_questionnaire_definition_dto.dart';
import '../mappers/compatibility_mapper.dart';
import '../network/dio_failure_mapper.dart';
import '../sources/petwise_remote_source.dart';

class QuestionnaireRepositoryImpl implements QuestionnaireRepository {
  QuestionnaireRepositoryImpl(this._source, this._draftCache);

  final PetWiseRemoteSource _source;
  final QuestionnaireDraftCache _draftCache;

  static const int _localUserId = 1;
  static const String _refinementGateId = 'refinement_gate';
  static const String _refinementContinueOptionId = 'continue';

  PetWiseQuestionnaireDefinitionDto? _definitionCache;

  @override
  Future<Session> startSession(String externalId) => guardCall(() async {
    final definition = await _loadDefinition();
    await _draftCache.clear();
    return _buildSession(
      userId: _localUserId,
      definition: definition,
      draft: _emptyDraft(definition.questionnaireVersion),
      compatibility: null,
    );
  });

  @override
  Future<Session> getSession(int userId) => guardCall(() async {
    final definition = await _loadDefinition();
    final draft = await _loadOrCreateDraft(definition.questionnaireVersion);
    final compatibility = await _loadCompatibilityIfCompleted(
      definition: definition,
      draft: draft,
    );
    return _buildSession(
      userId: userId,
      definition: definition,
      draft: draft,
      compatibility: compatibility,
    );
  });

  @override
  Future<Session> submitAnswer({
    required int userId,
    required UserAnswer answer,
  }) => guardCall(() async {
    final definition = await _loadDefinition();
    final draft = await _loadOrCreateDraft(definition.questionnaireVersion);
    final runtime = _runtime(definition);
    final localQuestion = runtime.questionByLocalId[answer.questionId];
    if (localQuestion == null) {
      throw ServerFailure(
        statusCode: -1,
        message: 'Unknown local question id: ${answer.questionId}',
      );
    }

    _applyAnswer(
      draft: draft,
      runtime: runtime,
      question: localQuestion,
      answer: answer,
    );
    draft['compatibility'] = null;
    await _draftCache.save(draft);

    final compatibility = await _loadCompatibilityIfCompleted(
      definition: definition,
      draft: draft,
    );
    return _buildSession(
      userId: userId,
      definition: definition,
      draft: draft,
      compatibility: compatibility,
    );
  });

  @override
  Future<Session> skipQuestion({
    required int userId,
    required int questionId,
  }) => guardCall(() async {
    final definition = await _loadDefinition();
    final draft = await _loadOrCreateDraft(definition.questionnaireVersion);
    final runtime = _runtime(definition);
    final localQuestion = runtime.questionByLocalId[questionId];
    if (localQuestion == null) {
      throw ServerFailure(
        statusCode: -1,
        message: 'Unknown local question id: $questionId',
      );
    }
    final skipped = _mutableStringListMap(draft, 'skippedQuestionIds');
    skipped.add(localQuestion.remoteQuestionId);
    final answers = _mutableAnswersMap(draft);
    answers.remove(localQuestion.remoteQuestionId);
    draft['compatibility'] = null;
    await _draftCache.save(draft);

    final compatibility = await _loadCompatibilityIfCompleted(
      definition: definition,
      draft: draft,
    );
    return _buildSession(
      userId: userId,
      definition: definition,
      draft: draft,
      compatibility: compatibility,
    );
  });

  @override
  Future<List<DynamicOption>> getDynamicOptions({
    required int userId,
    required int questionId,
    String? query,
  }) async {
    return const <DynamicOption>[];
  }

  Future<PetWiseQuestionnaireDefinitionDto> _loadDefinition() async {
    return _definitionCache ??= await _source.getQuestionnaireDefinition();
  }

  Future<Map<String, dynamic>> _loadOrCreateDraft(int questionnaireVersion) async {
    final loaded = await _draftCache.load();
    if (loaded == null) {
      return _emptyDraft(questionnaireVersion);
    }
    final version = (loaded['questionnaireVersion'] as num?)?.toInt();
    if (version != questionnaireVersion) {
      return _emptyDraft(questionnaireVersion);
    }
    return loaded;
  }

  Map<String, dynamic> _emptyDraft(int questionnaireVersion) {
    return <String, dynamic>{
      'questionnaireVersion': questionnaireVersion,
      'answers': <String, dynamic>{},
      'skippedQuestionIds': <String>[],
      'compatibility': null,
    };
  }

  _QuestionnaireRuntime _runtime(PetWiseQuestionnaireDefinitionDto definition) =>
      _QuestionnaireRuntime.fromDefinition(definition);

  Future<Compatibility?> _loadCompatibilityIfCompleted({
    required PetWiseQuestionnaireDefinitionDto definition,
    required Map<String, dynamic> draft,
  }) async {
    final runtime = _runtime(definition);
    final nextQuestion = _nextQuestion(runtime, draft);
    if (nextQuestion != null) return null;

    final cached = draft['compatibility'];
    if (cached is Map<String, dynamic>) {
      return CompatibilityMapper.fromDto(
        CompatibilityDto.fromJson(cached),
      );
    }

    final answers = _buildSelectedAnswers(runtime, draft);
    final profileResponse = await _source.buildProfile(
      questionnaireVersion: definition.questionnaireVersion,
      answers: answers,
    );
    final matchResponse = await _source.previewMatch(
      questionnaireVersion: profileResponse.questionnaireVersion,
      userProfile: profileResponse.userProfile,
    );
    draft['compatibility'] = _compatibilityToCacheJson(
      matchResponse.compatibility,
    );
    await _draftCache.save(draft);
    return CompatibilityMapper.fromDto(matchResponse.compatibility);
  }

  Map<String, dynamic> _compatibilityToCacheJson(CompatibilityDto dto) {
    return <String, dynamic>{
      'status': dto.status,
      'breed_id': dto.breedId,
      'breed_name': dto.breedName,
      'image_url': dto.imageUrl,
      'risk_level': dto.riskLevel,
      'score': dto.score,
      'summary': dto.summary,
      'compatible': dto.compatible,
      'insights': dto.insights,
      'requirement_highlights': dto.requirementHighlights,
      'hard_reasons': dto.hardReasons
          .map(
            (item) => <String, dynamic>{
              'code': item.code,
              'severity': item.severity,
              'message': item.message,
            },
          )
          .toList(growable: false),
      'risks': dto.risks
          .map(
            (item) => <String, dynamic>{
              'code': item.code,
              'severity': item.severity,
              'message': item.message,
            },
          )
          .toList(growable: false),
      'refusal': dto.refusal == null
          ? null
          : <String, dynamic>{
              'title': dto.refusal!.title,
              'external_message': dto.refusal!.externalMessage,
            },
      'suggestions': dto.suggestions
          .map(
            (item) => <String, dynamic>{
              'breed_id': item.breedId,
              'breed_name': item.breedName,
              'risk_level': item.riskLevel,
              'score': item.score,
              'summary': item.summary,
              'image_url': item.imageUrl,
            },
          )
          .toList(growable: false),
    };
  }

  Session _buildSession({
    required int userId,
    required PetWiseQuestionnaireDefinitionDto definition,
    required Map<String, dynamic> draft,
    required Compatibility? compatibility,
  }) {
    final runtime = _runtime(definition);
    final visibleQuestions = _visibleQuestions(runtime, draft);
    final nextQuestion = _nextQuestion(runtime, draft);
    final completedCount = visibleQuestions
        .where((question) => _isQuestionCompleted(question, draft))
        .length;
    return Session(
      userId: userId,
      progress: Progress(
        answered: completedCount,
        total: visibleQuestions.length,
      ),
      nextQuestion: nextQuestion?.question,
      compatibility: compatibility,
    );
  }

  List<_LocalQuestion> _visibleQuestions(
    _QuestionnaireRuntime runtime,
    Map<String, dynamic> draft,
  ) {
    final answers = _answersMap(draft);
    final skipped = _stringList(draft['skippedQuestionIds']);
    final refinementEnabled =
        answers[_refinementGateId]?.contains(_refinementContinueOptionId) ??
        false;
    final refinementGateSkipped = skipped.contains(_refinementGateId);

    return runtime.questions.where((question) {
      final isRefinementQuestion = question.remoteQuestionId == _refinementGateId;
      final isOptionalRefinementBlock = question.question.id >= 10;
      if (!isRefinementQuestion && !question.question.isOptional) {
        return true;
      }
      if (isRefinementQuestion) {
        return true;
      }
      if (!refinementEnabled || refinementGateSkipped) {
        return !isOptionalRefinementBlock;
      }
      return true;
    }).toList(growable: false);
  }

  _LocalQuestion? _nextQuestion(
    _QuestionnaireRuntime runtime,
    Map<String, dynamic> draft,
  ) {
    for (final question in _visibleQuestions(runtime, draft)) {
      if (!_isQuestionCompleted(question, draft)) {
        return question;
      }
    }
    return null;
  }

  bool _isQuestionCompleted(_LocalQuestion question, Map<String, dynamic> draft) {
    final answers = _answersMap(draft);
    final skipped = _stringList(draft['skippedQuestionIds']);
    return skipped.contains(question.remoteQuestionId) ||
        (answers[question.remoteQuestionId]?.isNotEmpty ?? false);
  }

  void _applyAnswer({
    required Map<String, dynamic> draft,
    required _QuestionnaireRuntime runtime,
    required _LocalQuestion question,
    required UserAnswer answer,
  }) {
    final answers = _mutableAnswersMap(draft);
    final skipped = _mutableStringListMap(draft, 'skippedQuestionIds');
    skipped.remove(question.remoteQuestionId);

    final selectedOptionIds = switch (answer) {
      SingleAnswer(:final optionId) => <int>[optionId],
      MultipleAnswer(:final optionIds) => optionIds.toList(growable: false),
      DynamicAnswer() => const <int>[],
    };
    final remoteIds = selectedOptionIds
        .map((id) => question.remoteOptionIdByLocalId[id])
        .whereType<String>()
        .toList(growable: false);
    answers[question.remoteQuestionId] = remoteIds;
  }

  List<PetWiseSelectedAnswerDto> _buildSelectedAnswers(
    _QuestionnaireRuntime runtime,
    Map<String, dynamic> draft,
  ) {
    final answers = _answersMap(draft);
    final visibleRemoteIds = _visibleQuestions(runtime, draft)
        .map((question) => question.remoteQuestionId)
        .toSet();

    return answers.entries
        .where(
          (entry) =>
              visibleRemoteIds.contains(entry.key) && entry.value.isNotEmpty,
        )
        .map(
          (entry) => PetWiseSelectedAnswerDto(
            questionId: entry.key,
            selectedOptionIds: entry.value,
          ),
        )
        .toList(growable: false);
  }

  Map<String, List<String>> _answersMap(Map<String, dynamic> draft) {
    final raw = draft['answers'] as Map<String, dynamic>? ?? const {};
    return raw.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>? ?? const []).whereType<String>().toList(),
      ),
    );
  }

  Map<String, dynamic> _mutableAnswersMap(Map<String, dynamic> draft) {
    final raw = draft['answers'];
    if (raw is Map<String, dynamic>) return raw;
    final created = <String, dynamic>{};
    draft['answers'] = created;
    return created;
  }

  List<String> _stringList(Object? raw) =>
      (raw as List<dynamic>? ?? const []).whereType<String>().toList();

  List<String> _mutableStringListMap(
    Map<String, dynamic> draft,
    String key,
  ) {
    final raw = draft[key];
    if (raw is List<dynamic>) {
      return raw.cast<String>();
    }
    final created = <String>[];
    draft[key] = created;
    return created;
  }
}

class _QuestionnaireRuntime {
  _QuestionnaireRuntime({
    required this.questions,
    required this.questionByLocalId,
  });

  factory _QuestionnaireRuntime.fromDefinition(
    PetWiseQuestionnaireDefinitionDto definition,
  ) {
    final sorted = definition.questions.toList()
      ..sort((left, right) => left.order.compareTo(right.order));
    final questions = sorted.map(_LocalQuestion.fromDto).toList(growable: false);
    final byId = <int, _LocalQuestion>{
      for (final question in questions) question.question.id: question,
    };
    return _QuestionnaireRuntime(questions: questions, questionByLocalId: byId);
  }

  final List<_LocalQuestion> questions;
  final Map<int, _LocalQuestion> questionByLocalId;
}

class _LocalQuestion {
  _LocalQuestion({
    required this.remoteQuestionId,
    required this.remoteOptionIdByLocalId,
    required this.question,
  });

  factory _LocalQuestion.fromDto(PetWiseQuestionDto dto) {
    final options = <QuestionOption>[];
    final remoteOptionIdByLocalId = <int, String>{};
    for (var index = 0; index < dto.options.length; index++) {
      final localId = index + 1;
      final option = dto.options[index];
      options.add(
        QuestionOption(
          id: localId,
          code: option.id,
          label: option.label,
        ),
      );
      remoteOptionIdByLocalId[localId] = option.id;
    }

    final question = switch (dto.kind) {
      'single_choice' => SingleChoiceQuestion(
          id: dto.order,
          title: dto.title,
          helpText: dto.description,
          isOptional: !dto.isRequired,
          options: options,
        ),
      'multi_choice' => MultipleChoiceQuestion(
          id: dto.order,
          title: dto.title,
          helpText: dto.description,
          isOptional: !dto.isRequired,
          options: options,
          maxSelections: dto.maxSelections,
        ),
      _ => UnknownQuestion(
          id: dto.order,
          title: dto.title,
          helpText: dto.description,
          isOptional: !dto.isRequired,
          questionType: dto.kind,
        ),
    };

    return _LocalQuestion(
      remoteQuestionId: dto.id,
      remoteOptionIdByLocalId: remoteOptionIdByLocalId,
      question: question,
    );
  }

  final String remoteQuestionId;
  final Map<int, String> remoteOptionIdByLocalId;
  final Question question;
}
