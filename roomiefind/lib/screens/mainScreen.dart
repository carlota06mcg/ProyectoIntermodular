import 'package:flutter/material.dart';
import 'package:roomiefind/widgets/widgets.dart'; // Aquí deben estar tus NavBars
import 'package:roomiefind/screens/screen.dart'; // Barrel file con todas las pantallas

class MainWrapper extends StatefulWidget {
  final bool isOwner; // Añadimos esta variable para distinguir el rol

  const MainWrapper({super.key, this.isOwner = false});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // 1. Páginas para ESTUDIANTES
  final List<Widget> _studentPages = [
    const MainmenuScreen(),       // Index 0: Home/Busqueda
    const MenuChatsScreen(),      // Index 1: Chats
    const SearchScreen(),         // Index 2: Buscar
    const HistoryScreen(),        // Index 3: Historial
    const FavoritesScreen(),      // Index 4: Favoritos
    const ProfileScreen(),  // Index 5: Perfil
  ];

  // 2. Páginas para PROPIETARIOS (Basado en la barra que hicimos antes)
  final List<Widget> _ownerPages = [
    const MenuChatsScreen(),        // Index 0: Mensajes
    const HistoryScreen(),          // Index 1: Calendario/Reservas (o la que decidas)
    const FormularioAlojamientoScreen(), // Index 2: Añadir Casa
    const MisAlojamientosScreen(),    // Index 3: Mis Propiedades/Home
    const ProfileScreen(),    // Index 4: Perfil
  ];

  @override
  Widget build(BuildContext context) {
    // Seleccionamos la lista de páginas según el rol
    final pages = widget.isOwner ? _ownerPages : _studentPages;

    return Scaffold(
      body: IndexedStack( // Usar IndexedStack mantiene el estado de las páginas al cambiar
        index: _currentIndex,
        children: pages,
      ),
      
      // Cambiamos la barra según el rol
      bottomNavigationBar: widget.isOwner
        ? OwnerBottomNavBar( // La que creamos al principio
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          )
        : CustomBottomNavBar( // La de estudiantes
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
    );
  }
}
