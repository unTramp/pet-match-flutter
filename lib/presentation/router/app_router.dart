import 'package:go_router/go_router.dart';

import '../../core/cache/session_cache.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/compatibility.dart';
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
        builder: (_, __) => const QuestionnairePage(),
      ),
      GoRoute(
        path: '/analyzing',
        builder: (_, state) => AnalyzingPage(userId: state.extra! as int),
      ),
      GoRoute(
        path: '/result',
        builder:
            (_, state) =>
                ResultPage(compatibility: state.extra! as Compatibility),
      ),
      GoRoute(
        path: '/breed/:id',
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
                  (state.extra as List<dynamic>? ?? const [])
                      .cast<String>()
                      .toList(),
            ),
      ),
    ],
  );
}
