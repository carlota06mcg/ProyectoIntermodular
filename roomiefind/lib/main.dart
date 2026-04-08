import 'package:flutter/material.dart';
// Importa tu archivo de tema
import 'package:roomiefind/theme/app_theme.dart';
// Importa la pantalla que acabamos de crear (y las demás)
import 'package:roomiefind/screens/Students/screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: myAppTheme,
      home: const LoginScreen(),
    );
  }
}

