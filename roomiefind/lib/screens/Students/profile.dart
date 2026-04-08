import 'package:flutter/material.dart';
import 'package:roomiefind/screens/Students/settings.dart';

class ProfileScreen extends StatefulWidget {
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

            // Llamamos a la función auxiliar para renderizar cada fila
            _buildField(
              "Descripción:",
              descController,
              Icons.description,
              isEditing,
              maxLines: 3,
            ),
            _buildField(
              "Ubicación:",
              locController,
              Icons.location_on_outlined,
              isEditing,
            ),
            _buildField(
              "Estudios:",
              studiesController,
              Icons.book_outlined,
              isEditing,
            ),
            _buildField(
              "Institución:",
              instController,
              Icons.business_outlined,
              isEditing,
            ),

            // Redes sociales: Solo se muestra si estamos editando o si ya tiene contenido
            if (isEditing || instagramController.text.isNotEmpty)
              _buildField(
                "Redes sociales (Instagram):",
                instagramController,
                Icons.camera_alt_outlined,
                isEditing,
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

  // =============================================================
  // 5. WIDGET AUXILIAR (BUILDER) - REUTILIZACIÓN DE CÓDIGO
  // =============================================================

  /// Esta función crea una fila que contiene un icono y, o bien un texto,
  /// o bien un cuadro de entrada (Input) dependiendo del valor de [editing].
  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool editing, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En modo edición, mostramos una etiqueta pequeña arriba del campo
          if (editing)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: primaryRed, size: 28),
              const SizedBox(width: 15),
              Expanded(
                child: editing
                    ? // --- VISTA DE EDICIÓN (Input gris redondeado) ---
                      Container(
                        decoration: BoxDecoration(
                          color: lightGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: controller,
                          maxLines: maxLines,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(10),
                          ),
                        ),
                      )
                    : // --- VISTA DE LECTURA (Texto normal) ---
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          controller.text,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
