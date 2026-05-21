import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_match/core/failures.dart';
import 'package:pet_match/domain/entities/answer.dart';
import 'package:pet_match/domain/entities/option.dart';
import 'package:pet_match/domain/entities/compatibility.dart';
import 'package:pet_match/domain/entities/progress.dart';
import 'package:pet_match/domain/entities/question.dart';
import 'package:pet_match/domain/entities/session.dart';
import 'package:pet_match/domain/usecases/poll_compatibility.dart';
import 'package:pet_match/domain/usecases/skip_question.dart';
import 'package:pet_match/domain/usecases/start_session.dart';
import 'package:pet_match/domain/usecases/submit_answer.dart';
import 'package:pet_match/presentation/questionnaire/cubit/questionnaire_cubit.dart';
import 'package:pet_match/presentation/questionnaire/cubit/questionnaire_state.dart';

class _MockStart extends Mock implements StartSession {}

class _MockSubmit extends Mock implements SubmitAnswer {}

class _MockSkip extends Mock implements SkipQuestion {}

class _MockPoll extends Mock implements PollCompatibility {}

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

const _readyCompatibility = Compatibility(status: CompatibilityStatus.ready);

void main() {
  late _MockStart start;
  late _MockSubmit submit;
  late _MockSkip skip;
  late _MockPoll poll;

  setUpAll(() {
    registerFallbackValue(const SingleAnswer(questionId: 0, optionId: 0));
  });

  setUp(() {
    start = _MockStart();
    submit = _MockSubmit();
    skip = _MockSkip();
    poll = _MockPoll();
    when(
      () => poll(userId: any(named: 'userId')),
    ).thenAnswer((_) async => _readyCompatibility);
  });

  blocTest<QuestionnaireCubit, QuestionnaireState>(
    'start emits [Loading, Question] on success',
    setUp: () {
      when(
        start.call,
      ).thenAnswer((_) async => _sessionWithQuestion(_firstQuestion));
    },
    build: () => QuestionnaireCubit(start, submit, skip, poll),
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
    build: () => QuestionnaireCubit(start, submit, skip, poll),
    act: (cubit) async {
      await cubit.start();
      cubit.selectSingle(1);
      await cubit.submit();
    },
    skip: 3,
    expect:
        () => [
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
    verify: (_) {
      verifyNever(() => poll(userId: any(named: 'userId')));
    },
  );

  blocTest<QuestionnaireCubit, QuestionnaireState>(
    'submit continues adaptive flow when backend adds more questions',
    setUp: () {
      when(start.call).thenAnswer(
        (_) async =>
            _sessionWithQuestion(_firstQuestion, answered: 16, total: 17),
      );
      when(
        () =>
            submit(userId: any(named: 'userId'), answer: any(named: 'answer')),
      ).thenAnswer(
        (_) async =>
            _sessionWithQuestion(_secondQuestion, answered: 17, total: 26),
      );
    },
    build: () => QuestionnaireCubit(start, submit, skip, poll),
    act: (cubit) async {
      await cubit.start();
      cubit.selectSingle(1);
      await cubit.submit();
    },
    skip: 3,
    expect:
        () => [
          isA<QuestionnaireQuestion>().having(
            (s) => s.isSubmitting,
            'isSubmitting',
            true,
          ),
          isA<QuestionnaireQuestion>()
              .having((s) => s.question.id, 'next question id', 102)
              .having((s) => s.progress.total, 'expanded total', 26),
        ],
    verify: (_) {
      verifyNever(() => poll(userId: any(named: 'userId')));
    },
  );

  blocTest<QuestionnaireCubit, QuestionnaireState>(
    'submit on last question emits ResultReady',
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
    build: () => QuestionnaireCubit(start, submit, skip, poll),
    act: (cubit) async {
      await cubit.start();
      cubit.selectSingle(1);
      await cubit.submit();
    },
    skip: 3,
    expect:
        () => [
          isA<QuestionnaireQuestion>().having(
            (s) => s.isSubmitting,
            'isSubmitting',
            true,
          ),
          isA<QuestionnaireResultReady>(),
        ],
  );

  blocTest<QuestionnaireCubit, QuestionnaireState>(
    'submit on terminal skipped compatibility emits ResultReady without polling',
    setUp: () {
      when(
        start.call,
      ).thenAnswer((_) async => _sessionWithQuestion(_firstQuestion));
      when(
        () =>
            submit(userId: any(named: 'userId'), answer: any(named: 'answer')),
      ).thenAnswer(
        (_) async => const Session(
          userId: 7,
          progress: Progress(answered: 17, total: 17),
          compatibility: Compatibility(
            status: CompatibilityStatus.skipped,
            summary: 'Подборка вариантов без выбранной породы.',
            suggestions: [
              CompatibilitySuggestion(breedId: 1, breedName: 'Скоттиш Страйт'),
            ],
          ),
        ),
      );
    },
    build: () => QuestionnaireCubit(start, submit, skip, poll),
    act: (cubit) async {
      await cubit.start();
      cubit.selectSingle(1);
      await cubit.submit();
    },
    skip: 3,
    expect:
        () => [
          isA<QuestionnaireQuestion>().having(
            (s) => s.isSubmitting,
            'isSubmitting',
            true,
          ),
          isA<QuestionnaireResultReady>().having(
            (s) => s.compatibility.suggestions.length,
            'suggestions',
            1,
          ),
        ],
    verify: (_) {
      verifyNever(() => poll(userId: any(named: 'userId')));
    },
  );

  blocTest<QuestionnaireCubit, QuestionnaireState>(
    'start failure emits Error with retry available',
    setUp: () {
      when(start.call).thenThrow(const NetworkFailure());
    },
    build: () => QuestionnaireCubit(start, submit, skip, poll),
    act: (cubit) => cubit.start(),
    expect:
        () => [
          isA<QuestionnaireLoading>(),
          isA<QuestionnaireError>()
              .having((s) => s.failure, 'failure', isA<NetworkFailure>())
              .having((s) => s.canRetry, 'canRetry', true),
        ],
  );

  blocTest<QuestionnaireCubit, QuestionnaireState>(
    'start unexpected exception emits generic ServerFailure instead of infinite loading',
    setUp: () {
      when(start.call).thenThrow(const FormatException('bad json'));
    },
    build: () => QuestionnaireCubit(start, submit, skip, poll),
    act: (cubit) => cubit.start(),
    expect:
        () => [
          isA<QuestionnaireLoading>(),
          isA<QuestionnaireError>()
              .having((s) => s.failure, 'failure', isA<ServerFailure>())
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
      build: () => QuestionnaireCubit(start, submit, skip, poll),
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
      build: () => QuestionnaireCubit(start, submit, skip, poll),
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
      build: () => QuestionnaireCubit(start, submit, skip, poll),
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
    build: () => QuestionnaireCubit(start, submit, skip, poll),
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
}
