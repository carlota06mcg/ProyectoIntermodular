import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/widgets/property_card.dart';
import 'package:roomiefind/models/property_model.dart';
import 'package:roomiefind/viewmodels/property_viewmodel.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // CLAVE: Cargar los datos de la base de datos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropertyViewModel>(context, listen: false).loadHistory();
    });
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
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Historial",
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
      body: Consumer<PropertyViewModel>(
        builder: (context, vm, child) {
          // 1. Mapeamos IDs a modelos reales buscando en la lista global del VM
          final List<PropertyModel> misPropiedadesHistorial = vm.historyIds
              .map((id) {
                try {
                  return vm.properties.firstWhere((p) => p.id == id);
                } catch (e) {
                  return null;
                }
              })
              .whereType<PropertyModel>()
              .toList();

          // 2. Mientras carga y no hay datos, podrías mostrar un spinner (opcional)
          if (vm.isLoading && misPropiedadesHistorial.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }

          // 3. Estado vacío
          if (misPropiedadesHistorial.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_outlined,
                    size: 80,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Tu historial está vacío",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Los pisos que visites aparecerán aquí.",
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          // 4. Listado con RefreshIndicator para poder actualizar a mano
          return RefreshIndicator(
            onRefresh: () => vm.loadHistory(),
            color: primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: misPropiedadesHistorial.length,
              itemBuilder: (context, index) {
                return PropertyCard(
                  property: misPropiedadesHistorial[index],
                  esPropietario: false,
                );
              },
            ),
          );
        },
      ),
    );
  }
}