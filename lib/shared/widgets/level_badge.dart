import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';

class LevelBadge extends StatelessWidget {
  final String level;
  final bool isLarge;

  const LevelBadge({
    super.key,
    required this.level,
    this.isLarge = false,
  });

  Color _getLevelColor() {
    switch (level.toUpperCase()) {
      case 'A1':
        return AppColors.reading;
      case 'A2':
        return AppColors.listening;
      case 'B1':
        return AppColors.writing;
      case 'B2':
        return AppColors.speaking;
      case 'C1':
        return AppColors.accent;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getLevelColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? AppDimensions.s16 : AppDimensions.s12,
        vertical: isLarge ? AppDimensions.s8 : AppDimensions.s4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
        boxShadow: isLarge
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Text(
        level.toUpperCase(),
        style: (isLarge ? AppTextStyles.h2 : AppTextStyles.labelMedium).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
