import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/fluenta_button.dart';
import 'lesson_notifier.dart';
import '../../dashboard/data/progress_provider.dart';
import '../../profile/data/profile_provider.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  final String lessonId;

  const AssessmentScreen({super.key, required this.lessonId});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  bool _isChecking = false;
  String? _feedback;
  bool _isPassed = false;

  Future<void> _submitAssessment() async {
    setState(() {
      _isChecking = true;
      _feedback = null;
    });

    final state = ref.read(lessonNotifierProvider(widget.lessonId));
    
    // Calculate breakdowns
    double readingScore = 0;
    int readingTotal = 0;
    for (var q in state.content!.readingQuestions) {
      readingTotal++;
      if (q.type == 'mcq' && state.answers[q.id] == q.answer) {
        readingScore++;
      }
    }

    double listeningScore = 0;
    int listeningTotal = 0;
    for (var e in state.content!.listeningExercises) {
      listeningTotal++;
      if (state.answers[e.id]?.toString().trim().isNotEmpty ?? false) {
        listeningScore++;
      }
    }

    final totalQuestions = readingTotal + listeningTotal;
    final correctCount = readingScore + listeningScore;
    final score = totalQuestions > 0 ? (correctCount / totalQuestions) * 100 : 100;

    await Future.delayed(const Duration(seconds: 1));

    if (score >= 70) {
      setState(() {
        _isPassed = true;
        _feedback = "Great job! You've mastered this lesson with a score of ${score.toInt()}%.";
      });

      // Update averages in profile
      final currentProfile = ref.read(profileProvider).value;
      if (currentProfile != null) {
        final rAvg = readingTotal > 0 ? (readingScore / readingTotal) * 100 : currentProfile.readingAvg.toDouble();
        final lAvg = listeningTotal > 0 ? (listeningScore / listeningTotal) * 100 : currentProfile.listeningAvg.toDouble();
        
        // Simple moving average (50/50 for demonstration, or could be more complex)
        await ref.read(profileProvider.notifier).updateProfile(
          readingAvg: ((currentProfile.readingAvg + rAvg) / 2).toInt(),
          listeningAvg: ((currentProfile.listeningAvg + lAvg) / 2).toInt(),
        );
      }

      // Unlock next lesson
      await ref.read(progressActionProvider).unlockNextLesson(widget.lessonId);
    } else {
      setState(() {
        _isPassed = false;
        _feedback = "You scored ${score.toInt()}%. Try reviewing the content and answering again to pass.";
      });
    }

    setState(() {
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Lesson Assessment"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.s24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              if (_feedback == null) ...[
                const Icon(Icons.assignment_turned_in_outlined, size: 80, color: AppColors.primary),
                const SizedBox(height: 24),
                Text("Ready to finish?", style: AppTextStyles.h1),
                const SizedBox(height: 16),
                Text(
                  "We'll check your answers to see if you're ready for the next lesson.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 40),
                FluentaButton(
                  text: "Submit My Answers",
                  onPressed: _isChecking ? null : _submitAssessment,
                  isLoading: _isChecking,
                ),
              ] else ...[
                Icon(
                  _isPassed ? Icons.check_circle_outline : Icons.error_outline,
                  size: 80,
                  color: _isPassed ? AppColors.success : AppColors.error,
                ),
                const SizedBox(height: 24),
                Text(_isPassed ? "Congratulations!" : "Keep Practicing!", style: AppTextStyles.h1),
                const SizedBox(height: 16),
                Text(
                  _feedback!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 40),
                if (_isPassed)
                  FluentaButton(
                    text: "Back to Curriculum",
                    onPressed: () => context.go('/lessons'),
                  )
                else
                  FluentaButton(
                    text: "Review Lesson",
                    onPressed: () => Navigator.pop(context),
                    variant: FluentaButtonVariant.outlined,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
