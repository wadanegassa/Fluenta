import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/community.dart';

final roomsProvider = FutureProvider<List<Room>>((ref) async {
  // Mock data for demonstration
  return [
    Room(id: 'r1', name: 'Free Talk', description: 'Just talk. Any topic. Any level.', icon: '💬', memberCount: 1240),
    Room(id: 'r2', name: 'Grammar Help', description: 'Ask grammar questions. Get clear answers.', icon: '📖', memberCount: 850),
    Room(id: 'r3', name: 'Speaking Practice', description: 'Share recordings. Get peer feedback.', icon: '🎙️', memberCount: 2100),
    Room(id: 'r4', name: 'Vocabulary Corner', description: 'Share and learn new words daily.', icon: '🔤', memberCount: 670),
  ];
});
