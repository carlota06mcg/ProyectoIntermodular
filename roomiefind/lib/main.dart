import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

// Importaciones de lógica (Tus archivos)
import 'package:roomiefind/viewmodels/auth_viewmodel.dart';
import 'package:roomiefind/theme/app_theme.dart';

// Importación de rutas (Lo nuevo de tu compañero)
import 'package:roomiefind/routes/routes.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Mantenemos tu configuración de Supabase
  await Supabase.initialize(
    url: 'https://ulnifjcvkaryqpiwoqpy.supabase.co',
    anonKey: 'sb_publishable_LzbRjDqKM1WZb8B5UrM-aw_d6N97Nvs',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
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