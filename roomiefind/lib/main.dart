import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/viewmodels/auth_viewmodel.dart';
import 'package:roomiefind/theme/app_theme.dart';
import 'package:roomiefind/screens/Shared/log_in.dart'; // Tu pantalla inicial

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ulnifjcvkaryqpiwoqpy.supabase.co',
    anonKey: 'sb_publishable_LzbRjDqKM1WZb8B5UrM-aw_d6N97Nvs',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
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
      theme: myAppTheme, // Tu tema personalizado
      home: const LoginScreen(), // LA PRIMERA EN ABRIR
    );
  }
}