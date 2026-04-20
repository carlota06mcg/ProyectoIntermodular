import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importante para acceder al ViewModel
import 'package:roomiefind/models/user_model.dart';
import 'package:roomiefind/routes/routes.dart'; 
import 'package:roomiefind/viewmodels/auth_viewmodel.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFAE2535);
    // Accedemos al AuthViewModel
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack( // Usamos Stack para poner el cargando encima si fuera necesario
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'RoomieFind',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryRed,
                    ),
                  ),
                  Image.asset('lib/photos/Logo.png', height: 100),
                  const SizedBox(height: 60),
                  
                  // Botón Estudiante
                  _buildRoleButton(
                    context: context,
                    label: 'Estudiante',
                    icon: Icons.menu_book_rounded,
                    color: primaryRed,
                    isLoading: authViewModel.isLoading,
                    onPressed: () async {
                      final success = await authViewModel.updateUserRole(UserRole.estudiante);
                      if (success && context.mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.mainMenu);
                      } else if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authViewModel.errorMessage ?? 'Error')),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 40),

                  // Botón Propietario
                  _buildRoleButton(
                    context: context,
                    label: 'Propietario',
                    icon: Icons.home_rounded,
                    color: primaryRed,
                    isLoading: authViewModel.isLoading,
                    onPressed: () async {
                      final success = await authViewModel.updateUserRole(UserRole.propietario);
                      if (success && context.mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.ownAppart);
                      } else if (!success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authViewModel.errorMessage ?? 'Error')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            // Si está cargando, mostramos un indicador visual
            if (authViewModel.isLoading)
              const Center(child: CircularProgressIndicator(color: primaryRed)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required bool isLoading, // Añadimos el estado de carga
  }) {
    return SizedBox(
      width: 180,
      height: 164,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Deshabilitar si carga
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 15), 
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}