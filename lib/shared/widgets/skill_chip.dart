import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SkillChip extends StatelessWidget {
  final String skill;

  const SkillChip({
    super.key,
    required this.skill,
  });

  (Color, Color) _getColors() {
    switch (skill.toLowerCase()) {
      case 'reading':
        return (AppColors.reading, AppColors.readingLight);
      case 'writing':
        return (AppColors.writing, AppColors.writingLight);
      case 'listening':
        return (AppColors.listening, AppColors.listeningLight);
      case 'speaking':
        return (AppColors.speaking, AppColors.speakingLight);
      default:
        return (AppColors.primary, AppColors.primarySurface);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = _getColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        skill.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
