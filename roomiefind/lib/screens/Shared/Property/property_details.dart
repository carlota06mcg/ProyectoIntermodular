import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/models/property_model.dart';
import 'package:roomiefind/screens/Owner/createAppartment.dart';
import 'package:roomiefind/screens/Shared/Chat/chat-plantilla.dart';
import 'package:roomiefind/viewmodels/chat_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
            // 1. Imagen + botón volver
            Stack(
              children: [
                SizedBox(
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

            // 2. Contenido
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título + precio
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

                  // Descripción
                  const Text(
                    "Sobre este alojamiento",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(property.description),

                  const SizedBox(height: 30),

                  // 3. Botón dinámico
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (esPropietario) {
                          // PROPIETARIO → EDITAR
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FormularioAlojamientoScreen(
                                propertyAEditar: property,
                              ),
                            ),
                          );
                        } else {
                          // ESTUDIANTE → CONTACTAR
                          final vm = Provider.of<ChatViewModel>(context, listen: false);

                          // Crear chat si no existe
                          final chatId = await vm.createChatWith(property.ownerId);

                          // Navegar al chat
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPlantillaScreen(
                                chatId: chatId,
                                otherUserId: property.ownerId,
                              ),
                            ),
                          );
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
