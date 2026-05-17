import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/community.dart';
import '../../auth/data/auth_provider.dart';

final roomsProvider = FutureProvider<List<Room>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  
  final response = await supabase.from('community_rooms').select().order('name');
  
  return response.map((r) => Room.fromJson(r)).toList();
});
