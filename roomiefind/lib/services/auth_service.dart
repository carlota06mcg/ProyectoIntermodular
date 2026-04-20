import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Getter para que otros puedan usar el cliente si es necesario
  SupabaseClient get supabase => _supabase;

  // MUEVE AQUÍ: signUp
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'username': username,
      },
    );
  }

  // MUEVE AQUÍ: signIn
  Future<void> signIn({required String email, required String password}) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  // MUEVE AQUÍ: usernameExists
  Future<bool> usernameExists(String username) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('username', username)
        .maybeSingle();
    return response != null;
  }
}