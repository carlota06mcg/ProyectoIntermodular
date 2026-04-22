import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/viewmodels/auth_viewmodel.dart';
import 'package:roomiefind/routes/routes.dart';
import 'package:roomiefind/models/user_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFAE2535);
    const Color secondaryIconColor = Color(0xFFC62828);
    const Color secondaryTextColor = Colors.black54;

    final auth = context.watch<AuthViewModel>();
    final user = auth.currentUser;

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
            const SizedBox(height: 10),

            // FOTO DE PERFIL
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: user?.avatarUrl != null
                    ? Image.network(
                        user!.avatarUrl!,
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/perfil.png',
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // NOMBRE REAL
            Text(
              user?.fullName ?? "Usuario",
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

            // ============================
            // CAMBIO DE ROL DINÁMICO
            // ============================
            if (user?.role == UserRole.estudiante)
              _SettingsActionText(
                text: 'Cambiar a cuenta de Propietario',
                onTap: () async {
                  final ok = await context.read<AuthViewModel>()
                      .updateUserRole(UserRole.propietario);

                  if (ok && context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.roleSelection,
                      (_) => false,
                    );
                  }
                },
              ),

            if (user?.role == UserRole.propietario)
              _SettingsActionText(
                text: 'Cambiar a cuenta de Estudiante',
                onTap: () async {
                  final ok = await context.read<AuthViewModel>()
                      .updateUserRole(UserRole.estudiante);

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

            // ============================
            // CERRAR SESIÓN
            // ============================
            _SettingsActionText(
              text: 'Cerrar Sesión',
              onTap: () async {
                await context.read<AuthViewModel>().logout();

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
}

// TILE
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SettingsTile({
    Key? key,
    required this.icon,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color secondaryIconColor = Color(0xFFC62828);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: secondaryIconColor, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: secondaryIconColor, size: 18),
        ],
      ),
    );
  }
}

// ACCIONES
class _SettingsActionText extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _SettingsActionText({
    Key? key,
    required this.text,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFAE2535);

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
