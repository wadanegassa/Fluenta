import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/lesson_content.dart';
import '../../../../shared/widgets/skill_chip.dart';
import '../lesson_notifier.dart';

class WritingSection extends ConsumerWidget {
  final LessonContent content;
  final String lessonId;

  const WritingSection({
    super.key,
    required this.content,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonNotifierProvider(lessonId));
    final userAnswer = state.answers['writing_submission'] ?? '';
    final wordCount = userAnswer.toString().trim().isEmpty ? 0 : userAnswer.toString().trim().split(RegExp(r'\s+')).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkillChip(skill: 'writing'),
          const SizedBox(height: 16),
          Text("Writing Task", style: AppTextStyles.h1),
          const SizedBox(height: 24),
          _buildPromptCard(),
          const SizedBox(height: 32),
          TextField(
            maxLines: 10,
            minLines: 6,
            onChanged: (v) => ref.read(lessonNotifierProvider(lessonId).notifier).saveAnswer('writing_submission', v),
            decoration: InputDecoration(
              hintText: "Start writing here...",
              fillColor: AppColors.surfaceWarm,
              counterText: "$wordCount words",
              counterStyle: AppTextStyles.caption,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPromptCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s24),
      decoration: BoxDecoration(
        color: AppColors.writingLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: const Border(
          left: BorderSide(color: AppColors.writing, width: 4),
        ),
      ),
      child: Text(
        content.writingPrompt,
        style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
      ),
    );
  }
}
