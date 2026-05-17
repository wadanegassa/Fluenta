import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/auth_provider.dart';

class LessonProgress {
  final String lessonId;
  final bool isUnlocked;
  final bool isMastered;

  LessonProgress({
    required this.lessonId,
    required this.isUnlocked,
    required this.isMastered,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      lessonId: json['lesson_id'],
      isUnlocked: json['is_unlocked'] ?? false,
      isMastered: json['is_mastered'] ?? false,
    );
  }
}

final userProgressProvider = StreamProvider<List<LessonProgress>>((ref) {
  final supabase = ref.watch(supabaseProvider);
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) return Stream.value([]);

  return supabase
      .from('user_lesson_progress')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .map((data) => data.map((json) => LessonProgress.fromJson(json)).toList());
});

class ProgressNotifier extends StateNotifier<void> {
  final SupabaseClient _supabase;

  ProgressNotifier(this._supabase) : super(null);

  Future<void> unlockNextLesson(String currentLessonId) async {
    final userId = _supabase.auth.currentUser!.id;

    // 1. Mark current as mastered
    await _supabase.from('user_lesson_progress').upsert({
      'user_id': userId,
      'lesson_id': currentLessonId,
      'is_mastered': true,
      'is_unlocked': true,
      'mastered_at': DateTime.now().toIso8601String(),
    });

    // 2. Update Profile Stats (lessons mastered)
    final profile = await _supabase.from('profiles').select().eq('id', userId).single();
    await _supabase.from('profiles').update({
      'total_lessons_mastered': (profile['total_lessons_mastered'] ?? 0) + 1,
    }).eq('id', userId);

    // 3. Find next lesson
    final currentLesson = await _supabase
        .from('lessons')
        .select('*, modules!inner(*)')
        .eq('id', currentLessonId)
        .single();

    final moduleId = currentLesson['module_id'];
    final nextOrderIndex = currentLesson['order_index'] + 1;
    final currentLevel = currentLesson['modules']['level_id'];

    // Try finding next lesson in same module
    final nextLesson = await _supabase
        .from('lessons')
        .select()
        .eq('module_id', moduleId)
        .eq('order_index', nextOrderIndex)
        .maybeSingle();

    if (nextLesson != null) {
      await _supabase.from('user_lesson_progress').upsert({
        'user_id': userId,
        'lesson_id': nextLesson['id'],
        'is_unlocked': true,
      });
    } else {
      // Try finding next module
      final nextModule = await _supabase
          .from('modules')
          .select()
          .eq('level_id', currentLevel)
          .eq('order_index', currentLesson['modules']['order_index'] + 1)
          .maybeSingle();

      if (nextModule != null) {
        final firstLessonNextModule = await _supabase
            .from('lessons')
            .select()
            .eq('module_id', nextModule['id'])
            .eq('order_index', 0)
            .maybeSingle();

        if (firstLessonNextModule != null) {
          await _supabase.from('user_lesson_progress').upsert({
            'user_id': userId,
            'lesson_id': firstLessonNextModule['id'],
            'is_unlocked': true,
          });
        }
      } else {
        // LEVEL COMPLETE!
        await _promoteLevel(userId, currentLevel);
      }
    }
  }

  Future<void> _promoteLevel(String userId, String currentLevel) async {
    const levels = ['A1', 'A2', 'B1', 'B2', 'C1'];
    final currentIndex = levels.indexOf(currentLevel);
    
    if (currentIndex != -1 && currentIndex < levels.length - 1) {
      final nextLevel = levels[currentIndex + 1];
      await _supabase.from('profiles').update({
        'level': nextLevel,
      }).eq('id', userId);
      
      // Trigger curriculum generation for the new level
      await _supabase.functions.invoke('generate-curriculum', body: {'levelId': nextLevel});
    }
  }
}

final progressActionProvider = Provider((ref) {
  final supabase = ref.watch(supabaseProvider);
  return ProgressNotifier(supabase);
});
