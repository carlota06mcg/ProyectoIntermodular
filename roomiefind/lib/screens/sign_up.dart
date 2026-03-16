import 'package:flutter/material.dart';
//import 'package:roomiefind/widgets/widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    // Accedemos a los colores de tu tema mediante el context como en LoginScreen
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.secondary, // Beige
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Registra tu cuenta',
              style: TextStyle(
                color: colors.primary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Subtítulo
            const Text(
              'Registrate con tu correo, un usuario y una\ncontraseña',
              style: TextStyle(
                color: Colors.black45, // Color grisáceo
                fontSize: 14,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 30),

            // Label Correo
            const Text(
              'Correo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(hintText: 'brooklynsim@gmail.com'),
            ),
            const SizedBox(height: 20),

            // Label Usuario
            const Text(
              'Usuario',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(hintText: 'brooklynsim'),
            ),
            const SizedBox(height: 20),

            // Label Contraseña
            const Text(
              'Contraseña',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: '........',
                suffixIcon: Icon(
                  Icons.visibility_off_outlined,
                  color: Colors.black45,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Checkbox Términos y Condiciones
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _acceptedTerms,
                    activeColor: const Color(
                      0xFFB82D41,
                    ), // Color de relleno similar al botón rojo
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(color: Colors.black45),
                    onChanged: (value) {
                      setState(() {
                        _acceptedTerms = value ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: 'Al hacer clic en continuar, aceptas nuestros ',
                        ),
                        TextSpan(
                          text: 'Términos de Servicio',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(text: ' y nuestra '),
                        TextSpan(
                          text: 'Política de Privacidad',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Botón Registrarme (Toma automáticamente el estilo de elevatedButtonTheme)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                // Por defecto el elevado ocupa todo el ancho de este box e implementa los bordes redondeados del theme.
                child: const Text(
                  'Registrarme',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Divider "O"
            const Center(
              child: Text(
                'O',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 20),

            // Botones sociales redondos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialRoundIcon(
                  child: Icon(
                    Icons.facebook,
                    color: Colors.blue[800],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                _buildSocialRoundIcon(
                  // Intenta cargar la imagen en assets sino renderiza una 'G' clásica
                  child: Image.asset(
                    'lib/photos/google_icon.png',
                    height: 22,
                    errorBuilder: (context, error, stackTrace) => Text(
                      'G',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Footer / Redirección Inicia Sesión
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Vuelve a la pantalla de Login
                },
                child: const Text.rich(
                  TextSpan(
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                    children: [
                      TextSpan(text: 'Ya tienes una cuenta ? '),
                      TextSpan(
                        text: 'Inicia sesión',
                        style: TextStyle(
                          color: Color(0xFFB82D41), // Resaltado en rojo
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialRoundIcon({required Widget child}) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[200], // Fondo claro como el diseño
        shape: BoxShape.circle,
      ),
      child: Center(child: child),
    );
  }
}
