import 'package:flutter/material.dart';
import 'package:roomiefind/screens/mainScreen.dart';
// Importa aquí tu barrel file (el archivo que contiene todos los exports)
import 'package:roomiefind/screens/Students/screen.dart'; 
import 'package:roomiefind/screens/Owner/screen.dart'; 
import 'package:roomiefind/screens/Shared/screen.dart'; 

class AppRoutes {
  // --- RUTAS DE AUTENTICACIÓN ---
  static const String login         = '/login';
  static const String signUp        = '/signup';
  static const String roleSelection = '/role_selection';

  // --- RUTAS PRINCIPALES (DASHBOARDS) ---
  static const String mainMenu      = '/main_menu';    // Para Estudiantes
  static const String ownAppart     = '/own_appartment'; // Para Propietarios

  // --- FUNCIONALIDADES ESTUDIANTE ---
  static const String search        = '/search';
  static const String favorites     = '/favorites';
  static const String history       = '/history';

  // --- FUNCIONALIDADES PROPIETARIO ---
  static const String createApart   = '/create_appartment';

  // --- CHAT ---
  static const String chatMenu      = '/chat_menu';
  static const String chatDetail    = '/chat_detail';

  // --- PERFIL ---
  static const String profile       = '/profile';
  static const String settings      = '/settings';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Auth
      login:         (context) => const LoginScreen(),
      signUp:        (context) => const SignUpScreen(),
      roleSelection: (context) => const RoleSelectionScreen(),

      // Core Screens
      mainMenu: (context) => const MainWrapper(isOwner: false),
      ownAppart:   (context) => const MainWrapper(isOwner: true), // Tu home de propietario

      // Student features
      //search:        (context) => const Search(),
      favorites:     (context) => const FavoritesScreen(),
      history:       (context) => const HistoryScreen(),

      // Owner features
      createApart:   (context) => const FormularioAlojamientoScreen(),

      // Chat
      chatMenu:      (context) => const MenuChatsScreen(),
      chatDetail:    (context) => const ChatPlantillaScreen(),

      // Profile
      profile:       (context) => const ProfileScreen(),
      settings:      (context) => const SettingsScreen(),
    };
  }
}