class Lesson {
  final String id;
  final String title;
  final String focusTopic;
  final String? focusSkill;
  final String? youtubeVideoId;
  final int orderIndex;

  Lesson({
    required this.id,
    required this.title,
    required this.focusTopic,
    this.focusSkill,
    this.youtubeVideoId,
    required this.orderIndex,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      focusTopic: json['focus_topic'],
      focusSkill: json['focus_skill'],
      youtubeVideoId: json['youtube_video_id'],
      orderIndex: json['order_index'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'focus_topic': focusTopic,
      'focus_skill': focusSkill,
      'youtube_video_id': youtubeVideoId,
      'order_index': orderIndex,
    };
  }
}

class Module {
  final String id;
  final String title;
  final String? description;
  final String? icon;
  final int orderIndex;
  final int totalLessons;
  final List<Lesson> lessons;

  Module({
    required this.id,
    required this.title,
    this.description,
    this.icon,
    required this.orderIndex,
    required this.totalLessons,
    this.lessons = const [],
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      orderIndex: json['order_index'],
      totalLessons: json['total_lessons'] ?? 0,
      lessons: (json['lessons'] as List? ?? [])
          .map((l) => Lesson.fromJson(l))
          .toList(),
    );
  }
}
