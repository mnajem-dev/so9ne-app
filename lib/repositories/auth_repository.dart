import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  User? get currentUser => _client.auth.currentUser;

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    
    if (response.user != null) {
      // Create profile record (assumes 'profiles' table exists and trigger is set up, 
      // or we do it manually here if no trigger exists).
      await _client.from('profiles').insert({
        'id': response.user!.id,
        'nom': name,
        'email': email,
        'role': 'Client', // Default role
      });
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
