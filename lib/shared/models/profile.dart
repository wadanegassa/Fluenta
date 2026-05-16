class Profile {
  final String id;
  final String fullName;
  final String level;
  final String? nativeLanguage;
  final String? goal;
  final String? avatarUrl;
  final int streakDays;
  final int readingAvg;
  final int writingAvg;
  final int listeningAvg;
  final int speakingAvg;
  final int totalLessonsMastered;
  final DateTime? lastActive;
  final DateTime? createdAt;

  Profile({
    required this.id,
    required this.fullName,
    required this.level,
    this.nativeLanguage,
    this.goal,
    this.avatarUrl,
    required this.streakDays,
    required this.readingAvg,
    required this.writingAvg,
    required this.listeningAvg,
    required this.speakingAvg,
    required this.totalLessonsMastered,
    this.lastActive,
    this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      fullName: json['full_name'],
      level: json['level'],
      nativeLanguage: json['native_language'],
      goal: json['goal'],
      avatarUrl: json['avatar_url'],
      streakDays: json['streak_days'] ?? 0,
      readingAvg: json['reading_avg'] ?? 0,
      writingAvg: json['writing_avg'] ?? 0,
      listeningAvg: json['listening_avg'] ?? 0,
      speakingAvg: json['speaking_avg'] ?? 0,
      totalLessonsMastered: json['total_lessons_mastered'] ?? 0,
      lastActive: json['last_active'] != null
          ? DateTime.parse(json['last_active'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'level': level,
      'native_language': nativeLanguage,
      'goal': goal,
      'avatar_url': avatarUrl,
      'streak_days': streakDays,
      'reading_avg': readingAvg,
      'writing_avg': writingAvg,
      'listening_avg': listeningAvg,
      'speaking_avg': speakingAvg,
      'total_lessons_mastered': totalLessonsMastered,
      'last_active': lastActive?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
