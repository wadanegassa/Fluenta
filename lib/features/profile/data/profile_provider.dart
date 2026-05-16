import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/profile.dart';
import '../../auth/data/auth_provider.dart';

final profileProvider = FutureProvider<Profile?>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final user = supabase.auth.currentUser;
  
  if (user == null) return null;

  final data = await supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();
      
  if (data == null) return null;
  return Profile.fromJson(data);
});
