import 'package:flutter/material.dart';
import 'package:roomiefind/widgets/property_card.dart';
import 'package:roomiefind/models/property_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFAE2535);

    // Lista de prueba con el modelo actualizado
    final List<PropertyModel> misPropiedadesHistorial = [
      PropertyModel(
        id: "hist_1",
        ownerId: "1",
        title: "Habitación en Centro Histórico",
        type: "Piso Compartido",
        streetNameNumber: "Calle Gran Vía, 12",
        city: "Granada",
        locality: "Centro",
        zipCode: "18001",
        price: 350.0,
        description: "Excelente ubicación cerca de la catedral.",
        imageUrls: ["https://picsum.photos/id/1/400/300"],
        transport: "Líneas de bus 4, 33", 
        services: {"wifi": true, "agua": true},
        additionalInfo: {"mascotas": false},
      ),
      PropertyModel(
        id: "hist_2",
        ownerId: "2",
        title: "Estudio Moderno",
        type: "Estudio",
        streetNameNumber: "Avenida de Italia, 5",
        city: "Granada",
        locality: "Zaidín",
        zipCode: "18007",
        price: 500.0,
        description: "Estudio recién reformado.",
        imageUrls: ["https://picsum.photos/id/2/400/300"],
        transport: "Metro: Parada Hípica", 
        services: {"wifi": true},
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
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Historial",
              style: TextStyle(
                color: primaryColor, 
                fontWeight: FontWeight.bold, 
                fontSize: 18
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
            esPropietario: false, // Añadido para evitar error de parámetros
          );
        },
      ),
    );
  }
}