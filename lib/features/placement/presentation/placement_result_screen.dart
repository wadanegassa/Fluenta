import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/fluenta_button.dart';
import '../../../shared/widgets/level_badge.dart';

class PlacementResultScreen extends StatelessWidget {
  final String level;
  final String feedback;

  const PlacementResultScreen({
    super.key,
    required this.level,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.s24, vertical: AppDimensions.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              LevelBadge(level: level, isLarge: true),
              const SizedBox(height: 24),
              Text(
                "Your Diagnostic Level",
                style: AppTextStyles.h3.copyWith(color: Colors.white70),
              ),
              Text(
                "Level $level",
                style: AppTextStyles.display1.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              
              // Beautiful Frosted Feedback Card showing the dynamic Gemini assessor feedback
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.s24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.analytics, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              "AI Assessment Feedback",
                              style: AppTextStyles.h3.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          feedback.isNotEmpty
                              ? feedback
                              : "Excellent job completing the exam! You demonstrated a good understanding of English syntax and structure. We have prepared a customized curriculum map matching your grammar, vocabulary, writing, and speaking proficiencies.",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.85),
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              FluentaButton(
                text: "Begin Your Learning Roadmap",
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
