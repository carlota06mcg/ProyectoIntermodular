import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Importante para acceder al cliente
import '../services/auth_service.dart';
import '../services/user_service.dart'; 
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Acceso directo al cliente de Supabase para evitar errores de "undefined getter"
  final _supabase = Supabase.instance.client;

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
      // Usamos el acceso directo de la instancia para evitar el error de la captura 6
      final user = _supabase.auth.currentUser;
      
      if (user == null) {
        _errorMessage = "No hay sesión activa";
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Llamamos al UserService (Asegúrate de que el método reciba String)
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
  
  // ... dentro de tu clase AuthViewModel ...

Future<void> refreshUserProfile() async {
  if (_currentUser == null) return;
  
  final userData = await _userService.getUserProfile(_currentUser!.id);
  if (userData != null) {
    _currentUser = UserModel.fromJson(userData);
    notifyListeners(); // Esto hace que la pantalla se actualice sola
  }
}

Future<void> updateProfile(UserModel updatedUser) async {
  try {
    // Usamos el nuevo método del servicio enviando el JSON del modelo
    await _userService.updateUserProfile(updatedUser.id, updatedUser.toJson());
    _currentUser = updatedUser;
    notifyListeners();
  } catch (e) {
    print("Error actualizando perfil en VM: $e");
    rethrow;
  }
}

}