import 'package:flutter/material.dart';
import 'package:roomiefind/widgets/widgets.dart';
import 'package:roomiefind/models/property_models.dart';

class MisAlojamientosScreen extends StatelessWidget {
  const MisAlojamientosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color customRed = Color(0xFFB02A37);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              "Alojamientos",
              style: TextStyle(
                color: customRed,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 40,
              height: 3,
              color: customRed,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          
          // BOTÓN AGREGAR NUEVO (Estilo Imagen 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ElevatedButton(
              onPressed: () {
                print("Navegando a Formulario de Creación");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: customRed,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 4,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Agregar Nuevo Alojamiento",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // LISTADO DE PROPIEDADES
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: propiedadesPrueba.length,
              itemBuilder: (context, index) {
                return PropertyCard(
                  property: propiedadesPrueba[index],
                  esPropietario: true, // Muestra el botón "Editar"
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}