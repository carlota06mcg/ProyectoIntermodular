import 'package:flutter/material.dart';

class Footerlogin extends StatelessWidget {
  const Footerlogin({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Al hacer clic en continuar, aceptas nuestros Términos de Servicio y nuestra Política de Privacidad",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 20),

      ],
    );
  }
}