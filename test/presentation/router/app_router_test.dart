import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_match/core/cache/session_cache.dart';
import 'package:pet_match/core/di/injection.dart';
import 'package:pet_match/core/localization/locale_provider.dart';
import 'package:pet_match/data/repositories/breed_repository_impl.dart';
import 'package:pet_match/data/repositories/questionnaire_repository_impl.dart';
import 'package:pet_match/data/sources/mock_pet_match_remote_source.dart';
import 'package:pet_match/data/sources/pet_match_remote_source.dart';
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

class _MockSessionCache extends Mock implements SessionCache {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockSessionCache cache;

  Future<void> setupDi() async {
    await sl.reset();
    sl.registerSingleton<SessionCache>(cache);
    sl.registerLazySingleton<LocaleProvider>(
      () => const StaticLocaleProvider(Locale('ru')),
    );
    sl.registerLazySingleton<PetMatchRemoteSource>(
      MockPetMatchRemoteSource.new,
    );
    sl.registerLazySingleton<QuestionnaireRepository>(
      () => QuestionnaireRepositoryImpl(sl<PetMatchRemoteSource>()),
    );
    sl.registerLazySingleton<BreedRepository>(
      () => BreedRepositoryImpl(sl<PetMatchRemoteSource>()),
    );
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
    cache = _MockSessionCache();
    // Стабы для всех методов SessionCache которые могут быть вызваны на старте.
    when(cache.hasActiveSession).thenAnswer((_) async => false);
    when(cache.getOrCreateUid).thenAnswer((_) async => 'uid:test');
    when(cache.getSavedUserId).thenAnswer((_) async => null);
    when(() => cache.saveUserId(any())).thenAnswer((_) async {});
    when(cache.clearSession).thenAnswer((_) async {});
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
        // Router-redirect срабатывает на onboarding routes (`/` и `/intro`).
        // Сценарий deep-link: пользователь с сохранённой сессией открывает
        // /intro — должен попасть не на онбординг, а сразу на текущий вопрос.
        // (С /welcome логика resume живёт в самом WelcomePage — там Future
        //  hasActiveSession() меняет лейбл CTA на «Продолжить», redirect не
        //  нужен.)
        when(cache.hasActiveSession).thenAnswer((_) async => true);
        when(cache.getSavedUserId).thenAnswer((_) async => 7);

        final router = buildRouter();
        router.go('/intro');
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        // tester.runAsync даёт mock-source с Future.delayed(250-550ms)
        // отработать, чтобы тест не падал на pending timers (mock source
        // start() триггерится Cubit.start() в QuestionnairePage).
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 800));
        });
        await tester.pumpAndSettle(const Duration(milliseconds: 200));

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
