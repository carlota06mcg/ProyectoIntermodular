import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Actualizar el rol (estudiante/propietario)
  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _supabase
          .from('profiles')
          .update({'role': role})
          .eq('id', userId);
    } catch (e) {
      // Esto te ayudará a ver en la consola si el error es de permisos o de nombre de columna
      print("Error en UserService.updateUserRole: $e");
      rethrow; // Re-lanzamos el error para que el ViewModel lo capture y muestre el mensaje
    }
  }

  // Obtener datos del perfil (Útil para mostrar el nombre en el menú)
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
}