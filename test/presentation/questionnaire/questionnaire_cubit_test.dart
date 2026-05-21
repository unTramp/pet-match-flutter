import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_match/core/failures.dart';
import 'package:pet_match/domain/entities/answer.dart';
import 'package:pet_match/domain/entities/option.dart';
import 'package:pet_match/domain/entities/progress.dart';
import 'package:pet_match/domain/entities/question.dart';
import 'package:pet_match/domain/entities/session.dart';
import 'package:pet_match/domain/usecases/skip_question.dart';
import 'package:pet_match/domain/usecases/start_session.dart';
import 'package:pet_match/domain/usecases/submit_answer.dart';
import 'package:pet_match/presentation/questionnaire/cubit/questionnaire_cubit.dart';
import 'package:pet_match/presentation/questionnaire/cubit/questionnaire_state.dart';

class _MockStart extends Mock implements StartSession {}

class _MockSubmit extends Mock implements SubmitAnswer {}

class _MockSkip extends Mock implements SkipQuestion {}

const _firstQuestion = SingleChoiceQuestion(
  id: 101,
  title: 'Какой питомец?',
  options: [
    QuestionOption(id: 1, code: 'dog', label: 'Собака'),
    QuestionOption(id: 2, code: 'cat', label: 'Кошка'),
  ],
);

const _secondQuestion = SingleChoiceQuestion(
  id: 102,
  title: 'Где живёте?',
  options: [QuestionOption(id: 11, code: 'flat', label: 'Квартира')],
);

Session _sessionWithQuestion(Question? q, {int answered = 0, int total = 2}) =>
    Session(
      userId: 7,
      progress: Progress(answered: answered, total: total),
      nextQuestion: q,
    );

void main() {
  late _MockStart start;
  late _MockSubmit submit;
  late _MockSkip skip;

  setUpAll(() {
    registerFallbackValue(const SingleAnswer(questionId: 0, optionId: 0));
  });

  setUp(() {
    start = _MockStart();
    submit = _MockSubmit();
    skip = _MockSkip();
  });

  blocTest<QuestionnaireCubit, QuestionnaireState>(
    'start emits [Loading, Question] on success',
    setUp: () {
      when(
        start.call,
      ).thenAnswer((_) async => _sessionWithQuestion(_firstQuestion));
    },
    build: () => QuestionnaireCubit(start, submit, skip),
    act: (cubit) => cubit.start(),
    expect:
        () => [
          isA<QuestionnaireLoading>(),
          isA<QuestionnaireQuestion>().having(
            (s) => s.question.id,
            'question.id',
            101,
          ),
        ],
  );

  blocTest<QuestionnaireCubit, QuestionnaireState>(
    'submit on non-last question keeps question visible and emits Question(next)',
    setUp: () {
      when(
        start.call,
      ).thenAnswer((_) async => _sessionWithQuestion(_firstQuestion));
      when(
        () =>
            submit(userId: any(named: 'userId'), answer: any(named: 'answer')),
      ).thenAnswer(
        (_) async => _sessionWithQuestion(_secondQuestion, answered: 1),
      );
    },
    build: () => QuestionnaireCubit(start, submit, skip),
    act: (cubit) async {
      await cubit.start();
      cubit.selectSingle(1);
      await cubit.submit();
    },
    skip: 2,
    expect:
        () => [
          isA<QuestionnaireQuestion>().having(
            (s) => s.selectedOptionIds,
            'selection',
            {1},
          ),
          isA<QuestionnaireQuestion>().having(
            (s) => s.isSubmitting,
            'isSubmitting',
            true,
          ),
          isA<QuestionnaireQuestion>().having(
            (s) => s.question.id,
            'next question id',
            102,
          ),
        ],
  );

  blocTest<QuestionnaireCubit, QuestionnaireState>(
    'submit on last question emits Completed',
    setUp: () {
      when(
        start.call,
      ).thenAnswer((_) async => _sessionWithQuestion(_firstQuestion));
      when(
        () =>
            submit(userId: any(named: 'userId'), answer: any(named: 'answer')),
      ).thenAnswer(
        (_) async => _sessionWithQuestion(null, answered: 2, total: 2),
      );
    },
    build: () => QuestionnaireCubit(start, submit, skip),
    act: (cubit) async {
      await cubit.start();
      cubit.selectSingle(1);
      await cubit.submit();
    },
    skip: 2,
    expect:
        () => [
          isA<QuestionnaireQuestion>(),
          isA<QuestionnaireQuestion>().having(
            (s) => s.isSubmitting,
            'isSubmitting',
            true,
          ),
          isA<QuestionnaireCompleted>().having((s) => s.userId, 'userId', 7),
        ],
  );

  blocTest<QuestionnaireCubit, QuestionnaireState>(
    'start failure emits Error with retry available',
    setUp: () {
      when(start.call).thenThrow(const NetworkFailure());
    },
    build: () => QuestionnaireCubit(start, submit, skip),
    act: (cubit) => cubit.start(),
    expect:
        () => [
          isA<QuestionnaireLoading>(),
          isA<QuestionnaireError>()
              .having((s) => s.failure, 'failure', isA<NetworkFailure>())
              .having((s) => s.canRetry, 'canRetry', true),
        ],
  );

  group('toggleMulti with exclusive options', () {
    const multiQuestion = MultipleChoiceQuestion(
      id: 8,
      title: 'Есть ли другие питомцы?',
      options: [
        QuestionOption(id: 29, code: 'no-pets', label: 'Нет'),
        QuestionOption(id: 30, code: 'dog', label: 'Собака'),
        QuestionOption(id: 31, code: 'cat', label: 'Кошка'),
      ],
      exclusiveOptionCodes: {'no-pets'},
    );

    Session sessionWithMulti() => const Session(
      userId: 7,
      progress: Progress(answered: 0, total: 2),
      nextQuestion: multiQuestion,
    );

    blocTest<QuestionnaireCubit, QuestionnaireState>(
      'выбор exclusive после обычной → вытесняет всё кроме exclusive',
      setUp: () {
        when(start.call).thenAnswer((_) async => sessionWithMulti());
      },
      build: () => QuestionnaireCubit(start, submit, skip),
      act: (cubit) async {
        await cubit.start();
        cubit.toggleMulti(30); // Собака
        cubit.toggleMulti(31); // Кошка
        cubit.toggleMulti(29); // Нет (exclusive)
      },
      skip: 2,
      verify: (cubit) {
        final s = cubit.state as QuestionnaireQuestion;
        expect(s.selectedOptionIds, {29});
      },
    );

    blocTest<QuestionnaireCubit, QuestionnaireState>(
      'выбор обычной после exclusive → exclusive выбрасывается',
      setUp: () {
        when(start.call).thenAnswer((_) async => sessionWithMulti());
      },
      build: () => QuestionnaireCubit(start, submit, skip),
      act: (cubit) async {
        await cubit.start();
        cubit.toggleMulti(29); // Нет (exclusive)
        cubit.toggleMulti(30); // Собака
      },
      skip: 2,
      verify: (cubit) {
        final s = cubit.state as QuestionnaireQuestion;
        expect(s.selectedOptionIds, {30});
      },
    );

    blocTest<QuestionnaireCubit, QuestionnaireState>(
      'без exclusive — обычный toggle работает как раньше',
      setUp: () {
        when(start.call).thenAnswer((_) async => sessionWithMulti());
      },
      build: () => QuestionnaireCubit(start, submit, skip),
      act: (cubit) async {
        await cubit.start();
        cubit.toggleMulti(30);
        cubit.toggleMulti(31);
        cubit.toggleMulti(30); // toggle off
      },
      skip: 2,
      verify: (cubit) {
        final s = cubit.state as QuestionnaireQuestion;
        expect(s.selectedOptionIds, {31});
      },
    );
  });

  blocTest<QuestionnaireCubit, QuestionnaireState>(
    'retry after Error recovers',
    setUp: () {
      var first = true;
      when(start.call).thenAnswer((_) async {
        if (first) {
          first = false;
          throw const NetworkFailure();
        }
        return _sessionWithQuestion(_firstQuestion);
      });
    },
    build: () => QuestionnaireCubit(start, submit, skip),
    act: (cubit) async {
      await cubit.start();
      await cubit.retry();
    },
    expect:
        () => [
          isA<QuestionnaireLoading>(),
          isA<QuestionnaireError>(),
          isA<QuestionnaireLoading>(),
          isA<QuestionnaireQuestion>(),
        ],
  );

  blocTest<QuestionnaireCubit, QuestionnaireState>(
    'goBack returns to previous answered question',
    setUp: () {
      when(
        start.call,
      ).thenAnswer((_) async => _sessionWithQuestion(_firstQuestion));
      when(
        () =>
            submit(userId: any(named: 'userId'), answer: any(named: 'answer')),
      ).thenAnswer(
        (_) async => _sessionWithQuestion(_secondQuestion, answered: 1),
      );
    },
    build: () => QuestionnaireCubit(start, submit, skip),
    act: (cubit) async {
      await cubit.start();
      cubit.selectSingle(2);
      await cubit.submit();
      cubit.goBack();
    },
    skip: 2,
    verify: (cubit) {
      expect(cubit.state, isA<QuestionnaireQuestion>());
      final state = cubit.state as QuestionnaireQuestion;
      expect(state.question.id, 101);
      expect(state.selectedOptionIds, {2});
    },
  );

  test(
    'goBack во время submit-in-flight — no-op, не возвращает к Q1 и не ломает '
    'историю при resolve submit()',
    () async {
      // Готовим сценарий: start → Q1, потом submit «висит» (Completer не
      // resolved), пользователь жмёт back. Ожидаем что goBack ничего не
      // делает, потом submit() резолвится → текущее состояние Q2.
      when(
        start.call,
      ).thenAnswer((_) async => _sessionWithQuestion(_firstQuestion));

      final submitCompleter = Completer<Session>();
      when(
        () =>
            submit(userId: any(named: 'userId'), answer: any(named: 'answer')),
      ).thenAnswer((_) => submitCompleter.future);

      final cubit = QuestionnaireCubit(start, submit, skip);
      await cubit.start();
      cubit.selectSingle(2);
      // submit() возвращает Future — НЕ ждём его.
      final submitFuture = cubit.submit();
      // Сейчас state == QuestionnaireQuestion(isSubmitting: true)
      expect(cubit.state, isA<QuestionnaireQuestion>());
      final inFlight = cubit.state as QuestionnaireQuestion;
      expect(inFlight.isSubmitting, isTrue);

      // Race: пользователь нажимает back во время submit-in-flight.
      cubit.goBack();
      expect(
        cubit.state,
        isA<QuestionnaireQuestion>(),
        reason: 'goBack должен быть no-op во время submit-in-flight',
      );
      expect((cubit.state as QuestionnaireQuestion).isSubmitting, isTrue);

      // Резолвим submit() → должен приехать Q2.
      submitCompleter.complete(
        _sessionWithQuestion(_secondQuestion, answered: 1),
      );
      await submitFuture;

      expect(cubit.state, isA<QuestionnaireQuestion>());
      final state = cubit.state as QuestionnaireQuestion;
      expect(state.question.id, 102, reason: 'должен быть Q2, не Q1');
      expect(cubit.canGoBack, isTrue, reason: 'Q1 должен быть в истории');

      await cubit.close();
    },
  );
}
