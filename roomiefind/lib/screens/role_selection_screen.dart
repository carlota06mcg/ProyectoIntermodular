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
              const SizedBox(height: 20),
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
      width: 180,
      height: 164,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 3,
        ),
        child: Column( // Cambiado de Row a Column
          mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente
          children: [
            Icon(
              icon, 
              size: 50, // Aumenté un poco el tamaño para que luzca mejor en 164 de alto
              color: Colors.white
            ),
            const SizedBox(height: 15), // Espacio vertical entre icono y texto
            Text(
              label,
              textAlign: TextAlign.center, // Asegura que el texto esté centrado si es largo
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