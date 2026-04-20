import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  // Instanciamos los dos nuevos servicios
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // REGISTRO
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

      await _authService.signUp(
        email: email,
        password: password,
        fullName: fullName,
        username: username,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().contains("already registered") 
          ? "Este correo ya está en uso" 
          : "Error en el registro";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // LOGIN
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
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

  // ACTUALIZAR ROL
  Future<bool> updateUserRole(UserRole role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _authService.supabase.auth.currentUser;
      if (user == null) {
        _errorMessage = "No hay sesión activa";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Llamamos al UserService
      await _userService.updateUserRole(user.id, role.name);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Error al guardar el rol: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}