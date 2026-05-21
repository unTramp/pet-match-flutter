import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/cache/session_cache.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/compatibility.dart';
import '../../domain/entities/session.dart';
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
      GoRoute(
        path: '/welcome',
        pageBuilder:
            (context, state) => _buildAppTransitionPage(
              key: state.pageKey,
              child: const WelcomePage(),
            ),
      ),
      GoRoute(
        path: '/intro',
        pageBuilder:
            (context, state) => _buildAppTransitionPage(
              key: state.pageKey,
              child: const IntroPage(),
            ),
      ),
      GoRoute(
        path: '/questionnaire',
        pageBuilder:
            (context, state) => _buildAppTransitionPage(
              key: state.pageKey,
              child: QuestionnairePage(
                initialSession:
                    state.extra is Session ? state.extra as Session : null,
              ),
            ),
      ),
      GoRoute(
        path: '/result',
        redirect:
            (_, state) => state.extra is Compatibility ? null : '/welcome',
        pageBuilder:
            (context, state) => _buildAppTransitionPage(
              key: state.pageKey,
              child: ResultPage(compatibility: state.extra! as Compatibility),
            ),
      ),
      GoRoute(
        path: '/breed/:id',
        redirect: (_, state) {
          final raw = state.pathParameters['id'];
          if (raw == null || int.tryParse(raw) == null) return '/welcome';
          return null;
        },
        pageBuilder:
            (context, state) => _buildAppTransitionPage(
              key: state.pageKey,
              child: BreedDetailPage(
                breedId: int.parse(state.pathParameters['id']!),
              ),
            ),
      ),
      GoRoute(
        path: '/breed/:id/gallery',
        pageBuilder:
            (context, state) => _buildAppTransitionPage(
              key: state.pageKey,
              child: BreedGalleryPage(
                images:
                    (state.extra as List<dynamic>? ?? const <dynamic>[])
                        .cast<String>()
                        .toList(),
              ),
            ),
      ),
    ],
    errorBuilder: (_, __) => const _RouterErrorFallback(),
  );
}

CustomTransitionPage<void> _buildAppTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 240),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.02),
        end: Offset.zero,
      ).animate(fade);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
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
