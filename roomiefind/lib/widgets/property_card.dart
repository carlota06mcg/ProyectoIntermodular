import 'package:flutter/material.dart';
import 'package:roomiefind/models/property_model.dart';
import 'package:roomiefind/screens/Owner/createAppartment.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/property_viewmodel.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property; 
  final bool esPropietario; 

  const PropertyCard({
    super.key,
    required this.property,
    this.esPropietario = false,
  });

  // Método privado para no repetir la lógica de navegación
  void _navegarAEditor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioAlojamientoScreen(
          propertyAEditar: property, // Pasamos el piso seleccionado
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
            Navigator.pop(ctx); // Cierra el diálogo
            final propVM = Provider.of<PropertyViewModel>(context, listen: false);
            
            bool ok = await propVM.deleteProperty(property.id!, property.ownerId);
            
            if (ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Alojamiento eliminado"), backgroundColor: Colors.green),
              );
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
      // Hacemos que toda la tarjeta sea clickable si es propietario
      onTap: esPropietario ? () => _navegarAEditor(context) : null,
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
            // IMAGEN DE LA PROPIEDAD
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
                          Row(
                            children: [
                              // BOTÓN ELIMINAR
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () => _confirmarEliminacion(context),
                              ),
                              const SizedBox(width: 4),
                              // TU BOTÓN EDITAR EXISTENTE
                              GestureDetector(
                                onTap: () => _navegarAEditor(context),
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
                              ),
                            ],
                          )
                        ],
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
                              TextSpan(text: "${property.price.toInt()}€", style: const TextStyle(fontWeight: FontWeight.bold)),
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