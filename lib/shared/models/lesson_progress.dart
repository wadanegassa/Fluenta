class LessonProgress {
  final String lessonId;
  final bool isUnlocked;
  final bool isMastered;
  final int masteryScore;
  final int attempts;
  final int readingScore;
  final int writingScore;
  final int listeningScore;
  final int speakingScore;

  LessonProgress({
    required this.lessonId,
    required this.isUnlocked,
    required this.isMastered,
    required this.masteryScore,
    required this.attempts,
    required this.readingScore,
    required this.writingScore,
    required this.listeningScore,
    required this.speakingScore,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      lessonId: json['lesson_id'],
      isUnlocked: json['is_unlocked'] ?? false,
      isMastered: json['is_mastered'] ?? false,
      masteryScore: json['mastery_score'] ?? 0,
      attempts: json['attempts'] ?? 0,
      readingScore: json['reading_score'] ?? 0,
      writingScore: json['writing_score'] ?? 0,
      listeningScore: json['listening_score'] ?? 0,
      speakingScore: json['speaking_score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lesson_id': lessonId,
      'is_unlocked': isUnlocked,
      'is_mastered': isMastered,
      'mastery_score': masteryScore,
      'attempts': attempts,
      'reading_score': readingScore,
      'writing_score': writingScore,
      'listening_score': listeningScore,
      'speaking_score': speakingScore,
    };
  }
}
