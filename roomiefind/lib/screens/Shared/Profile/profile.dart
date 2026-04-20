import 'package:flutter/material.dart';
import 'package:roomiefind/screens/Shared/Profile/settings.dart';
import 'package:roomiefind/widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // =============================================================
  // 1. ESTADO Y CONTROLADORES
  // =============================================================

  // 'isEditing' determina si mostramos el perfil o el formulario de edición
  bool isEditing = false;

  // Los controladores capturan y mantienen el texto escrito en los campos
  final TextEditingController nameController = TextEditingController(
    text: "Carlota Maroto",
  );
  final TextEditingController descController = TextEditingController(
    text: "Estudiante de Informática en Granada! <3",
  );
  final TextEditingController locController = TextEditingController(
    text: "Granada, España",
  );
  final TextEditingController studiesController = TextEditingController(
    text: "Desarrollo de Aplicaciones Multiplataforma (CFGS)",
  );
  final TextEditingController instController = TextEditingController(
    text: "Davante Medac Nevada",
  );
  final TextEditingController instagramController = TextEditingController(
    text: "",
  );

  // Definición de colores para mantener la coherencia visual (Paleta de la imagen)
  final Color primaryRed = const Color(0xFFAE2535); // Granate principal
  final Color lightGrey = const Color(
    0xFFE0E0E0,
  ); // Gris para los fondos de los inputs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar: Cambia dinámicamente el título según si estamos editando o no
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? "Edición | Perfil" : "Mi Perfil - Estudiante",
          style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: primaryRed),
            onPressed: () {
              Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // =============================================================
            // 2. SECCIÓN FOTO DE PERFIL (AVATAR)
            // =============================================================
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 80, color: Colors.grey[600]),
                ),
                // Botón circular de la cámara encima de la foto
                GestureDetector(
                  onTap: () => print("Abrir cámara/galería"),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: primaryRed,
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Nombre de usuario (Texto estático)
            Text(
              nameController.text,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryRed,
              ),
            ),
            const SizedBox(height: 10),

            // =============================================================
            // 3. BOTÓN DE ACCIÓN PRINCIPAL (EDITAR / CONFIRMAR)
            // =============================================================

            // Si NO estamos editando, muestra el botón para entrar al modo edición
            if (!isEditing)
              ElevatedButton(
                onPressed: () => setState(() => isEditing = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Editar Perfil",
                  style: TextStyle(color: Colors.white),
                ),
              ),

            const SizedBox(height: 20),

            // =============================================================
            // 4. LISTADO DE CAMPOS DE INFORMACIÓN
            // =============================================================

            CustomProfileField(
              esPropietario: false,
              label:"Descripción:",
              controller: descController,
              icon: Icons.description,
              isEditing: isEditing,
              maxLines: 3,
            ),
            CustomProfileField(
              esPropietario: false,
              label:"Ubicación:",
              controller: locController,
              icon: Icons.location_on_outlined,
              isEditing: isEditing,
            ),
            CustomProfileField(
              esPropietario: false,
              label: "Estudios:",
              controller: studiesController,
              icon: Icons.book_outlined,
              isEditing: isEditing,
            ),
            CustomProfileField(
              esPropietario: false,
              label: "Institución:",
              controller: instController,
              icon: Icons.business_outlined,
              isEditing: isEditing,
            ),

            // Redes sociales: Solo se muestra si estamos editando o si ya tiene contenido
            if (isEditing || instagramController.text.isNotEmpty)
              CustomProfileField(
                esPropietario: false,
                label: "Redes sociales (Instagram):",
                controller: instagramController,
                icon: Icons.camera_alt_outlined,
                isEditing: isEditing,
              ),

            const SizedBox(height: 30),

            // Botón de Confirmar: Solo aparece cuando 'isEditing' es true
            if (isEditing)
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () => setState(() => isEditing = false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Confirmar",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  }