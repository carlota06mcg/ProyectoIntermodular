import 'dart:io'; // Añadido para manejar el archivo de imagen
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final _supabase = Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ============================
  // CARGAR PERFIL DEL USUARIO
  // ============================
  Future<void> loadCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final data = await _userService.getUserProfile(user.id);
    if (data != null) {
      _currentUser = UserModel.fromJson({
        ...data,
        'email': user.email, // <- viene de auth
      });
      notifyListeners();
    }
  }

// ============================
  // REGISTRO (CON DIAGNÓSTICO DE ERRORES)
  // ============================
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Validar si el username existe
      final existeUsuario = await _authService.usernameExists(username);
      if (existeUsuario) {
        _errorMessage = "El nombre de usuario ya está en uso";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Intentar el registro en Supabase
      final res = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        username: username,
      );

      // Chivato en consola para ver qué devuelve Supabase exactamente
      debugPrint("=== [AUTH DIAGNOSIS] ===");
      debugPrint("User ID creado: ${res.user?.id}");
      debugPrint("Confirmación de email pendiente: ${res.user?.confirmedAt == null ? 'SÍ' : 'NO'}");

      if (res.user == null) {
        _errorMessage = "No se pudo crear el usuario (Respuesta vacía)";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 3. Cargar perfil recién creado
      await loadCurrentUser();

      _isLoading = false;
      notifyListeners();
      return true;

    } on AuthException catch (e) {
      // Errores específicos de Autenticación (Contraseña corta, email inválido, etc.)
      _errorMessage = e.message;
      debugPrint("❌ [Error Auth Supabase]: ${e.message} (Código: ${e.statusCode})");
      _isLoading = false;
      notifyListeners();
      return false;
    } on PostgrestException catch (e) {
      // Errores específicos de la base de datos (Fallo al insertar en la tabla 'profiles')
      _errorMessage = "Error en base de datos: ${e.message}";
      debugPrint("❌ [Error DB Supabase]: ${e.message} | Detalle: ${e.details}");
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Cualquier otro error inesperado
      _errorMessage = "Error inesperado: $e";
      debugPrint("❌ [Error Inesperado Registro]: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================
  // LOGIN
  // ============================
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _authService.signIn(
        email: email,
        password: password,
      );

      if (res.user == null) {
        _errorMessage = "Email o contraseña incorrectos";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await loadCurrentUser();

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = "Email o contraseña incorrectos";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================
  // ACTUALIZAR ROL
  // ============================
  Future<bool> updateUserRole(UserRole role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        _errorMessage = "No hay sesión activa";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _userService.updateUserRole(user.id, role.name);

      // Refrescar perfil
      await loadCurrentUser();

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = "Error al guardar el rol";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ============================
  // ACTUALIZAR PERFIL COMPLETO
  // ============================
  Future<void> updateProfile(UserModel updatedUser) async {
    try {
      await _userService.updateUserProfile(
        updatedUser.id,
        updatedUser.toJson(),
      );

      _currentUser = updatedUser;
      notifyListeners();

    } catch (e) {
      print("Error actualizando perfil en VM: $e");
      rethrow;
    }
  }

  // ============================
  // ACTUALIZAR AVATAR (Storage + DB)
  // ============================
  Future<void> updateAvatar(File imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 1. Subir al Bucket 'avatars'
      await _supabase.storage.from('avatars').upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // 2. Obtener URL pública
      final String publicUrl =
          _supabase.storage.from('avatars').getPublicUrl(fileName);

      // 3. Actualizar campo avatarUrl en la tabla de perfiles
      await _userService.updateUserProfile(user.id, {'avatar_url': publicUrl});

      // 4. Refrescar datos locales
      await loadCurrentUser();
    } catch (e) {
      print("Error actualizando avatar: $e");
      _errorMessage = "No se pudo actualizar la imagen";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================
  // LOGOUT
  // ============================
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print("Error al cerrar sesión: $e");
    }
  }
}