import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/widgets/widgets.dart';
import 'package:roomiefind/viewmodels/auth_viewmodel.dart';
import 'sign_up.dart';
import 'role_selection.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Controladores para capturar el texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Accedemos a los colores del tema y al ViewModel (el motor)
    final colors = Theme.of(context).colorScheme;
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: colors.secondary, // Beige del tema
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          children: [
            const SizedBox(height: 80),
            
            // Título
            Text(
              'RoomieFind',
              style: TextStyle(
                color: colors.primary,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Logo
            Image.asset(
              'lib/photos/Logo.png', 
              height: 180,
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

            // Inputs con sus controladores
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'email@domain.com'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passController,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Contraseña'),
            ),
            const SizedBox(height: 25),

            // Botón Continuar (Login Real)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: authViewModel.isLoading 
                  ? null 
                  : () async {
                      // Validar campos vacíos
                      if (_emailController.text.isEmpty || _passController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Por favor, rellena todos los campos')),
                        );
                        return;
                      }

                      // Llamada al ViewModel
                      final success = await authViewModel.login(
                        email: _emailController.text.trim(),
                        password: _passController.text.trim(),
                      );

                      if (success) {
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(authViewModel.errorMessage ?? 'Error al iniciar sesión'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                child: authViewModel.isLoading 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Continuar'),
              ),
            ),
            
            const SizedBox(height: 20),
            const DividerOr(), 
            const SizedBox(height: 20),

            // Botón Ir a Registro
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpScreen()),
                  );
                },
                child: const Text('Registrarme'),
              ),
            ),
            
            const SizedBox(height: 15),
            
            // Botones sociales
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