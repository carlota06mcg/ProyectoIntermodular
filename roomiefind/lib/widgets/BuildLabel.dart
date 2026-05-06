import 'package:flutter/material.dart';

class BuildLabel extends StatelessWidget {
  final String text;

  const BuildLabel({
    super.key, 
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 14,
        ),
      ),
    );
  }
}