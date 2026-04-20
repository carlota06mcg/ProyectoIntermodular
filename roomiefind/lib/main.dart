import 'package:flutter/material.dart';
import 'package:roomiefind/screens/Students/search.dart';
import 'package:roomiefind/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: myAppTheme,
      home: const SearchScreen(), // ← directo al SearchScreen
    );
  }
}
