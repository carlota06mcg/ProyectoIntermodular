import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener datos del perfil (Actualizado para devolver el mapa de Supabase)
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return data;
    } catch (e) {
      print("Error al obtener perfil: $e");
      return null;
    }
  }

  // Actualizar el perfil COMPLETO (Lo que usaremos en la pantalla Profile)
  Future<void> updateUserProfile(String userId, Map<String, dynamic> userData) async {
    try {
      await _supabase
          .from('profiles')
          .update(userData)
          .eq('id', userId);
    } catch (e) {
      print("Error en UserService.updateUserProfile: $e");
      rethrow;
    }
  }

  // Actualizar solo el rol (El que ya tenías)
  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _supabase
          .from('profiles')
          .update({'role': role})
          .eq('id', userId);
    } catch (e) {
      print("Error en UserService.updateUserRole: $e");
      rethrow;
    }
  }
}