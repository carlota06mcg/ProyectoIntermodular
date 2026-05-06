import 'package:flutter/material.dart';

class CustomPropertyImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;

  const CustomPropertyImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover, // Valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    // Si la URL es nula, mostramos el placeholder directamente
    if (url == null || url!.isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      url!,
      fit: fit,
      // Maneja errores de carga (ej. URL rota o sin internet)
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      // Opcional: puedes añadir un loadingBuilder para mostrar un spinner mientras descarga
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.image,
        color: Colors.grey,
        size: 30,
      ),
    );
  }
}