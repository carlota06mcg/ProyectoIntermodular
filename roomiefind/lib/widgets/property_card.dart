import 'package:flutter/material.dart';
import 'package:roomiefind/models/property_models.dart';
import 'package:roomiefind/screens/Owner/createAppartment.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property; // CAMBIO: Usar PropertyModel (el nombre de tu clase)
  final bool esPropietario; 

  const PropertyCard({
    super.key,
    required this.property,
    this.esPropietario = false,
  });

  @override
  Widget build(BuildContext context) {
    const Color customRed = Color(0xFFB02A37);

    return Container(
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
          // IMAGEN DE LA PROPIEDAD
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: property.imageUrls.isNotEmpty
                ? Image.network(
                    property.imageUrls[0], // Toma la primera imagen de la lista
                    width: 140,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),

          // DETALLES
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
                      if (esPropietario)
                        GestureDetector(
                          onTap: () {
                            print("Editando: ${property.title}");
                            // Aquí iría la navegación al formulario
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Editar",
                              style: TextStyle(fontSize: 10, color: Colors.black54),
                            ),
                          ),
                        )
                      else
                        const Icon(Icons.favorite_border, color: customRed, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.location,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 14),
                          Text(" 5.0", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                        ],
                      ),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black, fontSize: 13),
                          children: [
                            TextSpan(text: "${property.price}€", style: const TextStyle(fontWeight: FontWeight.bold)),
                            const TextSpan(text: "/mes", style: TextStyle(fontSize: 10, color: Colors.grey)),
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