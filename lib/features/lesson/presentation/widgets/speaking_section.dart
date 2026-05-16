import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/lesson_content.dart';
import '../../../../shared/widgets/skill_chip.dart';
import '../lesson_notifier.dart';

class SpeakingSection extends StatefulWidget {
  final LessonContent content;
  final String lessonId;

  const SpeakingSection({
    super.key,
    required this.content,
    required this.lessonId,
  });

  @override
  State<SpeakingSection> createState() => _SpeakingSectionState();
}

class _SpeakingSectionState extends State<SpeakingSection> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkillChip(skill: 'speaking'),
          const SizedBox(height: 16),
          Text("Speaking Exercise", style: AppTextStyles.h1),
          const SizedBox(height: 24),
          _buildPromptCard(),
          const SizedBox(height: 64),
          Center(child: _buildRecordButton()),
          const SizedBox(height: 24),
          Center(
            child: Text(
              _isRecording ? "Recording... tap to stop" : "Tap to record your response",
              style: AppTextStyles.bodyMedium.copyWith(
                color: _isRecording ? AppColors.error : AppColors.textSecondary,
              ),
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
        color: AppColors.speakingLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        border: const Border(
          left: BorderSide(color: AppColors.speaking, width: 4),
        ),
      ),
      child: Text(
        widget.content.speakingPrompt,
        style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
      ),
    );
  }

  Widget _buildRecordButton() {
    return GestureDetector(
      onTap: () => setState(() => _isRecording = !_isRecording),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isRecording)
            FadeTransition(
              opacity: _pulseController,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withOpacity(0.2),
                ),
              ),
            ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isRecording ? AppColors.error : AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? AppColors.error : AppColors.primary).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}
