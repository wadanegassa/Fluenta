import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/lesson_content.dart';
import '../../../../shared/widgets/skill_chip.dart';
import '../lesson_notifier.dart';

class ReadingSection extends ConsumerWidget {
  final LessonContent content;
  final String lessonId;

  const ReadingSection({
    super.key,
    required this.content,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkillChip(skill: 'reading'),
          const SizedBox(height: 16),
          Text("Today's Reading", style: AppTextStyles.h1),
          const SizedBox(height: 24),
          _buildVocabularyPreview(context),
          const SizedBox(height: 32),
          _buildPassageCard(),
          const SizedBox(height: 32),
          Text("Check Your Understanding", style: AppTextStyles.h2),
          const SizedBox(height: 16),
          ...content.readingQuestions.map((q) => _buildQuestion(context, ref, q)).toList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildVocabularyPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Key Vocabulary", style: AppTextStyles.labelMedium),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: content.vocabularyList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = content.vocabularyList[index];
              return ActionChip(
                label: Text(item.word),
                onPressed: () => _showVocabDetail(context, item),
                backgroundColor: AppColors.readingLight,
                labelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.reading),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                side: BorderSide.none,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPassageCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.s24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        content.readingPassage,
        style: AppTextStyles.bodyLarge.copyWith(
          fontFamily: 'Fraunces',
          height: 1.8,
        ),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, WidgetRef ref, ReadingQuestion q) {
    final state = ref.watch(lessonNotifierProvider(lessonId));
    final userAnswer = state.answers[q.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q.question, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (q.type == 'mcq')
            ...q.options!.map((option) {
              final isSelected = userAnswer == option;
              final isCorrect = option == q.answer;
              
              Color borderColor = AppColors.border;
              Color bgColor = AppColors.surfaceWarm;
              
              if (isSelected) {
                if (isCorrect) {
                  borderColor = AppColors.success;
                  bgColor = AppColors.success.withOpacity(0.1);
                } else {
                  borderColor = AppColors.error;
                  bgColor = AppColors.error.withOpacity(0.1);
                }
              }

              return GestureDetector(
                onTap: () => ref.read(lessonNotifierProvider(lessonId).notifier).saveAnswer(q.id, option),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(option, style: AppTextStyles.bodyMedium)),
                      if (isSelected && isCorrect) const Icon(Icons.check_circle, color: AppColors.success),
                      if (isSelected && !isCorrect) const Icon(Icons.cancel, color: AppColors.error),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  void _showVocabDetail(BuildContext context, VocabularyItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.word, style: AppTextStyles.display2.copyWith(color: AppColors.reading)),
            const SizedBox(height: 16),
            Text("DEFINITION", style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text(item.definition, style: AppTextStyles.bodyLarge),
            const SizedBox(height: 24),
            Text("EXAMPLE", style: AppTextStyles.caption),
            const SizedBox(height: 4),
            Text('"${item.example}"', style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
