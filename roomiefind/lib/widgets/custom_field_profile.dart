import 'package:flutter/material.dart';

class CustomProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final bool isEditing;
  final bool esPropietario;
  final int maxLines;

  const CustomProfileField({
    super.key,
    required this.label,
    required this.controller,
    required this.isEditing,
    required this.esPropietario,
    this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    // Colores para que contraste
    const Color primaryRed = Color(0xFFAE2535);
    const Color inputGrey = Color(0xFFF2F2F2); // Un gris suave que resalta sobre el blanco puro

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Icon(icon, color: primaryRed, size: 24),
                ),
                const SizedBox(width: 12),
              ],
              
              Expanded(
                child: isEditing
                    ? TextFormField(
                        controller: controller,
                        maxLines: maxLines,
                        decoration: InputDecoration(
                          filled: true, // ¡IMPORTANTE! Activa el color de fondo
                          fillColor: inputGrey, // El color gris que querías
                          contentPadding: const EdgeInsets.all(15),
                          // Bordes redondeados y sin línea
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 12, left: 5),
                        child: Text(
                          controller.text,
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}