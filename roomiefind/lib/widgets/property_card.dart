import 'package:flutter/material.dart';
import 'package:roomiefind/models/property_models.dart';
import 'package:roomiefind/screens/Owner/createAppartment.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final bool esPropietario; // Nueva variable para controlar la vista

  const PropertyCard({
    super.key,
    required this.property,
    this.esPropietario = false, // Por defecto es false (vista de inquilino)
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

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
            child: Image.network(
              property.imageUrl,
              width: 140, // Ajustado para que se parezca a la imagen 2
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 140,
                height: 120,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
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
                      // LÓGICA CONDICIONAL: Botón Editar o Icono Favorito
                      esPropietario
                          ? GestureDetector(
                              onTap: () {
                                // Aquí navegas al formulario pasando los datos
                                print("Editando: ${property.title}");
                                /* Navigator.push(context, MaterialPageRoute(
                                     builder: (context) => FormularioAlojamientoScreen(alojamientoAEditar: property.toMap())
                                   )); */
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
                          : Icon(
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
                      fontSize: 14, // Tamaño ajustado a la imagen 2
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "4-8 guests · Entire Home · 5 beds · 3 bath",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  const Text(
                    "Wifi · Kitchen · Free Parking",
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 14),
                          Text(" 5.0", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                          Text(" (318 reviews)", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
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
}