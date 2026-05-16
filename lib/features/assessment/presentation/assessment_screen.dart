import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/fluenta_button.dart';
import '../../../shared/widgets/score_badge.dart';

class AssessmentScreen extends StatefulWidget {
  final String lessonId;

  const AssessmentScreen({super.key, required this.lessonId});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  bool _isFinished = false;
  final int _score = 87; // Mock score

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildResultScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Lesson Check"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.s24),
        child: Column(
          children: [
            const Spacer(),
            Text(
              "Ready to show what you've learned?",
              style: AppTextStyles.display2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Complete this short assessment to unlock the next lesson. You need at least 80% to pass.",
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            FluentaButton(
              text: "Start Assessment",
              onPressed: () {
                // In a real app, this would show questions
                setState(() => _isFinished = true);
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text("Review Lesson Again"),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final bool passed = _score >= 80;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                passed ? Icons.stars : Icons.info_outline,
                size: 80,
                color: passed ? AppColors.success : AppColors.accent,
              ),
              const SizedBox(height: 24),
              Text(
                passed ? "Lesson Mastered!" : "Almost There!",
                style: AppTextStyles.display1,
              ),
              const SizedBox(height: 48),
              ScoreBadge(score: _score, size: 120),
              const SizedBox(height: 48),
              _buildStatsRow(),
              const Spacer(),
              FluentaButton(
                text: passed ? "Next Lesson" : "Try Again",
                onPressed: () => context.go('/home'),
              ),
              if (!passed) ...[
                const SizedBox(height: 16),
                FluentaButton(
                  text: "Review Lesson",
                  variant: FluentaButtonVariant.outlined,
                  onPressed: () => context.pop(),
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem("Reading", "90%"),
        _buildStatItem("Listening", "85%"),
        _buildStatItem("Writing", "80%"),
        _buildStatItem("Speaking", "92%"),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.labelLarge),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
