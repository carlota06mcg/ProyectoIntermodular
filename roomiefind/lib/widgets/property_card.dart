import 'package:flutter/material.dart';
// IMPORTANTE: Ajusta 'tu_proyecto' al nombre real de tu carpeta/app
import 'package:roomiefind/models/property_models.dart'; 

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({
    super.key, 
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos el color de tu tema para consistencia
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Sombra suave para que la tarjeta destaque
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        // Si es favorito, podemos poner un borde sutil
        border: property.isFavorite
            ? Border.all(color: primaryColor.withOpacity(0.2), width: 1)
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEN DE LA PROPIEDAD
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Image.network(
              property.imageUrl,
              width: 130,
              height: 110,
              fit: BoxFit.cover,
              // Manejo de error si la imagen no carga
              errorBuilder: (context, error, stackTrace) => Container(
                width: 130,
                height: 110,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          
          // DETALLES (TEXTOS)
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
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        property.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: primaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Wifi · Kitchen · Free Parking",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 14),
                          Text(" 5.0", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text(
                        "${property.price}/mes",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 14,
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
    );
  }
}