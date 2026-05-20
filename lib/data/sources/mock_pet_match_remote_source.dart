import 'dart:convert';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../dto/answer_result_dto.dart';
import '../dto/answer_submit_dto.dart';
import '../dto/breed_detail_dto.dart';
import '../dto/compatibility_dto.dart';
import '../dto/dynamic_option_dto.dart';
import '../dto/question_dto.dart';
import '../dto/session_dto.dart';
import '../dto/stats_dto.dart';
import '../dto/user_summary_dto.dart';
import 'pet_match_remote_source.dart';

/// In-memory state machine для локального демо и для тестов без сети.
///
/// Поддерживает:
/// * последовательный flow вопросов из `assets/mock/questions.json`,
/// * dynamic-options с фильтрацией по `q`,
/// * имитацию polling — после последнего ответа возвращает `processing`,
///   на 2-й вызов `getSession` отдаёт `ready`,
/// * имитацию ошибок через `--dart-define=MOCK_FAIL_RATE=0..1`.
const String _kFailRateRaw = String.fromEnvironment(
  'MOCK_FAIL_RATE',
  defaultValue: '0',
);

class MockPetMatchRemoteSource implements PetMatchRemoteSource {
  MockPetMatchRemoteSource({Random? random, double? failRate})
    : _random = random ?? Random(),
      _failRate = failRate ?? (double.tryParse(_kFailRateRaw) ?? 0);

  final Random _random;
  final double _failRate;

  int? _userId;
  List<QuestionDto>? _questions;
  int _currentIndex = 0;
  int _pollsAfterCompletion = 0;

  Future<void> _maybeFail() async {
    await Future<void>.delayed(
      Duration(milliseconds: 250 + _random.nextInt(300)),
    );
    if (_failRate > 0 && _random.nextDouble() < _failRate) {
      throw DioException.connectionError(
        requestOptions: RequestOptions(path: 'mock'),
        reason: 'Injected mock failure',
      );
    }
  }

  Future<List<QuestionDto>> _loadQuestions() async {
    final cached = _questions;
    if (cached != null) return cached;
    final raw = await rootBundle.loadString('assets/mock/questions.json');
    final list =
        (jsonDecode(raw) as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(QuestionDto.fromJson)
            .toList();
    _questions = list;
    return list;
  }

  SessionDto _buildSession({
    QuestionDto? nextQuestion,
    CompatibilityDto? compatibility,
    required int answered,
    required int total,
  }) {
    return SessionDto(
      user: UserSummaryDto(
        id: _userId ?? 1,
        externalId: 'uid:mock-user',
        displayName: 'Тестовый пользователь',
      ),
      stats: StatsDto(
        answeredCount: answered,
        totalCount: total,
        progressPercent: total > 0 ? (answered / total) * 100 : 0,
        status: nextQuestion != null ? 'in_progress' : 'completed',
      ),
      nextQuestion: nextQuestion,
      compatibility: compatibility,
    );
  }

  String? _externalId;

  @override
  Future<SessionDto> startSession({required String externalId}) async {
    await _maybeFail();
    final questions = await _loadQuestions();
    // Если сессия уже была начата под тем же external_id — это resume
    // (retry после ошибки, hot-restart с сохранённым uid). Сохраняем прогресс,
    // чтобы пользователь не откатывался к первому вопросу.
    // Если external_id новый — сбрасываем индекс на 0 (новая анкета).
    if (_externalId != externalId) {
      _externalId = externalId;
      _currentIndex = 0;
      _pollsAfterCompletion = 0;
    }
    _userId = 1;
    final isCompleted = _currentIndex >= questions.length;
    return _buildSession(
      nextQuestion: isCompleted ? null : questions[_currentIndex],
      compatibility:
          isCompleted ? const CompatibilityDto(status: 'processing') : null,
      answered: _currentIndex,
      total: questions.length,
    );
  }

  @override
  Future<SessionDto> getSession({required int userId}) async {
    await _maybeFail();
    final questions = await _loadQuestions();
    if (_currentIndex < questions.length) {
      return _buildSession(
        nextQuestion: questions[_currentIndex],
        answered: _currentIndex,
        total: questions.length,
      );
    }

    // Анкета пройдена → имитируем polling: первые 2 опроса — processing,
    // дальше — ready.
    _pollsAfterCompletion += 1;
    final compatibility = await _loadCompatibility(
      readyFromPoll: _pollsAfterCompletion >= 2,
    );
    return _buildSession(
      compatibility: compatibility,
      answered: questions.length,
      total: questions.length,
    );
  }

  Future<CompatibilityDto> _loadCompatibility({
    required bool readyFromPoll,
  }) async {
    final path =
        readyFromPoll
            ? 'assets/mock/compatibility_ready.json'
            : 'assets/mock/compatibility_processing.json';
    final raw = await rootBundle.loadString(path);
    return CompatibilityDto.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<AnswerResultDto> submitAnswer({
    required int userId,
    required AnswerSubmitDto answer,
  }) async {
    await _maybeFail();
    final questions = await _loadQuestions();
    _currentIndex = (_currentIndex + 1).clamp(0, questions.length);
    final isCompleted = _currentIndex >= questions.length;
    final nextQuestion = isCompleted ? null : questions[_currentIndex];

    return AnswerResultDto(
      session: _buildSession(
        nextQuestion: nextQuestion,
        compatibility:
            isCompleted ? const CompatibilityDto(status: 'processing') : null,
        answered: _currentIndex,
        total: questions.length,
      ),
    );
  }

  @override
  Future<SessionDto> skipQuestion({
    required int userId,
    required int questionId,
  }) async {
    await _maybeFail();
    final questions = await _loadQuestions();
    _currentIndex = (_currentIndex + 1).clamp(0, questions.length);
    final isCompleted = _currentIndex >= questions.length;
    return _buildSession(
      nextQuestion: isCompleted ? null : questions[_currentIndex],
      compatibility:
          isCompleted ? const CompatibilityDto(status: 'processing') : null,
      answered: _currentIndex,
      total: questions.length,
    );
  }

  @override
  Future<DynamicOptionListDto> getDynamicOptions({
    required int userId,
    required int questionId,
    String? query,
    int limit = 50,
  }) async {
    await _maybeFail();
    final raw = await rootBundle.loadString(
      'assets/mock/dynamic_options_preferred_breed.json',
    );
    final dto = DynamicOptionListDto.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    final filtered =
        query == null || query.isEmpty
            ? dto.items
            : dto.items
                .where(
                  (o) => o.label.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
    return DynamicOptionListDto(
      questionId: dto.questionId,
      items: filtered.take(limit).toList(),
    );
  }

  @override
  Future<BreedDetailDto> getBreedDetail({required int breedId}) async {
    await _maybeFail();
    try {
      final raw = await rootBundle.loadString(
        'assets/mock/breed_$breedId.json',
      );
      return BreedDetailDto.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // `rootBundle.loadString` для отсутствующего файла бросает FlutterError
      // (subclass Error, не Exception), поэтому ловим всё. Fallback —
      // фикстура breed_501.
      final raw = await rootBundle.loadString('assets/mock/breed_501.json');
      return BreedDetailDto.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
  }
}
