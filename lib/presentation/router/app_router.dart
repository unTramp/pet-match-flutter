import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/cache/session_cache.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/compatibility.dart';
import '../../domain/entities/session.dart';
import '../analyzing/analyzing_page.dart';
import '../details/breed_detail_page.dart';
import '../details/breed_gallery_page.dart';
import '../intro/intro_page.dart';
import '../questionnaire/questionnaire_page.dart';
import '../result/result_page.dart';
import '../welcome/welcome_page.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) async {
      final hasSession = await sl<SessionCache>().hasActiveSession();
      final isOnboarding =
          state.matchedLocation == '/' || state.matchedLocation == '/intro';
      if (hasSession && isOnboarding) {
        return '/questionnaire';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/welcome'),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomePage()),
      GoRoute(path: '/intro', builder: (_, __) => const IntroPage()),
      GoRoute(
        path: '/questionnaire',
        builder:
            (_, state) => QuestionnairePage(
              initialSession: state.extra is Session ? state.extra as Session : null,
            ),
      ),
      GoRoute(
        path: '/analyzing',
        // extra обязателен; если открыли маршрут без него (deep link,
        // отсутствие state на restore) — мягко уводим на welcome,
        // вместо crash на `state.extra! as int`.
        redirect: (_, state) => state.extra is int ? null : '/welcome',
        builder: (_, state) => AnalyzingPage(userId: state.extra! as int),
      ),
      GoRoute(
        path: '/result',
        redirect:
            (_, state) => state.extra is Compatibility ? null : '/welcome',
        builder:
            (_, state) =>
                ResultPage(compatibility: state.extra! as Compatibility),
      ),
      GoRoute(
        path: '/breed/:id',
        redirect: (_, state) {
          final raw = state.pathParameters['id'];
          if (raw == null || int.tryParse(raw) == null) return '/welcome';
          return null;
        },
        builder:
            (_, state) => BreedDetailPage(
              breedId: int.parse(state.pathParameters['id']!),
            ),
      ),
      GoRoute(
        path: '/breed/:id/gallery',
        builder:
            (_, state) => BreedGalleryPage(
              images:
                  (state.extra as List<dynamic>? ?? const <dynamic>[])
                      .cast<String>()
                      .toList(),
            ),
      ),
    ],
    errorBuilder: (_, __) => const _RouterErrorFallback(),
  );
}

/// Fallback на случай неожиданной ошибки навигации.
class _RouterErrorFallback extends StatelessWidget {
  const _RouterErrorFallback();

  @override
  Widget build(BuildContext context) {
    // Не используем Scaffold, чтобы не тянуть Material — этот экран
    // сразу скрывается redirect'ом.
    return const WelcomePage();
  }
}
