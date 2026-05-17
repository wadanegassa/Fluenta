import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/fluenta_button.dart';
import '../../../shared/widgets/level_badge.dart';
import '../../../shared/widgets/skill_chip.dart';
import 'placement_provider.dart';

class PlacementScreen extends ConsumerWidget {
  const PlacementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(placementProvider);
    final notifier = ref.read(placementProvider.notifier);

    if (state.isFinished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/placement/result', extra: state.estimatedLevel);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.isLoading || state.currentQuestion == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Preparing your next challenge...", style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      );
    }

    final currentQuestion = state.currentQuestion!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: (state.currentQuestionIndex + 1) / PlacementNotifier.totalQuestions,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "QUESTION ${state.currentQuestionIndex + 1} OF ${PlacementNotifier.totalQuestions}",
              style: AppTextStyles.caption.copyWith(letterSpacing: 1.2),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SkillChip(skill: currentQuestion.skill),
                  LevelBadge(level: state.estimatedLevel),
                ],
              ),
              const SizedBox(height: AppDimensions.s32),
              Text(
                currentQuestion.text,
                style: AppTextStyles.display2,
              ),
              const SizedBox(height: AppDimensions.s48),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: currentQuestion.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final option = currentQuestion.options[index];
                  return _OptionCard(
                    text: option,
                    onTap: () => notifier.submitAnswer(
                      currentQuestion.id,
                      option == currentQuestion.correctAnswer,
                      userAnswer: option,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _OptionCard({required this.text, required this.onTap});

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isSelected = true);
        Future.delayed(const Duration(milliseconds: 400), widget.onTap);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppDimensions.s20),
        decoration: BoxDecoration(
          color: _isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: _isSelected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.text,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (_isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
