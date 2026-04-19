import 'package:flutter/material.dart';
// 1. Importa tu archivo de rutas
import 'package:roomiefind/routes/routes.dart'; 
import 'package:roomiefind/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoomieFind',
      theme: myAppTheme,

      // 2. Definimos que la app inicie en el Login
      initialRoute: AppRoutes.login,

      // 3. Cargamos el mapa de rutas desde tu archivo externo
      routes: AppRoutes.getRoutes(),
      
      // OPCIONAL: Si quieres que al haber un error de ruta no crashee
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text("Ruta no encontrada")),
        ),
      ),
    );
  }
}
