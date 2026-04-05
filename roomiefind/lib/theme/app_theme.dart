import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryRed = Color(0xAE2535);
  static const Color navBarColor = Color(0xEBDECF);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryRed,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryRed,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
