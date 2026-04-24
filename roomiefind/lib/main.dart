import 'package:flutter/material.dart';
import 'package:roomiefind/viewmodels/chat_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

// Importaciones de lógica (ViewModels)
import 'package:roomiefind/viewmodels/auth_viewmodel.dart';
import 'package:roomiefind/viewmodels/property_viewmodel.dart';
import 'package:roomiefind/theme/app_theme.dart';

// Importación de rutas (lo que insertó joss)
import 'package:roomiefind/routes/routes.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mantenemos tu configuración de Supabase
  await Supabase.initialize(
    url: 'https://ulnifjcvkaryqpiwoqpy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVsbmlmamN2a2FyeXFwaXdvcXB5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYzODE3MjAsImV4cCI6MjA5MTk1NzcyMH0.MPFjzLc4Lla1v2mkqekmgdNe9U8yIJZR9wINyePmThg',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PropertyViewModel()),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        
        // Nota: Cuando crees el ProfileViewModel, deberás añadirlo aquí debajo
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoomieFind',
      theme: myAppTheme,

      // Usamos el sistema de rutas de tu compañero
      // Esto hará que la app inicie en el Login automáticamente
      initialRoute: AppRoutes.login, 

      // Cargamos el mapa de todas las pantallas (Login, Registro, Home, etc.)
      routes: AppRoutes.getRoutes(),
      
      // Seguridad para rutas inexistentes
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text("Ruta no encontrada")),
        ),
      ),
    );
  }
}
