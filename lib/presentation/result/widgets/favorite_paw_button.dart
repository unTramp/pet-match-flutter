import 'package:flutter/material.dart';

import '../../../core/design/tokens/alpha.dart';
import '../../../core/design/tokens/motion.dart';
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
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, AppAlpha.shadowEmphasis),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                  spreadRadius: -2,
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
                size: 21,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
