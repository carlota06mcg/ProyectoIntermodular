import 'package:flutter/material.dart';
import 'package:roomiefind/models/property_model.dart';
import 'package:roomiefind/screens/Owner/createAppartment.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/screens/Shared/Property/property_details.dart';
import '../../viewmodels/property_viewmodel.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property; 
  final bool esPropietario; 

  const PropertyCard({
    super.key,
    required this.property,
    this.esPropietario = false,
  });

  void _navegarAEditor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioAlojamientoScreen(
          propertyAEditar: property,
        ),
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Eliminar alojamiento?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final propVM = Provider.of<PropertyViewModel>(context, listen: false);
              
              // Usamos el ! porque el ID debe existir para eliminar
              if (property.id != null) {
                bool ok = await propVM.deleteProperty(property.id!, property.ownerId);
                
                if (ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Alojamiento eliminado"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color customRed = Color(0xFFB02A37);

    return GestureDetector(
      onTap: () {
        if (esPropietario) {
          _navegarAEditor(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PropertyDetailsScreen(property: property),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGEN ---
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: property.imageUrls.isNotEmpty
                  ? Image.network(
                      property.imageUrls[0],
                      width: 140,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),

            // --- DETALLES ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          property.type.toUpperCase(),
                          style: const TextStyle(
                            color: customRed,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (esPropietario)
                          Row(
                            children: [
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () => _confirmarEliminacion(context),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.edit_note, color: Colors.black54, size: 20),
                            ],
                          )
                      ],
                    ),

                    const SizedBox(height: 4),
                    
                    Text(
                      property.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // UBICACIÓN CORREGIDA
                    Text(
                      "${property.city}, ${property.locality}",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1), 
                            borderRadius: BorderRadius.circular(4)
                          ),
                          child: const Text(
                            "Disponible", 
                            style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black, fontSize: 14),
                            children: [
                              TextSpan(
                                text: "${property.price.toInt()}€",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(
                                text: "/mes",
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 140,
      height: 120,
      color: Colors.grey[200],
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}