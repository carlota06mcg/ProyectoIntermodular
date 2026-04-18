import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFAE2535);
    const Color secondaryIconColor = Color(0xFFC62828);
    const Color textColor = Colors.black87;
    const Color secondaryTextColor = Colors.black54;

    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco para la pantalla de ajustes
      appBar: AppBar(
        // Un AppBar transparente para el status bar (hora, etc.)
        backgroundColor: Colors.transparent,
        elevation: 0,
        // 1. Botón de flecha hacia atrás (izquierda)
        leading: const BackButton(color: secondaryIconColor),
        // 2. Título "Ajustes" (centro)
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
        // Padding generoso alrededor de todo el contenido
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          children: [
            const SizedBox(height: 10), // Espacio superior

            // --- SECCIÓN DE PERFIL ---
            // 3. Foto de perfil (el gatito con lazos)
            // Reemplaza con tu imagen real de asset
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100), // Bordes redondeados
                child: Image.asset(
                  'assets/images/perfil.png', // <-- PON AQUÍ LA RUTA DE TU FOTO DE PERFIL
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover, // Para que la imagen cubra todo el espacio
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // 4. Nombre de perfil
            const Text(
              'Carlota Maroto',
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),

            // 5. Correo electrónico
            const Text(
              'correoimaginario@gmail.com',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 25),

            // 6. Línea divisoria horizontal
            const Divider(
              color: Color(0x1F000000), // Negro con 12% de opacidad (Gris transparente)
              thickness: 1,             // Una línea muy fina
              height: 40,),
            const SizedBox(height: 25),

            // --- SECCIÓN DE OPCIONES (TILES) ---
            // 7. Lista de opciones de ajustes
            // Widget reutilizable creado abajo
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

            const SizedBox(height: 40), // Espacio entre opciones y enlaces

            // --- SECCIÓN DE ENLACES ---
            // 8. Enlaces finales (Cambiar a cuenta de Arrendatario / Cerrar Sesión)
            // Widget reutilizable creado abajo
            const _SettingsActionText(text: 'Cambiar a cuenta de Arrendatario'),
            const SizedBox(height: 15),
            const _SettingsActionText(text: 'Cerrar Sesión'),
            const SizedBox(height: 40), // Espacio inferior

          ],
        ),
      ),
    );
  }
}

// --- WIDGETS PRIVADOS Y REUTILIZABLES ---

// 7. Tile de Ajuste Reutilizable
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
    const Color secondaryTextColor = Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          // Icono (izquierda)
          Icon(icon, color: secondaryIconColor, size: 28),
          const SizedBox(width: 15), // Espaciado entre icono y texto

          // Título (centro)
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

          // Flecha hacia la derecha (derecha)
          Icon(Icons.arrow_forward_ios_rounded, color: secondaryIconColor, size: 18),
        ],
      ),
    );
  }
}

// 8. Texto de Acción Reutilizable
class _SettingsActionText extends StatelessWidget {
  final String text;

  const _SettingsActionText({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definimos el color primario del diseño (el rojo/burdeos)
    const Color primaryColor = Color(0xFFAE2535); 

    return SizedBox(
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(0),
        ),
        onPressed: () {}, // Pon aquí tu función
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