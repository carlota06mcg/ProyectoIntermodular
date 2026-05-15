import 'package:flutter/material.dart';

class OwnerBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const OwnerBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Mantengo tu paleta de colores para consistencia visual
    const Color backgroundColor = Color(0xFFEBDDCF); 
    const Color primaryColor = Color(0xFFAE2535); 
    const Color unselectedColor = Color(0xFFC9A696);

    return BottomAppBar(
      color: backgroundColor,
      elevation: 0,
      height: 70, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          _buildNavItem(Icons.send_outlined, 0, primaryColor, unselectedColor),

          _buildNavItem(Icons.graphic_eq_outlined, 1, primaryColor, unselectedColor),

          //_buildNavItem(Icons.add_home_outlined, 2, primaryColor, unselectedColor),

          _buildNavItem(Icons.home_outlined, 3, primaryColor, unselectedColor),

          _buildNavItem(Icons.person_outline, 4, primaryColor, unselectedColor),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, Color selectedColor, Color unselectedColor) {
  final isSelected = currentIndex == index;
  
  return Expanded(
    child: InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(48),
      child: Center( 
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? selectedColor : unselectedColor,
        ),
      ),
    ),
  );
}
}