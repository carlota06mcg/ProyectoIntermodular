import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/models/user_model.dart';
import 'package:roomiefind/routes/routes.dart';
import 'package:roomiefind/viewmodels/auth_viewmodel.dart';
import 'package:roomiefind/widgets/widgets.dart'; 

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFAE2535);
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
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

                  RoleButton(
                    label: 'Estudiante',
                    icon: Icons.menu_book_rounded,
                    color: primaryRed,
                    isLoading: authViewModel.isLoading,
                    onPressed: () async {
                      final success = await authViewModel.updateUserRole(UserRole.estudiante);

                      if (success && context.mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.mainMenu);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authViewModel.errorMessage ?? 'Error')),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 40),

                  RoleButton(
                    label: 'Propietario',
                    icon: Icons.home_rounded,
                    color: primaryRed,
                    isLoading: authViewModel.isLoading,
                    onPressed: () async {
                      final success = await authViewModel.updateUserRole(UserRole.propietario);

                      if (success && context.mounted) {
                        Navigator.pushReplacementNamed(context, AppRoutes.ownAppart);
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authViewModel.errorMessage ?? 'Error')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            if (authViewModel.isLoading)
              const Center(child: CircularProgressIndicator(color: primaryRed)),
          ],
        ),
      ),
    );
  }
  
}
