import 'package:flutter/material.dart';
// Importamos el modelo y el widget de la tarjeta
import 'package:roomiefind/widgets/property_card.dart';
import 'package:roomiefind/models/property_models.dart';

class MainmenuScreen extends StatelessWidget {
  const MainmenuScreen({super.key});

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
              "Ubicacion",
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
      // 2. USAMOS LISTVIEW.BUILDER PARA RECORRER EL ARRAY
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: propiedadesPrueba.length, // Cantidad de elementos en el array
        itemBuilder: (context, index) {
          return PropertyCard(
            property: propiedadesPrueba[index], // Pasa el objeto actual del array
            esPropietario: false, // En historial queremos ver favoritos, no editar
          );
        },
      ),
    );
  }
}