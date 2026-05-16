import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ScoreCalculator {
  static const int masteryThreshold = 80;

  static int calculateMasteryScore({
    required int readingScore,
    required int writingScore,
    required int listeningScore,
    required int speakingScore,
  }) {
    return ((readingScore + writingScore + listeningScore + speakingScore) / 4).round();
  }

  static bool isMastered(int score) => score >= masteryThreshold;

  static String levelFromDifficulty(int difficulty) {
    if (difficulty <= 2) return 'A1';
    if (difficulty <= 4) return 'A2';
    if (difficulty <= 6) return 'B1';
    if (difficulty <= 8) return 'B2';
    return 'C1';
  }

  static Color scoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.accent;
    return AppColors.error;
  }

  static String skillFeedbackLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Mastered';
    if (score >= 60) return 'Getting there';
    if (score >= 40) return 'Needs work';
    return 'Keep practicing';
  }
}
