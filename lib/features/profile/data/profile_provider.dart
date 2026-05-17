import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/profile.dart';
import '../../auth/data/auth_provider.dart';

class ProfileNotifier extends AsyncNotifier<Profile?> {
  @override
  Future<Profile?> build() async {
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
  }

  Future<void> updateProfile({
    String? fullName,
    String? level,
    int? readingAvg,
    int? listeningAvg,
    int? writingAvg,
    int? speakingAvg,
  }) async {
    final supabase = ref.read(supabaseProvider);
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final updates = {
      if (fullName != null) 'full_name': fullName,
      if (level != null) 'level': level,
      if (readingAvg != null) 'reading_avg': readingAvg,
      if (listeningAvg != null) 'listening_avg': listeningAvg,
      if (writingAvg != null) 'writing_avg': writingAvg,
      if (speakingAvg != null) 'speaking_avg': speakingAvg,
    };

    if (updates.isEmpty) return;

    await supabase.from('profiles').update(updates).eq('id', user.id);
    
    // Refresh the profile data
    ref.invalidateSelf();
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, Profile?>(() {
  return ProfileNotifier();
});
