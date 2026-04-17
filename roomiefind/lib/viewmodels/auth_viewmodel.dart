import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class AuthViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // FUNCION: Registro de usuario, la llamaremos desde el viewmodel
 // En lib/viewmodels/auth_viewmodel.dart

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
    // 1. Validar si el nombre de usuario ya está pillado
    final existeUsuario = await _supabaseService.usernameExists(username);
    if (existeUsuario) {
      _errorMessage = "El nombre de usuario ya está en uso";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // 2. Intentar el registro normal
    await _supabaseService.signUp(
      email: email,
      password: password,
      fullName: fullName,
      username: username,
    );

    _isLoading = false;
    notifyListeners();
    return true;

  } catch (e) {
    // 3. Capturar errores específicos de Supabase (como correo duplicado)
    String errorRaw = e.toString().toLowerCase();
    
    if (errorRaw.contains("user already exists") || errorRaw.contains("already registered")) {
      _errorMessage = "Este correo electrónico ya está en uso";
    } else {
      _errorMessage = "Error: Correo o contraseña inválidos";
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}

  // FUNCION: para iniciar sesión, la llamaremos desde el botón de login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supabaseService.signIn(
        email: email,
        password: password,
      );
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
}