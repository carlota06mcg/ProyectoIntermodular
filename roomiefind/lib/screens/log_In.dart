// Pantalla de Inicio de la Aplicacion Log in.
import 'package:flutter/material.dart';
import 'package:roomiefind/widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Accedemos a los colores de tu tema mediante el context
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      // Usamos el color 'secondary' del tema como fondo (el beige que definiste)
      backgroundColor: colors.secondary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          children: [
            const SizedBox(height: 80),
            
            // Título usando el color primario del tema
            Text(
              'RoomieFind',
              style: TextStyle(
                color: colors.primary,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Logo (Asegúrate de tenerlo en assets)
            Image.asset(
              'lib/photos/Logo.png', // <-- Reemplaza con la ruta EXACTA de tu imagen
              height: 180, // Ajusta la altura para que coincida con el diseño
            ),
            
            const SizedBox(height: 30),
            const Text(
              'Iniciar Sesión',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Introduce tu correo electrónico para iniciar sesión',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),

            // Inputs (Toman automáticamente el estilo de tu inputDecorationTheme)
            const TextField(
              decoration: InputDecoration(hintText: 'email@domain.com'),
            ),
            const SizedBox(height: 15),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: 'Contraseña'),
            ),
            const SizedBox(height: 25),

            // Botón (Toma automáticamente el estilo de tu elevatedButtonTheme)
            ElevatedButton(
              onPressed: () {},
              child: const Text('Continuar'),
            ),
            
            const SizedBox(height: 20),
            const DividerOr(), // Widget de soporte abajo
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
              child: const Text('Registrarme'),
            ),
            
            const SizedBox(height: 15),
            
            // Botones sociales (blancos, fuera del tema principal)
            const SocialButton(text: "Continuar con Google", icon: Icons.g_mobiledata),
            const SocialButton(text: "Continuar con Apple", icon: Icons.apple),
            
            const SizedBox(height: 40),
            const Footerlogin(),
          ],
        ),
      ),
    );
  }
}