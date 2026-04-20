import 'package:flutter/material.dart';
import 'package:roomiefind/widgets/property_card.dart';
import 'package:roomiefind/models/property_models.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

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
              "Favoritos",
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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          // CAMBIO: Ahora usamos PropertyModel con los campos obligatorios que definiste
          PropertyCard(
            property: PropertyModel(
              ownerId: "mock_id", // ID temporal
              title: "Student Experience",
              type: "Residencia",
              location: "Granada, España",
              price: 600.0, // Ahora es un double, no String con €
              description: "Residencia universitaria con todos los servicios.",
              imageUrls: ["https://via.placeholder.com/150"],
              transport: {},
              services: {"Wifi": true},
              additionalInfo: {},
            ),
            esPropietario: false, // Como es favoritos, el usuario es estudiante
          ),
        ],
      ),
    );
  }
}