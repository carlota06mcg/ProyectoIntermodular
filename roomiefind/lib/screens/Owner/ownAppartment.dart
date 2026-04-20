import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../viewmodels/property_viewmodel.dart';
import '../../widgets/property_card.dart'; 
import 'createAppartment.dart'; 

class MisAlojamientosScreen extends StatefulWidget {
  const MisAlojamientosScreen({super.key});

  @override
  State<MisAlojamientosScreen> createState() => _MisAlojamientosScreenState();
}

class _MisAlojamientosScreenState extends State<MisAlojamientosScreen> {
  @override
  void initState() {
    super.initState();
    // Ejecutamos la carga inicial
    _cargarPropiedades();
  }

  void _cargarPropiedades() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        Provider.of<PropertyViewModel>(context, listen: false).fetchMyProperties(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color customRed = Color(0xFFB02A37);
    // Usamos select para que solo se reconstruya cuando cambie el estado de carga o la lista
    final propVM = context.watch<PropertyViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Text("Mis Alojamientos",
                style: TextStyle(color: customRed, fontWeight: FontWeight.bold, fontSize: 22)),
            Container(margin: const EdgeInsets.only(top: 4), width: 40, height: 3, color: customRed),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          
          // BOTÓN AGREGAR NUEVO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FormularioAlojamientoScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: customRed,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text("Agregar Nuevo Alojamiento", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // LISTADO REAL
          Expanded(
            child: propVM.isLoading
                ? const Center(child: CircularProgressIndicator(color: customRed))
                : propVM.myProperties.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: customRed,
                        onRefresh: () async {
                          final userId = Supabase.instance.client.auth.currentUser?.id;
                          if (userId != null) await propVM.fetchMyProperties(userId);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          itemCount: propVM.myProperties.length,
                          itemBuilder: (context, index) {
                            // IMPORTANTE: Asegúrate de que PropertyCard acepte la navegación
                            return PropertyCard(
                              property: propVM.myProperties[index],
                              esPropietario: true, 
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bed_outlined, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text("Aún no tienes alojamientos publicados.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}