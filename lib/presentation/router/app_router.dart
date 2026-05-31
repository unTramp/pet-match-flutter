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
import '../test/state_screens_preview_page.dart';
import '../welcome/welcome_page.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.resultPreview,
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
                compatibility: _resultPreviewCompatibility,
              ),
            ),
      ),
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
          if (raw == null || int.tryParse(raw) == null) {
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
              breedId: int.parse(state.pathParameters['id']!),
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

const _resultPreviewCompatibility = Compatibility(
  status: CompatibilityStatus.ready,
  breedId: 501,
  breedName: 'Лабрадор-ретривер',
  score: 0.92,
  risk: CompatibilityRisk.low,
  compatible: true,
  summary:
      'Лабрадор — отличный выбор для активной семьи. Дружелюбный, легко '
      'обучается, прекрасно ладит с детьми и другими питомцами.',
  insights: [
    'Подходит для активного образа жизни.',
    'Дружелюбен к детям и другим животным.',
    'Требует регулярных нагрузок и общения.',
  ],
  requirementHighlights: [
    'Активные прогулки 1+ час в день',
    'Минимальный груминг — расчёсывание 2-3 раза в неделю',
    'Подходит для семей с детьми',
  ],
  suggestions: [
    CompatibilitySuggestion(
      breedId: 502,
      breedName: 'Голден-ретривер',
      score: 0.88,
      risk: CompatibilityRisk.low,
      summary: 'Очень близкий по характеру к лабрадору, чуть спокойнее.',
    ),
    CompatibilitySuggestion(
      breedId: 503,
      breedName: 'Бордер-колли',
      score: 0.81,
      risk: CompatibilityRisk.medium,
      summary: 'Очень умная и активная порода. Требует много занятости.',
    ),
    CompatibilitySuggestion(
      breedId: 504,
      breedName: 'Самоед',
      score: 0.79,
      risk: CompatibilityRisk.medium,
      summary:
          'Дружелюбный и семейный, но требует больше ухода за шерстью и общения.',
    ),
  ],
);

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
