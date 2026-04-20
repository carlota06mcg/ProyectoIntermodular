import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Actualizar el rol (estudiante/propietario)
  Future<void> updateUserRole(String userId, String role) async {
    await _supabase
        .from('profiles')
        .update({'role': role})
        .eq('id', userId);
  }

  // Aquí añadiremos en el futuro: getUserProfile, updateAvatar, etc.
}