import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../viewmodels/property_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  final Color primaryRed = const Color(0xFFAE2535);

  // Controladores
  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController locController;
  late TextEditingController studiesController;
  late TextEditingController instController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthViewModel>(context, listen: false).currentUser;
    
    // Rellenamos los controladores con los datos REALES del usuario
    nameController = TextEditingController(text: user?.fullName ?? "");
    descController = TextEditingController(text: user?.description ?? "");
    locController = TextEditingController(text: user?.location ?? "");
    studiesController = TextEditingController(text: user?.studies ?? "");
    instController = TextEditingController(text: user?.institution ?? "");

    if (user?.role == UserRole.propietario) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<PropertyViewModel>(context, listen: false).fetchMyProperties(user!.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? "Edición | Perfil" : "Mi Perfil - ${user.role == UserRole.estudiante ? 'Estudiante' : 'Propietario'}",
          style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAvatar(user),
            const SizedBox(height: 15),
            Text(user.fullName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryRed)),
            const SizedBox(height: 10),
            
            if (!isEditing) 
              ElevatedButton(
                onPressed: () => setState(() => isEditing = true),
                style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
                child: const Text("Editar Perfil", style: TextStyle(color: Colors.white)),
              ),

            const SizedBox(height: 20),
            CustomProfileField(label: "Descripción:", controller: descController, icon: Icons.description, isEditing: isEditing, maxLines: 3),
            CustomProfileField(label: "Ubicación:", controller: locController, icon: Icons.location_on_outlined, isEditing: isEditing),

            // Mostramos campos según el ROL REAL del usuario
            if (user.role == UserRole.estudiante) ...[
              CustomProfileField(label: "Estudios:", controller: studiesController, icon: Icons.book_outlined, isEditing: isEditing),
              CustomProfileField(label: "Institución:", controller: instController, icon: Icons.business_outlined, isEditing: isEditing),
            ] else ...[
              _buildOwnerPropertiesList(), // Lista de pisos para Bea
            ],

            const SizedBox(height: 30),
            if (isEditing) 
              ElevatedButton(
                onPressed: () async {
                  final updatedUser = UserModel(
                    id: user.id,
                    email: user.email,
                    fullName: nameController.text,
                    description: descController.text,
                    location: locController.text,
                    studies: studiesController.text,
                    institution: instController.text,
                    role: user.role,
                  );
                  
                  await authVM.updateProfile(updatedUser);
                  setState(() => isEditing = false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: primaryRed, minimumSize: const Size(150, 45)),
                child: const Text("Confirmar", style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  // --- Widgets de apoyo ---
  Widget _buildAvatar(UserModel user) {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey[200],
      child: const Icon(Icons.person, size: 80, color: Colors.grey),
    );
  }

  Widget _buildOwnerPropertiesList() {
    final propVM = context.watch<PropertyViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Mis Propiedades:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 10),
        ...propVM.myProperties.map((p) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
          child: Text(p.title), // Muestra el título del piso (ej: Apartamento Prueba1)
        )).toList(),
      ],
    );
  }
}

// El widget de campo personalizado
class CustomProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isEditing;
  final int maxLines;

  const CustomProfileField({super.key, required this.label, required this.controller, required this.icon, required this.isEditing, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 18, color: const Color(0xFFAE2535)), const SizedBox(width: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: isEditing,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: isEditing ? Colors.white : Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: isEditing ? const BorderSide(color: Color(0xFFAE2535)) : BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}