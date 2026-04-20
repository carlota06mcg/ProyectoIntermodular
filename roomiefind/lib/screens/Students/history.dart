import 'package:flutter/material.dart';
import 'package:roomiefind/widgets/property_card.dart';
import 'package:roomiefind/models/property_models.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFAE2535);

    // 1. LISTA DE PRUEBA TEMPORAL (Para que no de error 'propiedadesPrueba')
    final List<PropertyModel> misPropiedadesHistorial = [
      PropertyModel(
        ownerId: "1",
        title: "Habitación en Centro Histórico",
        type: "Piso compartido",
        location: "Granada, España",
        price: 350.0,
        description: "Excelente ubicación cerca de la catedral.",
        imageUrls: ["https://via.placeholder.com/150"],
        transport: {"Bus": true},
        services: {"Wifi": true, "Agua": true},
        additionalInfo: {"Mascotas": false},
      ),
      PropertyModel(
        ownerId: "2",
        title: "Estudio Moderno",
        type: "Estudio",
        location: "Zaidín, Granada",
        price: 500.0,
        description: "Estudio recién reformado.",
        imageUrls: ["https://via.placeholder.com/150"],
        transport: {"Metro": true},
        services: {"Wifi": true},
        additionalInfo: {},
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Column(
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
      body: ListView.builder(
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
  }
}