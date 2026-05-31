import 'package:flutter/material.dart';

import '../../../core/design/tokens/alpha.dart';
import '../../../core/design/tokens/motion.dart';
import '../../../core/design/tokens/strokes.dart';
import '../../../core/theme/app_colors.dart';

class FavoritePawButton extends StatefulWidget {
  const FavoritePawButton({super.key});

  @override
  State<FavoritePawButton> createState() => _FavoritePawButtonState();
}

class _FavoritePawButtonState extends State<FavoritePawButton> {
  bool _isFavorite = false;

  void _toggle() {
    setState(() => _isFavorite = !_isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      toggled: _isFavorite,
      label: _isFavorite ? 'Убрать из избранного' : 'Добавить в избранное',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggle,
          customBorder: const CircleBorder(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border.withValues(alpha: AppAlpha.borderSubtle),
                width: AppStroke.hairline,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, AppAlpha.shadowMedium),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                  spreadRadius: -4,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              transitionBuilder:
                  (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
              child: Icon(
                _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey<bool>(_isFavorite),
                size: 19,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
