import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Colores basados en tu tema y diseño
    const Color backgroundColor = Color(0xFFEBDDCF); 

    return BottomAppBar(
      color: backgroundColor,
      elevation: 0,
      height: 70, // Altura ajustada para que respire el diseño
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 0),
          _buildNavItem(Icons.send_outlined, 1),
          _buildNavItem(Icons.search, 2),
          _buildNavItem(Icons.history, 3),
          _buildNavItem(Icons.favorite_border, 4),
          _buildNavItem(Icons.person_outline, 5),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
  final isSelected = currentIndex == index;
  
  return Expanded(
    child: InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(48),
      child: Center( 
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? const Color(0xFFAE2535) : const Color(0xFFC9A696),
        ),
      ),
    ),
  );
}
}