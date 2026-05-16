import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/lesson_content.dart';
import '../../../../shared/widgets/skill_chip.dart';
import '../lesson_notifier.dart';

class ListeningSection extends ConsumerWidget {
  final LessonContent content;
  final String lessonId;

  const ListeningSection({
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
          const SkillChip(skill: 'listening'),
          const SizedBox(height: 16),
          Text("Listening Practice", style: AppTextStyles.h1),
          const SizedBox(height: 24),
          _buildVideoPlaceholder(),
          const SizedBox(height: 32),
          _buildTranscriptCard(),
          const SizedBox(height: 32),
          Text("Fill in the Blanks", style: AppTextStyles.h2),
          const SizedBox(height: 16),
          ...content.listeningExercises.map((e) => _buildExercise(context, ref, e)).toList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
              SizedBox(height: 8),
              Text("YouTube Video Player", style: TextStyle(color: Colors.white54)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranscriptCard() {
    return ExpansionTile(
      title: Text("Show Transcript", style: AppTextStyles.labelMedium),
      childrenPadding: const EdgeInsets.all(16),
      collapsedBackgroundColor: AppColors.listeningLight,
      backgroundColor: AppColors.listeningLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLarge)),
      children: [
        Text(content.listeningTranscript, style: AppTextStyles.bodyMedium),
      ],
    );
  }

  Widget _buildExercise(BuildContext context, WidgetRef ref, ListeningExercise e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.sentenceWithBlank.replaceAll('_____', '[ ____ ]'), style: AppTextStyles.bodyLarge),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => ref.read(lessonNotifierProvider(lessonId).notifier).saveAnswer(e.id, v),
            decoration: InputDecoration(
              hintText: "Type your answer...",
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
            ),
          ),
        ],
      ),
    );
  }
}
