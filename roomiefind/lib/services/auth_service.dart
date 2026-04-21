import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  SupabaseClient get supabase => _supabase;

  // REGISTRO COMPLETO: auth + profiles
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    final AuthResponse res = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    // Si el usuario se creó correctamente
    if (res.user != null) {
      await _supabase.from('profiles').insert({
        'id': res.user!.id,
        'full_name': fullName,
        'username': username,
        'email': email,
        'role': 'pendiente', // hasta que elija rol
      });
    }

    return res;
  }

  // LOGIN
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final AuthResponse res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return res;
  }

  // COMPROBAR USERNAME
  Future<bool> usernameExists(String username) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('username', username)
        .maybeSingle();

    return response != null;
  }
}
