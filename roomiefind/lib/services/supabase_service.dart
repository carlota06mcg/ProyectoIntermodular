import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  // Dentro de la clase SupabaseService
  SupabaseClient get supabase => Supabase.instance.client;

  // FUNCION: Registro de usuario, la llamaremos desde el viewmodel
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    // Registro en la sección de seguridad de Supabase
    final AuthResponse res = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    // Si el registro fue bien, insertamos en nuestra tabla de 'profiles'
    if (res.user != null) {
      await _supabase.from('profiles').insert({
        'id': res.user!.id,
        'full_name': fullName,
        'username': username,
        'email': email,
        'role': 'pendiente', // Por defecto hasta que elija en la siguiente pantalla
      });
    }
    return res;
  }

  //FUNCION: para iniciar sesión, la llamaremos desde el botón de login
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    // Esto le pregunta a Supabase: "¿Existe este usuario con esta clave?"
    final AuthResponse res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return res;
  }

// FUNCION: para comprobar si un username ya existe, la llamaremos desde el viewmodel antes de registrar al usuario
Future<bool> usernameExists(String username) async {
  final res = await _supabase
      .from('profiles')
      .select()
      .eq('username', username)
      .maybeSingle(); // Busca un solo resultado
  
  return res != null; // Si res no es nulo, es que ya existe
}

}