import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/lesson_content.dart';
import '../../../../shared/widgets/skill_chip.dart';
import '../lesson_notifier.dart';

class ListeningSection extends StatelessWidget {
  final LessonContent content;
  final String lessonId;
  final String? youtubeVideoId;

  const ListeningSection({
    super.key,
    required this.content,
    required this.lessonId,
    this.youtubeVideoId,
  });

  @override
  Widget build(BuildContext context) {
    return _ListeningContent(
      content: content,
      lessonId: lessonId,
      youtubeVideoId: youtubeVideoId,
      isMissing: youtubeVideoId == null || youtubeVideoId!.trim().isEmpty,
    );
  }
}

class _ListeningContent extends ConsumerWidget {
  final LessonContent content;
  final String lessonId;
  final String? youtubeVideoId;
  final bool isMissing;

  const _ListeningContent({
    required this.content,
    required this.lessonId,
    required this.youtubeVideoId,
    required this.isMissing,
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
          _buildVideoPlayer(context),
          const SizedBox(height: 32),
          _buildTranscriptCard(),
          const SizedBox(height: 32),
          
          // "Write what you understand" Section
          _buildSummarySection(context, ref),
          const SizedBox(height: 32),
          
          // "Answer those questions" Section
          Text("Answer the Questions", style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            "Test your comprehension based on the video content.",
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ...content.listeningExercises.map((e) => _buildExercise(context, ref, e)).toList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    if (isMissing || youtubeVideoId == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.s24),
        decoration: BoxDecoration(
          color: AppColors.surfaceWarm,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(Icons.videocam_off_outlined, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              "Video Unavailable",
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "We couldn't find a video for this specific lesson. Please use the transcript below to complete the exercises.",
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final thumbnailUrl = 'https://img.youtube.com/vi/$youtubeVideoId/hqdefault.jpg';
    final videoUrl = 'https://www.youtube.com/watch?v=$youtubeVideoId';

    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(videoUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(uri);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Beautiful Thumbnail
              CachedNetworkImage(
                imageUrl: thumbnailUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: AppColors.surfaceWarm,
                  child: const Center(child: Icon(Icons.error)),
                ),
              ),
              
              // Dark gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.65),
                      ],
                    ),
                  ),
                ),
              ),

              // Glowing Play Button Overlay
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 36,
                  color: Colors.red,
                ),
              ),

              // Video info details at the bottom
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Watch Lesson Video",
                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.open_in_new, size: 14, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(
                          "Tap to play natively on YouTube",
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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

  Widget _buildSummarySection(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonNotifierProvider(lessonId));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, color: AppColors.primary, size: 28),
              const SizedBox(width: 8),
              Text("Write What You Understand", style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Write a short summary in English explaining what you understood from the video.",
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            maxLines: 4,
            onChanged: (v) => ref.read(lessonNotifierProvider(lessonId).notifier).saveAnswer('listening_summary', v),
            decoration: InputDecoration(
              hintText: "E.g., In this video, I learned that when greeting someone for the first time, it's polite to...",
              fillColor: Colors.white,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercise(BuildContext context, WidgetRef ref, ListeningExercise e) {
    final state = ref.watch(lessonNotifierProvider(lessonId));
    final showHint = state.answers['show_hint_${e.id}'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(e.question, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => ref.read(lessonNotifierProvider(lessonId).notifier).saveAnswer(e.id, v),
            decoration: InputDecoration(
              hintText: "Type your answer here...",
              fillColor: Colors.white,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  ref.read(lessonNotifierProvider(lessonId).notifier).saveAnswer(
                    'show_hint_${e.id}',
                    !showHint,
                  );
                },
                icon: Icon(showHint ? Icons.visibility_off : Icons.help_outline, size: 18),
                label: Text(showHint ? "Hide Model Answer" : "Compare with Model Answer"),
              ),
            ],
          ),
          if (showHint)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.listeningLight,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Model Answer:", style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(e.modelAnswer, style: AppTextStyles.bodyMedium),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
