import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/cache/session_cache.dart';
import '../../core/design/tokens/motion.dart';
import '../../core/di/injection.dart';
import '../../core/logger.dart';
import '../../core/routing/app_routes.dart';
import '../../domain/entities/compatibility.dart';
import '../../domain/entities/session.dart';
import '../details/breed_detail_page.dart';
import '../details/breed_gallery_page.dart';
import '../intro/intro_page.dart';
import '../questionnaire/questionnaire_page.dart';
import '../result/result_page.dart';
import '../test/preview_fixtures.dart';
import '../test/state_screens_preview_page.dart';
import '../welcome/welcome_page.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final hasSession = await sl<SessionCache>().hasActiveSession();
      final isOnboarding =
          state.matchedLocation == '/' ||
          state.matchedLocation == AppRoutes.intro;
      if (hasSession && isOnboarding) {
        return AppRoutes.questionnaire;
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, __) => AppRoutes.welcome),
      GoRoute(
        path: AppRoutes.welcome,
        pageBuilder:
            (context, state) => _buildAppTransitionPage(
              key: state.pageKey,
              child: const WelcomePage(),
            ),
      ),
      GoRoute(
        path: AppRoutes.intro,
        pageBuilder:
            (context, state) => _buildAppTransitionPage(
              key: state.pageKey,
              child: const IntroPage(),
            ),
      ),
      // Preview-routes доступны только в debug/profile сборках.
      // В release физически отсутствуют в GoRouter — переход даёт
      // `_RouterErrorFallback`, который ведёт на Welcome.
      if (!kReleaseMode) ...[
        GoRoute(
          path: AppRoutes.statePreview,
          pageBuilder:
              (context, state) => _buildAppTransitionPage(
                key: state.pageKey,
                child: const StateScreensPreviewPage(),
              ),
        ),
        GoRoute(
          path: AppRoutes.resultPreview,
          pageBuilder:
              (context, state) => _buildAppTransitionPage(
                key: state.pageKey,
                child: const ResultPage(
                  compatibility: kResultPreviewCompatibility,
                ),
              ),
        ),
      ],
      GoRoute(
        path: AppRoutes.questionnaire,
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
        path: AppRoutes.result,
        redirect:
            (_, state) =>
                state.extra is Compatibility ? null : AppRoutes.welcome,
        pageBuilder:
            (context, state) => _buildAppTransitionPage(
              key: state.pageKey,
              child: ResultPage(compatibility: state.extra! as Compatibility),
            ),
      ),
      GoRoute(
        path: AppRoutes.breedPattern,
        redirect: (_, state) {
          final raw = state.pathParameters['id'];
          if (raw == null || raw.isEmpty) {
            return AppRoutes.welcome;
          }
          return null;
        },
        pageBuilder: (context, state) {
          // Optional match score проносится из Result через GoRoute.extra.
          // Deep-link через `/breed/:id` без extra → score = null, badge скрыт.
          final extra = state.extra;
          final score = extra is double ? extra : null;
          return _buildAppTransitionPage(
            key: state.pageKey,
            child: BreedDetailPage(
              breedId: state.pathParameters['id']!,
              score: score,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.breedGalleryPattern,
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
    errorBuilder: (_, state) {
      appLogger.e(
        'Router error: ${state.uri} — ${state.error}',
        error: state.error,
      );
      return const _RouterErrorFallback();
    },
  );
}

CustomTransitionPage<void> _buildAppTransitionPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: AppMotion.routeIn,
    reverseTransitionDuration: AppMotion.routeOut,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
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
