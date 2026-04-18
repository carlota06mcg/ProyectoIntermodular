import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'Shared/screen.dart';
import 'package:roomiefind/widgets/widgets.dart';
import 'Students/screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // Lista de tus pantallas reales
  final List<Widget> _pages = [
    MenuChatsScreen(),
    HistoryScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Muestra la página según el índice
      body: _pages[_currentIndex],
      
      // LLAMADA AL WIDGET EXTERNO
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}