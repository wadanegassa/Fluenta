import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/lesson.dart';
import '../../auth/data/auth_provider.dart';

final modulesProvider = FutureProvider.family<List<Module>, String>((ref, levelId) async {
  final supabase = ref.watch(supabaseProvider);
  
  // 1. Fetch modules and lessons for this level
  final response = await supabase
      .from('modules')
      .select('*, lessons(*)')
      .eq('level_id', levelId)
      .order('order_index', ascending: true)
      .order('order_index', referencedTable: 'lessons', ascending: true);
  
  if (response.isNotEmpty) {
    return response.map((m) => Module.fromJson(m)).toList();
  }

  // 2. If empty, trigger curriculum generation via AI
  try {
    await supabase.functions.invoke('generate-curriculum', body: {'levelId': levelId});
    
    // 3. Re-fetch after generation
    final retryResponse = await supabase
        .from('modules')
        .select('*, lessons(*)')
        .eq('level_id', levelId)
        .order('order_index', ascending: true)
        .order('order_index', referencedTable: 'lessons', ascending: true);
    
    return retryResponse.map((m) => Module.fromJson(m)).toList();
  } catch (e) {
    // If generation fails, return empty list or handle error
    return [];
  }
});
