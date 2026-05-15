import 'package:flutter/material.dart';
import 'package:roomiefind/widgets/widgets.dart'; 
import 'package:roomiefind/screens/screen.dart'; // Usamos el barrel que ya tiene todo

class MainWrapper extends StatefulWidget {
  final bool isOwner;

  const MainWrapper({super.key, this.isOwner = false});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // 1. Páginas para ESTUDIANTES
  final List<Widget> _studentPages = [
    const MainmenuScreen(),       
    const MenuChatsScreen(),      
    const SearchScreen(),         
    const HistoryScreen(),        
    const FavoritesScreen(),      
    const ProfileScreen(),        
  ];

  // 2. Páginas para PROPIETARIOS
  final List<Widget> _ownerPages = [
    const MenuChatsScreen(),             // Index 0: Mensajes
    const OwnerStatsScreen(),            // Index 1: ESTADÍSTICAS (Nombre de clase corregido)
    const FormularioAlojamientoScreen(),  // Index 2: Añadir Casa
    const MisAlojamientosScreen(),        // Index 3: Mis Propiedades
    const ProfileScreen(),                // Index 4: Perfil
  ];

  @override
  Widget build(BuildContext context) {
    final pages = widget.isOwner ? _ownerPages : _studentPages;

    return Scaffold(
      body: IndexedStack( 
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: widget.isOwner
        ? OwnerBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          )
        : CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
    );
  }
}