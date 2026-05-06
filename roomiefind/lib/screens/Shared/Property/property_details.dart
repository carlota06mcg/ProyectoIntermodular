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
    const Color primaryRed = Color(0xFFB02A37);
    const Color secondaryGrey = Color(0xFF757575);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryRed, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Más Información",
          style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TÍTULO, ACCIONES Y RATING
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryRed),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.ios_share, color: primaryRed),
                          const SizedBox(width: 15),
                          Icon(Icons.favorite_border, color: primaryRed),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.directions_bus, color: Colors.black87, size: 22),
                      const SizedBox(width: 10),
                      const Icon(Icons.directions_subway, color: Colors.black87, size: 22),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star_border, color: secondaryGrey, size: 18),
                      const Text(" 4,8 (500 reseñas)  ", style: TextStyle(color: secondaryGrey)),
                      const Icon(Icons.location_on_outlined, color: secondaryGrey, size: 18),
                      const Text(" 2 km", style: TextStyle(color: secondaryGrey)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${property.price.toInt()}€",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const TextSpan(
                          text: " /mes",
                          style: TextStyle(fontSize: 16, color: secondaryGrey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

// 2. CUADRÍCULA DE IMÁGENES (Estilo mosaico del diseño)
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(15),
    child: SizedBox( // Envolvemos el Row aquí
      height: 200,   // Movemos la altura al SizedBox
      child: Row(
        children: [
          // Imagen grande izquierda
          Expanded(
            flex: 2,
            child: _buildImage(property.imageUrls.isNotEmpty ? property.imageUrls[0] : null),
          ),
          const SizedBox(width: 4),
          // Columna derecha con dos pequeñas
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(child: _buildImage(property.imageUrls.length > 1 ? property.imageUrls[1] : null)),
                const SizedBox(height: 4),
                Expanded(child: _buildImage(property.imageUrls.length > 2 ? property.imageUrls[2] : null)),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
),

            // 3. DESCRIPCIÓN
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.description,
                    style: const TextStyle(color: Colors.black87, height: 1.5),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Mostrar más >", style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // 4. UBICACIÓN (Mapa simulado)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text("Ubicación exacta.", style: TextStyle(fontWeight: FontWeight.bold, color: primaryRed)),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: const DecorationImage(
                  image: NetworkImage("https://static.com/map_placeholder.png"), // Cambiar por mapa real si tienes
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 5. RESEÑAS Y ESTADÍSTICAS
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: primaryRed, size: 18),
                      const Text(" 5.0 · 500 reseñas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildStatBar("Limpieza", 5.0)),
                      const SizedBox(width: 40),
                      Expanded(child: _buildStatBar("Transporte", 5.0)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildStatBar("Comunicación", 4.9)),
                      const SizedBox(width: 40),
                      Expanded(child: _buildStatBar("Ubicación", 4.9)),
                    ],
                  ),
                ],
              ),
            ),

            // 6. BOTÓN DE CONTACTO (Fijo abajo o al final)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                    onPressed: () async {
                      if (esPropietario) {
                        // Lógica para editar (tu código actual)
                      } else {
                        try {
                          final vm = Provider.of<ChatViewModel>(context, listen: false);
                          
                          // 1. Esto ahora devolverá el ID SIEMPRE (si existe lo busca, si no lo crea)
                          final String chatId = await vm.createChatWith(property.ownerId);

                          // 2. Navegamos SIEMPRE que tengamos un chatId
                          if (context.mounted && chatId.isNotEmpty) {
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
                        } catch (e) {
                          print("Error al contactar: $e");
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error al abrir el chat: $e")),
                          );
                        }
                      }
                    },
                  child: Text(
                    esPropietario ? "GESTIONAR ALOJAMIENTO" : "CONTACTAR AHORA",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? url) {
    return url != null
        ? Image.network(url, fit: BoxFit.cover)
        : Container(color: Colors.grey[300], child: const Icon(Icons.image));
  }

  Widget _buildStatBar(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            Text(value.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: value / 5,
          backgroundColor: Colors.grey[200],
          color: const Color(0xFFB02A37),
          minHeight: 3,
        ),
      ],
    );
  }
}