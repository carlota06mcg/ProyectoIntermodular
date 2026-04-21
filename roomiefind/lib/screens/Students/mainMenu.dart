import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importante para usar Consumer
import 'package:roomiefind/widgets/property_card.dart';
import 'package:roomiefind/models/property_model.dart';
import 'package:roomiefind/viewmodels/property_viewmodel.dart';

class MainmenuScreen extends StatefulWidget {
  const MainmenuScreen({super.key});

  @override
  State<MainmenuScreen> createState() => _MainmenuScreenState();
}

class _MainmenuScreenState extends State<MainmenuScreen> {
  @override
  void initState() {
    super.initState();
    // 1. Cargamos las propiedades de Supabase al iniciar la pantalla
    Future.microtask(() =>
        Provider.of<PropertyViewModel>(context, listen: false).fetchProperties());
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFAE2535);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              "Explorar Alojamientos",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Container(
              height: 2,
              width: 30,
              color: primaryColor,
              margin: const EdgeInsets.only(top: 4),
            ),
          ],
        ),
      ),
      // 2. Usamos Consumer para escuchar los cambios en PropertyViewModel
      body: Consumer<PropertyViewModel>(
        builder: (context, propVM, child) {
          // A. Si está cargando datos de Supabase
          if (propVM.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }

          // B. Si hubo un error
          if (propVM.errorMessage != null) {
            return Center(
              child: Text("Error al cargar: ${propVM.errorMessage}"),
            );
          }

          // C. Si la lista está vacía
          if (propVM.properties.isEmpty) {
            return const Center(
              child: Text("No hay alojamientos disponibles aún."),
            );
          }

          // D. ÉXITO: Mostramos los datos reales
          return RefreshIndicator(
            onRefresh: () => propVM.fetchProperties(),
            color: primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: propVM.properties.length,
              itemBuilder: (context, index) {
                final propiedad = propVM.properties[index];
                return PropertyCard(
                  property: propiedad,
                  esPropietario: false, // El estudiante no puede editar
                );
              },
            ),
          );
        },
      ),
    );
  }
}