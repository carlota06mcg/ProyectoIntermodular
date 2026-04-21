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
  // REGISTRO
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
      final existeUsuario = await _authService.usernameExists(username);
      if (existeUsuario) {
        _errorMessage = "El nombre de usuario ya está en uso";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final res = await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        username: username,
      );

      if (res.user == null) {
        _errorMessage = "No se pudo crear el usuario";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Cargar perfil recién creado
      await loadCurrentUser();

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = "Error en el registro";
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
}
