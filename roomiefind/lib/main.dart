import 'package:flutter/material.dart';
import 'package:roomiefind/theme/app_theme.dart';
import 'package:roomiefind/screens/screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoomieFind',
      theme: AppTheme.lightTheme,

      home: const HistoryFavScreen(),
    );
  }
}
