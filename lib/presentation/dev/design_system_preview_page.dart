import 'package:flutter/material.dart';

import '../../core/design/tokens/alpha.dart';
import '../../core/design/tokens/motion.dart';
import '../../core/design/tokens/radius.dart';
import '../../core/design/tokens/shadows.dart';
import '../../core/design/tokens/sizes.dart';
import '../../core/design/tokens/spacing.dart';
import '../../core/design/tokens/strokes.dart';
import '../../core/theme/app_colors.dart';

/// Визуальный реестр всех дизайн-токенов. Открывается только в dev-сборке
/// (через debug-меню). Цель — быстро увидеть всю палитру, шкалы и сравнить
/// варианты бок о бок при редизайне.
class DesignSystemPreviewPage extends StatelessWidget {
  const DesignSystemPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Design System')),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: const [
          _Section(title: 'Colors', child: _ColorsGrid()),
          SizedBox(height: AppSpacing.xxxxl),
          _Section(title: 'Radius', child: _RadiusRow()),
          SizedBox(height: AppSpacing.xxxxl),
          _Section(title: 'Spacing', child: _SpacingScale()),
          SizedBox(height: AppSpacing.xxxxl),
          _Section(title: 'Shadows', child: _ShadowsRow()),
          SizedBox(height: AppSpacing.xxxxl),
          _Section(title: 'Alpha', child: _AlphaGrid()),
          SizedBox(height: AppSpacing.xxxxl),
          _Section(title: 'Motion', child: _MotionList()),
          SizedBox(height: AppSpacing.xxxxl),
          _Section(title: 'Icon sizes', child: _IconSizes()),
          SizedBox(height: AppSpacing.xxxxl),
          _Section(title: 'Control sizes', child: _ControlSizes()),
          SizedBox(height: AppSpacing.xxxxl),
          _Section(title: 'Strokes', child: _Strokes()),
          SizedBox(height: AppSpacing.xxxxxl),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        child,
      ],
    );
  }
}

class _ColorsGrid extends StatelessWidget {
  const _ColorsGrid();

  static const _entries = <(String, Color)>[
    ('primary', AppColors.primary),
    ('primaryDark', AppColors.primaryDark),
    ('accent', AppColors.accent),
    ('background', AppColors.background),
    ('cream', AppColors.cream),
    ('lavenderTint', AppColors.lavenderTint),
    ('surface', AppColors.surface),
    ('textPrimary', AppColors.textPrimary),
    ('textSecondary', AppColors.textSecondary),
    ('border', AppColors.border),
    ('error', AppColors.error),
    ('warning', AppColors.warning),
    ('warningSurface', AppColors.warningSurface),
    ('warningBorder', AppColors.warningBorder),
    ('overlayDark', AppColors.overlayDark),
    ('onDarkMuted', AppColors.onDarkMuted),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final (name, color) in _entries) _Swatch(name: name, color: color),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.name, required this.color});

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final hex =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
    return SizedBox(
      width: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.border),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            hex,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _RadiusRow extends StatelessWidget {
  const _RadiusRow();

  static const _entries = <(String, double)>[
    ('xs', AppRadius.xs),
    ('sm', AppRadius.sm),
    ('md', AppRadius.md),
    ('lg', AppRadius.lg),
    ('xl', AppRadius.xl),
    ('xxl', AppRadius.xxl),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.xl,
      children: [
        for (final (name, value) in _entries)
          Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(value),
                  border: Border.all(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '$name (${value.toInt()})',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
      ],
    );
  }
}

class _SpacingScale extends StatelessWidget {
  const _SpacingScale();

  static const _entries = <(String, double)>[
    ('xxs', AppSpacing.xxs),
    ('xs', AppSpacing.xs),
    ('sm', AppSpacing.sm),
    ('md', AppSpacing.md),
    ('lg', AppSpacing.lg),
    ('xl', AppSpacing.xl),
    ('xxl', AppSpacing.xxl),
    ('xxxl', AppSpacing.xxxl),
    ('xxxxl', AppSpacing.xxxxl),
    ('xxxxxl', AppSpacing.xxxxxl),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, value) in _entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    '$name (${value.toInt()})',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                Container(height: 16, width: value, color: AppColors.primary),
              ],
            ),
          ),
      ],
    );
  }
}

class _ShadowsRow extends StatelessWidget {
  const _ShadowsRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xxl,
      runSpacing: AppSpacing.xxl,
      children: [
        _shadowDemo('card', AppShadows.card),
        _shadowDemo('elevatedCard', AppShadows.elevatedCard),
        _shadowDemo(
          'elevatedCardSelected',
          AppShadows.elevatedCardSelected(AppColors.primary),
        ),
      ],
    );
  }

  Widget _shadowDemo(String name, List<BoxShadow> shadow) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: shadow,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(name, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _AlphaGrid extends StatelessWidget {
  const _AlphaGrid();

  static const _entries = <(String, double)>[
    ('tintFaint', AppAlpha.tintFaint),
    ('tintSubtle', AppAlpha.tintSubtle),
    ('tintSoft', AppAlpha.tintSoft),
    ('tint', AppAlpha.tint),
    ('borderSubtle', AppAlpha.borderSubtle),
    ('borderMuted', AppAlpha.borderMuted),
    ('mutedHeavy', AppAlpha.mutedHeavy),
    ('muted', AppAlpha.muted),
    ('textOverSurface', AppAlpha.textOverSurface),
    ('divider', AppAlpha.divider),
    ('overlayMid', AppAlpha.overlayMid),
    ('shadowFaint', AppAlpha.shadowFaint),
    ('shadowSoft', AppAlpha.shadowSoft),
    ('shadowMedium', AppAlpha.shadowMedium),
    ('shadowStrong', AppAlpha.shadowStrong),
    ('shadowEmphasis', AppAlpha.shadowEmphasis),
    ('splash', AppAlpha.splash),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final (name, value) in _entries)
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: value),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(name, style: const TextStyle(fontSize: 11)),
                Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MotionList extends StatefulWidget {
  const _MotionList();

  @override
  State<_MotionList> createState() => _MotionListState();
}

class _MotionListState extends State<_MotionList> {
  static const _entries = <(String, Duration)>[
    ('instant', AppMotion.instant),
    ('fast', AppMotion.fast),
    ('normal', AppMotion.normal),
    ('routeIn', AppMotion.routeIn),
    ('routeOut', AppMotion.routeOut),
    ('slow', AppMotion.slow),
    ('scoreTicker', AppMotion.scoreTicker),
    ('heroIntro', AppMotion.heroIntro),
    ('pulse', AppMotion.pulse),
  ];

  String? _animating;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Тапните, чтобы проиграть',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final (name, duration) in _entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: GestureDetector(
              onTap: () async {
                setState(() => _animating = name);
                await Future<void>.delayed(duration);
                if (!mounted) return;
                setState(() => _animating = null);
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      '$name (${duration.inMilliseconds}ms)',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                        ),
                        AnimatedContainer(
                          duration: duration,
                          curve: AppMotion.standardCurve,
                          height: 6,
                          width: _animating == name ? double.infinity : 0,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _IconSizes extends StatelessWidget {
  const _IconSizes();

  static const _entries = <(String, double)>[
    ('sm', AppIconSize.sm),
    ('md', AppIconSize.md),
    ('lg', AppIconSize.lg),
    ('xl', AppIconSize.xl),
    ('xxl', AppIconSize.xxl),
    ('xxxl', AppIconSize.xxxl),
    ('emptyState', AppIconSize.emptyState),
    ('hero', AppIconSize.hero),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.xl,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        for (final (name, size) in _entries)
          Column(
            children: [
              Icon(Icons.star_rounded, size: size, color: AppColors.primary),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '$name (${size.toInt()})',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
      ],
    );
  }
}

class _ControlSizes extends StatelessWidget {
  const _ControlSizes();

  static const _entries = <(String, double)>[
    ('selectorDot', AppControlSize.selectorDot),
    ('lg/spinner', AppControlSize.spinner),
    ('selector', AppControlSize.selector),
    ('brandBadge', AppControlSize.brandBadge),
    ('tapTarget', AppControlSize.tapTarget),
    ('buttonHeight', AppControlSize.buttonHeight),
    ('thumb', AppControlSize.thumb),
    ('heroBadge', AppControlSize.heroBadge),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.xl,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        for (final (name, size) in _entries)
          Column(
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: AppAlpha.tint),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '$name (${size.toInt()})',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
      ],
    );
  }
}

class _Strokes extends StatelessWidget {
  const _Strokes();

  static const _entries = <(String, double)>[
    ('hairline', AppStroke.hairline),
    ('regular', AppStroke.regular),
    ('indicator', AppStroke.indicator),
    ('loader', AppStroke.loader),
    ('strong', AppStroke.strong),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, value) in _entries)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    '$name (${value.toStringAsFixed(1)})',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                Expanded(
                  child: Container(height: value, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
