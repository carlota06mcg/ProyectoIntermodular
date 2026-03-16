import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //Definimos el color principal
    const Color primaryRed = Color(0xFFAE2535);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Logo
              Image.asset('assets/images/logo.png', height: 100),
              const SizedBox(height: 20),
              const Text(
                'RoomieFind',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryRed,
                ),
              ),
              const SizedBox(height: 60),
              // Botón Estudiante
              _buildRoleButton(
                context: context,
                label: 'Estudiante',
                icon: Icons.menu_book_rounded,
                color: primaryRed,
                onPressed: () {
                  print('Navegar a Estudiante');
                },
              ),

              const SizedBox(height: 40),

              // Botón Propietario
              _buildRoleButton(
                context: context,
                label: 'Propietario',
                icon: Icons.home_rounded,
                color: primaryRed,
                onPressed: () {
                  print('Navegar a Propietario');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Estilo del botón
  Widget _buildRoleButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 280,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
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
