import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider((ref) => Supabase.instance.client);

final authStateProvider = StreamProvider((ref) {
  return ref.watch(supabaseProvider).auth.onAuthStateChange;
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref.watch(supabaseProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseClient _supabase;

  AuthNotifier(this._supabase) : super(const AsyncData(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncLoading();
    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      
      if (res.user != null) {
        // Create profile entry
        await _supabase.from('profiles').insert({
          'id': res.user!.id,
          'full_name': name,
          'level': 'unassigned',
        });
      }
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
