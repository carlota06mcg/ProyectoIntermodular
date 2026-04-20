import 'package:flutter/material.dart';
import 'package:roomiefind/models/property_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roomiefind/screens/Owner/createAppartment.dart'; // Ajusta la ruta si es necesario

class PropertyDetailsScreen extends StatelessWidget {
  final PropertyModel property;

  const PropertyDetailsScreen({Key? key, required this.property}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final bool esPropietario = currentUser?.id == property.ownerId;
    final Color primaryRed = const Color(0xFFB02A37);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Imagen y Botón Volver
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  child: property.imageUrls.isNotEmpty
                      ? Image.network(property.imageUrls[0], fit: BoxFit.cover)
                      : Container(color: Colors.grey, child: const Icon(Icons.home, size: 100)),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Título y Precio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "${property.price}€/mes",
                        style: TextStyle(fontSize: 20, color: primaryRed, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(property.location, style: const TextStyle(color: Colors.grey)),
                  
                  const Divider(height: 40),

                  // 3. Descripción
                  const Text("Sobre este alojamiento", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(property.description),

                  const SizedBox(height: 30),

                  // 4. BOTÓN DINÁMICO (Editar o Contactar)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (esPropietario) {
                          // IR A EDITAR
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FormularioAlojamientoScreen(
                                propertyAEditar: property, // Pasamos el objeto completo
                              ),
                            ),
                          );
                        } else {
                          // LÓGICA DE CONTACTO ESTUDIANTE
                        }
                      },
                      child: Text(
                        esPropietario ? "Editar Alojamiento" : "Contactar con Propietario",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}