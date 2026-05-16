import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/lesson.dart';
import '../../auth/data/auth_provider.dart';

final modulesProvider = FutureProvider.family<List<Module>, String>((ref, levelId) async {
  final supabase = ref.watch(supabaseProvider);
  
  // In a real app, we'd fetch from Supabase
  // final data = await supabase.from('modules').select('*, lessons(*)').eq('level_id', levelId).order('order_index');
  // return data.map(Module.fromJson).toList();
  
  // Returning mock data for demonstration
  return [
    Module(
      id: 'm1',
      title: 'Foundation',
      description: 'The basics of communication',
      orderIndex: 0,
      totalLessons: 3,
      lessons: [
        Lesson(id: 'l1', title: 'Meeting New People', focusTopic: 'Greetings', orderIndex: 0, focusSkill: 'speaking'),
        Lesson(id: 'l2', title: 'Daily Routines', focusTopic: 'Present Simple', orderIndex: 1, focusSkill: 'reading'),
        Lesson(id: 'l3', title: 'At the Cafe', focusTopic: 'Ordering Food', orderIndex: 2, focusSkill: 'listening'),
      ],
    ),
    Module(
      id: 'm2',
      title: 'Travel',
      description: 'Navigating the world',
      orderIndex: 1,
      totalLessons: 3,
      lessons: [
        Lesson(id: 'l4', title: 'Airport Essentials', focusTopic: 'Travel Vocabulary', orderIndex: 0, focusSkill: 'listening'),
        Lesson(id: 'l5', title: 'Finding Your Way', focusTopic: 'Directions', orderIndex: 1, focusSkill: 'speaking'),
        Lesson(id: 'l6', title: 'Hotel Stay', focusTopic: 'Booking', orderIndex: 2, focusSkill: 'writing'),
      ],
    ),
  ];
});
