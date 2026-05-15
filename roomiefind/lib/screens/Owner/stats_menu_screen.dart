import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roomiefind/models/property_model.dart'; // Asegúrate de que la ruta es correcta
import 'property_detail_stats_screen.dart';

class OwnerStatsScreen extends StatefulWidget {
  const OwnerStatsScreen({super.key});

  @override
  State<OwnerStatsScreen> createState() => _OwnerStatsScreenState();
}

class _OwnerStatsScreenState extends State<OwnerStatsScreen> {
  final _supabase = Supabase.instance.client;
  
  // Definimos el Stream usando el Modelo
  late Stream<List<PropertyModel>> _propertiesStream;

  @override
  void initState() {
    super.initState();
    _initPropertiesStream();
  }

  void _initPropertiesStream() {
  final userId = _supabase.auth.currentUser?.id;

  _propertiesStream = _supabase
      .from('properties')
      .stream(primaryKey: ['id']) // Crucial que sea 'id'
      .eq('owner_id', userId ?? '')
      .map((data) {
        // Al convertir los datos, forzamos la creación de una nueva lista.
        // Esto ayuda a Flutter a detectar que la longitud de la lista ha cambiado (borrado).
        return data.map((json) => PropertyModel.fromJson(json)).toList();
      });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Estadísticas de Mis Alojamientos",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<PropertyModel>>(
        stream: _propertiesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFB82D41)));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final properties = snapshot.data ?? [];

          if (properties.isEmpty) {
            return const Center(
              child: Text("No tienes propiedades publicadas", 
                style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              return _buildPropertyCard(context, properties[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, PropertyModel property) {
    // Usamos directamente la lista del modelo
    final String? firstImageUrl = property.imageUrls.isNotEmpty ? property.imageUrls[0] : null;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          // Pasamos el toJson() para que la pantalla de detalles siga recibiendo un Map si así lo tenías
          builder: (context) => PropertyDetailStatsScreen(property: property.toJson()),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 10, 
              offset: const Offset(0, 5)
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGEN
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: firstImageUrl != null
                  ? Image.network(
                      firstImageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.home_work_outlined, size: 50, color: Colors.grey),
                    ),
            ),
            
            // CONTENIDO
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.title, // <--- Actualización en tiempo real
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 16,
                            color: Colors.black87
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${property.city}, ${property.locality}",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  // PRECIO O RATING
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${property.price.toStringAsFixed(0)}€",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Color(0xFFB82D41),
                          fontSize: 18
                        ),
                      ),
                      const Text(
                        "al mes",
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
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