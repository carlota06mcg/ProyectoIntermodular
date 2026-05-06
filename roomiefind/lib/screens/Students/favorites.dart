import 'package:flutter/material.dart';
import 'package:roomiefind/widgets/property_card.dart';
import 'package:roomiefind/models/property_model.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFAE2535);

    // Lista de favoritos con datos quemados (Mock Data) siguiendo el nuevo modelo
    final List<PropertyModel> misFavoritos = [
      PropertyModel(
        id: "fav_1",
        ownerId: "owner_1",
        title: "Student Experience",
        type: "Residencia",
        streetNameNumber: "Calle de la Paz, 22",
        city: "Granada",
        locality: "Centro",
        zipCode: "18002",
        price: 600.0,
        description: "Residencia universitaria con todo incluido.",
        imageUrls: ["https://picsum.photos/id/10/400/300"],
        transport: "Metro Recogidas",
        services: {"wifi": true, "gym": true},
        additionalInfo: {"limpieza": true},
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
              "Favoritos",
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
        itemCount: misFavoritos.length,
        itemBuilder: (context, index) {
          return PropertyCard(
            property: misFavoritos[index],
            esPropietario: false, // Importante para que coincida con el widget
          );
        },
      ),
    );
  }
}