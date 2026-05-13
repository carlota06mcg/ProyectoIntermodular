import 'dart:io'; // IMPORTANTE
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart'; // IMPORTANTE
import 'package:image_picker/image_picker.dart'; // IMPORTANTE
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/property_viewmodel.dart';
import '../../shared/Profile/settings.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  final Color primaryRed = const Color(0xFFAE2535);

  late TextEditingController descController;
  late TextEditingController locController;

  @override
  void initState() {
    super.initState();
    // LEEMOS LOS DATOS DEL USUARIO REAL INSTANTÁNEAMENTE
    final user = context.read<AuthViewModel>().currentUser;
    
    descController = TextEditingController(text: user?.description ?? "");
    locController = TextEditingController(text: user?.location ?? "");

    // SI ES PROPIETARIO, BUSCAMOS SUS PISOS
    if (user?.role == UserRole.propietario) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PropertyViewModel>().fetchMyProperties(user!.id);
      });
    }
  }

  // ==========================================
  // LÓGICA DE SELECCIÓN Y RECORTE
  // ==========================================
  Future<void> _seleccionarYRecortarImagen() async {
    final picker = ImagePicker();
    final authVM = context.read<AuthViewModel>();

    // 1. Seleccionar de galería
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    // 2. Abrir editor de recorte
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Ajustar Foto de Perfil',
          toolbarColor: primaryRed,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true, // Forzamos cuadrado para el avatar circular
          aspectRatioPresets: [CropAspectRatioPreset.square],
        ),
        IOSUiSettings(
          title: 'Ajustar Foto',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (croppedFile != null) {
      // 3. Subir mediante el ViewModel
      await authVM.updateAvatar(File(croppedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().currentUser;
    final authLoading = context.watch<AuthViewModel>().isLoading;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          children: [
            Text(
              isEditing
  ? "Edición | Perfil"
  : "Mi Perfil - ${user.role == UserRole.estudiante ? 'Estudiante' : 'Propietario'}",
              style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Container(height: 2, width: 30, color: primaryRed, margin: const EdgeInsets.only(top: 4)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: primaryRed, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),

        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(user, authLoading), // Pasamos el estado de carga
            const SizedBox(height: 15),
            
            // NOMBRE Y USERNAME
            Text(user.fullName, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryRed)),
            if (user.username != null && user.username!.isNotEmpty)
              Text("@${user.username}", style: const TextStyle(fontSize: 16, color: Colors.grey)),
            
            const SizedBox(height: 15),

            // INTERCAMBIO ENTRE MODO EDICIÓN Y MODO VISTA
            if (isEditing) 
              _buildEditMode(user)
            else 
              _buildViewMode(user),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(UserModel user, bool isLoading) {
    return GestureDetector(
      onTap: isEditing ? _seleccionarYRecortarImagen : null,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 65,
            backgroundColor: Colors.black,
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null 
                ? const Icon(Icons.person, size: 80, color: Colors.white) 
                : (isLoading ? const CircularProgressIndicator(color: Colors.white) : null),
          ),
          if (isEditing) // El icono solo aparece si estamos editando
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 17,
                backgroundColor: primaryRed,
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // MODO VISTA (Información BBDD + Botón para cambiar a edición))
  // ==========================================
Widget _buildViewMode(UserModel user) {
  final propVM = context.watch<PropertyViewModel>();

  return Column(
    children: [
      ElevatedButton(
        onPressed: () => setState(() => isEditing = true),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        ),
        child: const Text("Editar Perfil", style: TextStyle(color: Colors.white)),
      ),
      const SizedBox(height: 30),

      // Descripción
      Text(
        user.description ?? "Sin descripción asignada.",
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
      const SizedBox(height: 30),

      // Ubicación
      Row(
        children: [
          Icon(Icons.location_on_outlined, color: primaryRed),
          const SizedBox(width: 10),
          Text(user.location ?? "Sin ubicación", style: const TextStyle(fontSize: 14)),
        ],
      ),
      const SizedBox(height: 20),

      // MOSTRAR SEGÚN ROL
      if (user.role == UserRole.estudiante) ...[
        Row(
          children: [
            Icon(Icons.school, color: primaryRed),
            const SizedBox(width: 10),
            Text(user.studies ?? "Sin estudios", style: const TextStyle(fontSize: 14)),
          ],
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Icon(Icons.apartment, color: primaryRed),
            const SizedBox(width: 10),
            Text(user.institution ?? "Sin institución", style: const TextStyle(fontSize: 14)),
          ],
        ),
      ] else ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.domain, color: primaryRed),
            const SizedBox(width: 10),
            Expanded(
              child: propVM.myProperties.isEmpty
                  ? const Text("No tienes propiedades subidas.")
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: propVM.myProperties
                          .map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Text(p.streetNameNumber, style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ],
    ],
  );
}


  // ==========================================
  // MODO EDICIÓN (solo campos editables + botón para confirmar cambios)
  // ==========================================
Widget _buildEditMode(UserModel user) {
  final propVM = context.watch<PropertyViewModel>();

  final studiesController = TextEditingController(text: user.studies ?? "");
  final institutionController = TextEditingController(text: user.institution ?? "");

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Descripción:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      const SizedBox(height: 5),
      TextField(
        controller: descController,
        maxLines: 3,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[300],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 20),

      Row(
        children: [
          Icon(Icons.location_on_outlined, color: primaryRed, size: 20),
          const SizedBox(width: 8),
          const Text("Ubicación:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
      const SizedBox(height: 5),
      TextField(
        controller: locController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[300],
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 20),

      // CAMPOS EXTRA PARA ESTUDIANTE
      if (user.role == UserRole.estudiante) ...[
        const Text("Estudios:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 5),
        TextField(
          controller: studiesController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[300],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),

        const Text("Institución:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 5),
        TextField(
          controller: institutionController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[300],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
      ],

      // PROPIEDADES SOLO PARA PROPIETARIO
      if (user.role == UserRole.propietario) ...[
        Row(
          children: [
            Icon(Icons.domain, color: primaryRed, size: 20),
            const SizedBox(width: 8),
            const Text("Propiedades:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          child: propVM.myProperties.isEmpty
              ? const Text("No hay propiedades.")
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: propVM.myProperties
                      .map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(p.streetNameNumber, style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                ),
        ),
      ],

      const SizedBox(height: 30),
      Center(
        child: ElevatedButton(
          onPressed: () async {
            final updatedUser = UserModel(
              id: user.id,
              email: user.email,
              fullName: user.fullName,
              username: user.username,
              description: descController.text,
              location: locController.text,
              studies: user.role == UserRole.estudiante ? studiesController.text : user.studies,
              institution: user.role == UserRole.estudiante ? institutionController.text : user.institution,
              avatarUrl: user.avatarUrl,
              role: user.role,
            );

            await context.read<AuthViewModel>().updateProfile(updatedUser);
            setState(() => isEditing = false);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
          child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
        ),
      ),
      const SizedBox(height: 40),
    ],
  );
}
}