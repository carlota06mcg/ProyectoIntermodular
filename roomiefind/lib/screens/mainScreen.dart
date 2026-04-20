import 'package:flutter/material.dart';
import 'package:roomiefind/widgets/widgets.dart';
import 'package:roomiefind/screens/Shared/screen.dart';
import 'package:roomiefind/screens/Students/screen.dart';
import 'package:roomiefind/screens/Students/history.dart';
import 'package:roomiefind/screens/Students/favorites.dart';
import 'package:roomiefind/screens/Owner/screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    FormularioAlojamientoScreen(),
    const MainMenuScreen(),
    const SearchScreen(),
    HistoryScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
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
