import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/lesson_content.dart';

class LessonState {
  final int currentSection; // 0: Reading, 1: Listening, 2: Writing, 3: Speaking
  final LessonContent? content;
  final String? youtubeVideoId;
  final String? level;
  final String? topic;
  final bool isLoading;
  final Map<String, dynamic> answers;

  LessonState({
    this.currentSection = 0,
    this.content,
    this.youtubeVideoId,
    this.level,
    this.topic,
    this.isLoading = false,
    this.answers = const {},
  });

  LessonState copyWith({
    int? currentSection,
    LessonContent? content,
    String? youtubeVideoId,
    String? level,
    String? topic,
    bool? isLoading,
    Map<String, dynamic>? answers,
  }) {
    return LessonState(
      currentSection: currentSection ?? this.currentSection,
      content: content ?? this.content,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      level: level ?? this.level,
      topic: topic ?? this.topic,
      isLoading: isLoading ?? this.isLoading,
      answers: answers ?? this.answers,
    );
  }
}

final lessonNotifierProvider = StateNotifierProvider.family<LessonNotifier, LessonState, String>((ref, lessonId) {
  return LessonNotifier(lessonId);
});

class LessonNotifier extends StateNotifier<LessonState> {
  final String lessonId;

  LessonNotifier(this.lessonId) : super(LessonState()) {
    _loadContent();
  }

  Future<void> _loadContent() async {
    state = state.copyWith(isLoading: true);
    
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser!.id;

    try {
      // 1. Fetch lesson details to provide context to AI (and ensure videoId is always loaded)
      final lessonData = await supabase
          .from('lessons')
          .select('*, modules(level_id)')
          .eq('id', lessonId)
          .single();

      final level = lessonData['modules']['level_id'];
      final topic = lessonData['focus_topic'];
      final focusSkill = lessonData['focus_skill'];
      final videoId = lessonData['youtube_video_id'];
      final videoTitle = lessonData['youtube_video_title'];

      // Update state with details early
      state = state.copyWith(
        youtubeVideoId: videoId,
        level: level,
        topic: topic,
      );

      // 2. Try to fetch existing content
      final existingContent = await supabase
          .from('lesson_content')
          .select()
          .eq('lesson_id', lessonId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingContent != null) {
        state = state.copyWith(
          content: LessonContent.fromJson(existingContent),
          isLoading: false,
        );
        return;
      }

      // 3. Generate content via AI
      final response = await supabase.functions.invoke('generate-lesson', body: {
        'level': level,
        'topic': topic,
        'focusSkill': focusSkill,
        'youtubeVideoTitle': videoTitle,
      });

      final generatedJson = response.data;
      
      if (generatedJson == null || generatedJson['error'] != null) {
        throw Exception(generatedJson?['error'] ?? 'No content returned from AI');
      }
      
      // 4. Save generated content
      await supabase.from('lesson_content').insert({
        'lesson_id': lessonId,
        'user_id': userId,
        ...generatedJson,
      });

      state = state.copyWith(
        content: LessonContent.fromJson(generatedJson),
        isLoading: false,
      );
    } catch (e, stack) {
      print('DEBUG: Lesson load error: $e');
      print('DEBUG: Stack trace: $stack');
      state = state.copyWith(isLoading: false);
    }
  }

  void setSection(int section) {
    state = state.copyWith(currentSection: section);
  }

  void saveAnswer(String id, dynamic value) {
    final newAnswers = Map<String, dynamic>.from(state.answers);
    newAnswers[id] = value;
    state = state.copyWith(answers: newAnswers);
  }
}
