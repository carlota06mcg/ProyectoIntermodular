import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/viewmodels/auth_viewmodel.dart';
import 'package:roomiefind/routes/routes.dart';
import '../../../models/user_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el ViewModel
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    // Colores constantes
    const Color primaryColor = Color(0xFFAE2535);
    const Color secondaryIconColor = Color(0xFFC62828);
    const Color secondaryTextColor = Colors.black54;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: secondaryIconColor),
        centerTitle: true,
        title: const Text(
          'Ajustes',
          style: TextStyle(
            color: primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          children: [
            // FOTO DE PERFIL (Ahora recibe la función para editar)
            _buildAvatar(user, () {
              // Aquí irá la lógica para elegir foto más adelante
              print("Seleccionar imagen para el usuario: ${user?.avatarUrl}");
            }),
            
            const SizedBox(height: 15),

            // NOMBRE REAL
            Text(
              user?.fullName ?? "Usuario",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),

            // CORREO REAL
            Text(
              user?.email ?? "correo no disponible",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 25),

            const Divider(
              color: Color(0x1F000000),
              thickness: 1,
              height: 40,
            ),
            const SizedBox(height: 25),

            // OPCIONES
            const _SettingsTile(
              icon: Icons.settings_accessibility_rounded,
              title: 'Accesibilidad',
            ),
            const _SettingsTile(
              icon: Icons.lock_open_rounded,
              title: 'Privacidad y Seguridad',
            ),
            const _SettingsTile(
              icon: Icons.payment_rounded,
              title: 'Métodos de Pago',
            ),
            const _SettingsTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notificaciones',
            ),
            const _SettingsTile(
              icon: Icons.language_rounded,
              title: 'Idioma',
            ),
            const _SettingsTile(
              icon: Icons.phone_in_talk_rounded,
              title: 'Contacta con Nosotros',
            ),
            const _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'Sobre Nosotros',
            ),

            const SizedBox(height: 40),

            // CAMBIO DE ROL DINÁMICO
            if (user != null)
              _SettingsActionText(
                text: 'Cambiar a modo ${user.role == UserRole.estudiante ? "Propietario" : "Estudiante"}',
                onTap: () async {
                  final nuevoRol = user.role == UserRole.estudiante 
                      ? UserRole.propietario 
                      : UserRole.estudiante;
                  
                  final ok = await authViewModel.updateUserRole(nuevoRol);

                  if (ok && context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.roleSelection,
                      (_) => false,
                    );
                  }
                },
              ),

            const SizedBox(height: 15),

            // CERRAR SESIÓN
            _SettingsActionText(
              text: 'Cerrar Sesión',
              onTap: () async {
                await authViewModel.logout();

                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (_) => false,
                  );
                }
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget del Avatar corregido
  Widget _buildAvatar(UserModel? user, VoidCallback onEditPhoto) {
    const Color primaryColor = Color(0xFFAE2535);
    
    return GestureDetector(
      onTap: onEditPhoto,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 65,
            backgroundColor: const Color(0xFFEEEEEE),
            backgroundImage: (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty)
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                ? const Icon(Icons.person, size: 80, color: Colors.grey)
                : null,
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 17,
              backgroundColor: primaryColor,
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para las filas de ajustes
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SettingsTile({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFC62828), size: 24),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

// Widget auxiliar para los textos de acción (Cerrar sesión / Cambio de rol)
class _SettingsActionText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SettingsActionText({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFAE2535),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}