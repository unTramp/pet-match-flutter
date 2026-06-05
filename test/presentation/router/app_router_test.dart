import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_match/core/cache/questionnaire_draft_cache.dart';
import 'package:pet_match/core/cache/session_cache.dart';
import 'package:pet_match/core/di/injection.dart';
import 'package:pet_match/domain/entities/option.dart';
import 'package:pet_match/domain/entities/progress.dart';
import 'package:pet_match/domain/entities/question.dart';
import 'package:pet_match/domain/entities/session.dart';
import 'package:pet_match/domain/repositories/breed_repository.dart';
import 'package:pet_match/domain/repositories/questionnaire_repository.dart';
import 'package:pet_match/domain/usecases/get_breed_detail.dart';
import 'package:pet_match/domain/usecases/get_dynamic_options.dart';
import 'package:pet_match/domain/usecases/poll_compatibility.dart';
import 'package:pet_match/domain/usecases/skip_question.dart';
import 'package:pet_match/domain/usecases/start_session.dart';
import 'package:pet_match/domain/usecases/submit_answer.dart';
import 'package:pet_match/presentation/details/cubit/breed_detail_cubit.dart';
import 'package:pet_match/presentation/intro/intro_page.dart';
import 'package:pet_match/presentation/questionnaire/cubit/questionnaire_cubit.dart';
import 'package:pet_match/presentation/questionnaire/questionnaire_page.dart';
import 'package:pet_match/presentation/router/app_router.dart';
import 'package:pet_match/presentation/welcome/welcome_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockSessionCache extends Mock implements SessionCache {}

class _MockQuestionnaireRepository extends Mock
    implements QuestionnaireRepository {}

class _MockBreedRepository extends Mock implements BreedRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockSessionCache cache;
  late _MockQuestionnaireRepository questionnaireRepository;
  late _MockBreedRepository breedRepository;

  const firstQuestion = SingleChoiceQuestion(
    id: 1,
    title: 'Какой питомец?',
    options: [QuestionOption(id: 1, code: 'dog', label: 'Собака')],
  );

  Session questionnaireSession() => const Session(
    userId: 7,
    progress: Progress(answered: 0, total: 2),
    nextQuestion: firstQuestion,
  );

  Future<void> setupDi() async {
    await sl.reset();
    sl.registerSingleton<SessionCache>(cache);
    sl.registerLazySingleton<QuestionnaireDraftCache>(
      QuestionnaireDraftCache.new,
    );
    sl.registerLazySingleton<QuestionnaireRepository>(
      () => questionnaireRepository,
    );
    sl.registerLazySingleton<BreedRepository>(() => breedRepository);
    sl.registerFactory(
      () => StartSession(sl<QuestionnaireRepository>(), sl<SessionCache>()),
    );
    sl.registerFactory(() => SubmitAnswer(sl<QuestionnaireRepository>()));
    sl.registerFactory(() => SkipQuestion(sl<QuestionnaireRepository>()));
    sl.registerFactory(() => GetDynamicOptions(sl<QuestionnaireRepository>()));
    sl.registerFactory(() => PollCompatibility(sl<QuestionnaireRepository>()));
    sl.registerFactory(() => GetBreedDetail(sl<BreedRepository>()));
    sl.registerFactory(() => QuestionnaireCubit(sl(), sl(), sl(), sl()));
    sl.registerFactory(() => BreedDetailCubit(sl()));
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    cache = _MockSessionCache();
    questionnaireRepository = _MockQuestionnaireRepository();
    breedRepository = _MockBreedRepository();

    when(cache.hasActiveSession).thenAnswer((_) async => false);
    when(cache.getOrCreateUid).thenAnswer((_) async => 'uid:test');
    when(cache.getSavedUserId).thenAnswer((_) async => null);
    when(() => cache.saveUserId(any())).thenAnswer((_) async {});
    when(cache.clearSession).thenAnswer((_) async {});

    when(
      () => questionnaireRepository.startSession(any()),
    ).thenAnswer((_) async => questionnaireSession());
    when(
      () => questionnaireRepository.getSession(any()),
    ).thenAnswer((_) async => questionnaireSession());

    await setupDi();
  });

  tearDown(() async {
    await sl.reset();
  });

  group('AppRouter redirect', () {
    testWidgets('пустая сессия → стартует на /welcome', (tester) async {
      when(cache.hasActiveSession).thenAnswer((_) async => false);

      await tester.pumpWidget(MaterialApp.router(routerConfig: buildRouter()));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(find.byType(WelcomePage), findsOneWidget);
      expect(find.byType(QuestionnairePage), findsNothing);
    });

    testWidgets(
      'активная сессия + переход на /intro → redirect на /questionnaire',
      (tester) async {
        when(cache.hasActiveSession).thenAnswer((_) async => true);
        when(cache.getSavedUserId).thenAnswer((_) async => 7);

        final router = buildRouter();
        router.go('/intro');
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle(const Duration(milliseconds: 400));

        expect(
          router.routerDelegate.currentConfiguration.uri.path,
          '/questionnaire',
        );
        expect(find.byType(IntroPage), findsNothing);
      },
    );

    testWidgets('пустая сессия + /intro → остаёмся на /intro (без редиректа)', (
      tester,
    ) async {
      when(cache.hasActiveSession).thenAnswer((_) async => false);

      final router = buildRouter();
      router.go('/intro');
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(router.routerDelegate.currentConfiguration.uri.path, '/intro');
      expect(find.byType(IntroPage), findsOneWidget);
    });

    testWidgets('/result без extra → redirect на /welcome', (tester) async {
      when(cache.hasActiveSession).thenAnswer((_) async => false);
      final router = buildRouter();
      router.go('/result');

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(router.routerDelegate.currentConfiguration.uri.path, '/welcome');
      expect(find.byType(WelcomePage), findsOneWidget);
    });
  });
}
