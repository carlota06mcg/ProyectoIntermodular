import 'package:flutter/material.dart';
// Importamos el modelo y el widget de la tarjeta
import 'package:roomiefind/widgets/property_card.dart';
import 'package:roomiefind/models/property_models.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos el color rojo de tu tema
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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          PropertyCard(
            property: Property(
              title: "Student Experience",
              type: "Residencia",
              price: "600€",
              imageUrl: "https://via.placeholder.com/150",
              isFavorite: false, // En historial no tiene por qué ser favorito
            ),
          ),
          PropertyCard(
            property: Property(
              title: "Residencia Kadora Granada",
              type: "Piso compartido",
              price: "350€",
              imageUrl: "https://via.placeholder.com/150",
              isFavorite: false,
            ),
          ),
        ],
      ),
    );
  }
}