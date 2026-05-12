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
          // 1. Convertimos los IDs del historial en objetos PropertyModel reales
          // Buscamos dentro de la lista global de propiedades del ViewModel
          final List<PropertyModel> misPropiedadesHistorial = vm.historyIds
              .map((id) {
                try {
                  // Buscamos la propiedad que coincida con el ID del historial
                  return vm.properties.firstWhere((p) => p.id == id);
                } catch (e) {
                  // Si por alguna razón la propiedad ya no existe en la lista global, devolvemos null
                  return null;
                }
              })
              .whereType<PropertyModel>() // Filtramos los nulos
              .toList();

          // 2. Estado si el historial está vacío
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

          // 3. Listado de historial ordenado (el más reciente arriba)
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: misPropiedadesHistorial.length,
            itemBuilder: (context, index) {
              return PropertyCard(
                property: misPropiedadesHistorial[index],
                esPropietario: false,
              );
            },
          );
        },
      ),
    );
  }
}