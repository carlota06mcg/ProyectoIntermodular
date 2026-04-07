import 'package:flutter/material.dart';
// Importa tu archivo de tema
import 'package:roomiefind/theme/app_theme.dart';
// Importa la pantalla que acabamos de crear (y las demás)
import 'package:roomiefind/screens/screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quita la banda roja de "Debug"
      title: 'RoomieFind',

      // Aquí conectamos tu archivo app_theme.dart
      // Usando la variable estática lightTheme dentro de la clase AppTheme
      theme: AppTheme.lightTheme,

      // La pantalla de inicio (Home)
      // RoomieFindHome debe ser el nombre de la clase que creamos para Favoritos/Historial
      home: const HistoryFavScreen(),
    );
  }
}
