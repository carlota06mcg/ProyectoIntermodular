import 'package:flutter/material.dart';
import 'package:roomiefind/widgets/property_card.dart';
import 'package:roomiefind/models/property_models.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFAE2535);

    // 1. LISTA DE PRUEBA TEMPORAL (Datos compatibles con PropertyModel)
    final List<PropertyModel> resultadosBusqueda = [
      PropertyModel(
        ownerId: "search_1",
        title: "Apartamento luminoso cerca del Campus",
        type: "Apartamento",
        location: "Granada, Camino de Ronda",
        price: 450.0,
        description: "Ideal para estudiantes de ciencias.",
        imageUrls: ["https://via.placeholder.com/300"],
        transport: {"Bus": true, "Metro": true},
        services: {"Wifi": true, "Calefacción": true},
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
              "Buscar", // Corregido el título
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
      body: Column(
        children: [
          // BARRA DE BÚSQUEDA VISUAL
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Buscar por zona o tipo...",
                prefixIcon: const Icon(Icons.search, color: primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          
          // LISTADO DE RESULTADOS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: resultadosBusqueda.length, 
              itemBuilder: (context, index) {
                return PropertyCard(
                  property: resultadosBusqueda[index], 
                  esPropietario: false, 
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}