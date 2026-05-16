import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/fluenta_button.dart';
import '../../../shared/widgets/level_badge.dart';
import '../../../shared/widgets/skill_progress_bar.dart';

class PlacementResultScreen extends StatelessWidget {
  final String level;

  const PlacementResultScreen({super.key, required this.level});

  String _getLevelDescription() {
    switch (level.toUpperCase()) {
      case 'A1':
        return "You are just starting your English journey. We'll help you build a strong foundation.";
      case 'A2':
        return "You know the basics and are building confidence. Let's expand your vocabulary.";
      case 'B1':
        return "You can handle everyday conversations. Time to work on more complex structures.";
      case 'B2':
        return "You are becoming fluent and comfortable. We'll focus on nuance and clarity.";
      case 'C1':
        return "You speak with clarity, nuance, and fluency. Let's reach for perfection.";
      default:
        return "Welcome to Fluenta!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              LevelBadge(level: level, isLarge: true),
              const SizedBox(height: 32),
              Text(
                "You are $level",
                style: AppTextStyles.display1.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                _getLevelDescription(),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
              _buildSkillOverview(),
              const Spacer(),
              FluentaButton(
                text: "Begin Your Journey",
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillOverview() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: const Column(
        children: [
          SkillProgressBar(
            skillName: 'Reading',
            progress: 0.65,
            color: AppColors.reading,
          ),
          SizedBox(height: 20),
          SkillProgressBar(
            skillName: 'Listening',
            progress: 0.45,
            color: AppColors.listening,
          ),
          SizedBox(height: 20),
          SkillProgressBar(
            skillName: 'Writing',
            progress: 0.55,
            color: AppColors.writing,
          ),
          SizedBox(height: 20),
          SkillProgressBar(
            skillName: 'Speaking',
            progress: 0.35,
            color: AppColors.speaking,
          ),
        ],
      ),
    );
  }
}
