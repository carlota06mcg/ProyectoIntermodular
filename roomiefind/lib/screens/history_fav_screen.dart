import 'package:flutter/material.dart';

class HistoryFavScreen extends StatefulWidget {
  const HistoryFavScreen({super.key});

  @override
  State<HistoryFavScreen> createState() => _HistoryFavScreenState();
}

class _HistoryFavScreenState extends State<HistoryFavScreen> {
  int _currentIndex = 3; // Por defecto en el icono de Historial

  @override
  Widget build(BuildContext context) {
    // Determinamos si estamos en Favoritos (índice 4) o Historial (índice 3)
    final bool isFavoriteScreen = _currentIndex == 4;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              isFavoriteScreen ? "Favoritos" : "Historial",
              style: const TextStyle(
                color: Color(0xFFB71C1C),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Container(
              height: 2,
              width: 30,
              color: const Color(0xFFB71C1C),
              margin: const EdgeInsets.only(top: 4),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 10),
        children: [
          // Tarjeta 1 (Aparece en ambas)
          _PropertyCard(
            title: "Student Experience",
            type: "Residencia",
            price: "600€",
            isSelected: isFavoriteScreen, // El borde azul de tu captura
            imageUrl:
                "https://via.placeholder.com/150", // Sustituir por tu imagen
          ),
          // Tarjeta 2 (Solo aparece en Historial según tu captura)
          if (!isFavoriteScreen)
            const _PropertyCard(
              title: "Residencia Kadora Granada",
              type: "Piso compartido",
              price: "350€",
              isSelected: false,
              imageUrl: "https://via.placeholder.com/150",
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFF0E4D7),
        selectedItemColor: const Color(0xFFB71C1C),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.send_outlined), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ""),
        ],
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final String title;
  final String type;
  final String price;
  final bool isSelected;
  final String imageUrl;

  const _PropertyCard({
    required this.title,
    required this.type,
    required this.price,
    required this.isSelected,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: isSelected ? const EdgeInsets.all(2) : null,
      decoration: isSelected
          ? BoxDecoration(border: Border.all(color: Colors.blue, width: 2))
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 130,
              height: 95,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      type,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    Row(
                      children: [
                        _actionButton("Contactar"),
                        const SizedBox(width: 4),
                        Icon(
                          isSelected ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  "4-6 guests · Entire Home · 5 beds · 3 bath\nWifi · Kitchen · Free Parking",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text(
                          "5.0",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.star, color: Colors.orange, size: 12),
                        Text(
                          " (1318 reviews)",
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                    Text(
                      "$price /mes",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10)),
    );
  }
}
