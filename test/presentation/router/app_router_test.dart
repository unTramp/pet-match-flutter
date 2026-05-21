import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_match/core/cache/session_cache.dart';
import 'package:pet_match/core/di/injection.dart';
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
    if (sl.isRegistered<SessionCache>()) await sl.reset();
    await configureDependencies();
    // Перезатираем SessionCache моком — остальной DI (Mock-source, repos,
    // usecases) остаётся реальным mock-стеком, чтобы Cubit'ы могли
    // зарегистрироваться без падений.
    sl.unregister<SessionCache>();
    sl.registerSingleton<SessionCache>(cache);
    // Cubit factories — обычно в main.dart, здесь делаем то же самое.
    if (!sl.isRegistered<QuestionnaireCubit>()) {
      sl.registerFactory(() => QuestionnaireCubit(sl(), sl(), sl()));
    }
    if (!sl.isRegistered<BreedDetailCubit>()) {
      sl.registerFactory(() => BreedDetailCubit(sl()));
    }
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

      await tester.pumpWidget(
        MaterialApp.router(routerConfig: buildRouter()),
      );
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

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        '/intro',
      );
      expect(find.byType(IntroPage), findsOneWidget);
    });

    testWidgets('/analyzing без extra → redirect на /welcome', (tester) async {
      when(cache.hasActiveSession).thenAnswer((_) async => false);
      final router = buildRouter();
      router.go('/analyzing'); // extra=null

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        '/welcome',
      );
      expect(find.byType(WelcomePage), findsOneWidget);
    });

    testWidgets('/result без extra → redirect на /welcome', (tester) async {
      when(cache.hasActiveSession).thenAnswer((_) async => false);
      final router = buildRouter();
      router.go('/result');

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(
        router.routerDelegate.currentConfiguration.uri.path,
        '/welcome',
      );
      expect(find.byType(WelcomePage), findsOneWidget);
    });
  });
}
