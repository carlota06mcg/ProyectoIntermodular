import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:roomiefind/widgets/widgets.dart'; // Importa tu widget externo

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // Lista de tus pantallas reales
  final List<Widget> _pages = [
    const HomeScreen(),      // Indice 0
    const ChatScreen(),      // Indice 1
    const SearchScreen(),    // Indice 2
    const HistoryScreen(),   // Indice 3
    const FavoritesScreen(), // Indice 4
    const SettingsScreen(),  // Indice 5 (La de Ajustes que hicimos antes)
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

  // 7. WIDGET PRIVADO PARA CADA ÍTEM DE NAVEGACIÓN
  Widget _buildNavItem({required IconData icon, required int index, required String label}) {
    // Determinamos si este ítem es el seleccionado actual
    final bool isSelected = (_selectedIndex == index);

    return InkWell(
      // 8. Efecto "Ink" al tocar el icono (ripple effect)
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(100), // Efecto circular
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min, // El contenido debe ser mínimo
          children: [
            // Icono: Cambia de color y tamaño si está seleccionado
            Icon(
              icon,
              size: isSelected ? 28 : 24, // Icono un poco más grande si seleccionado
              color: isSelected ? primaryColor : unselectedIconColor, // Cambio de color
            ),
            // Opcional: Texto label debajo del icono (se puede quitar si prefieres solo iconos)
            // if (isSelected) // Mostrar texto solo si seleccionado
            //   Text(
            //     label,
            //     style: const TextStyle(
            //       color: primaryColor,
            //       fontSize: 12,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}