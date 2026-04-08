import 'package:flutter/material.dart';

class HistoryFavScreen extends StatefulWidget {
  // Pasamos el índice como parámetro para que la pantalla sepa qué mostrar
  final bool showFavorites; 

  const HistoryFavScreen({super.key, this.showFavorites = false});

  @override
  State<HistoryFavScreen> createState() => _HistoryFavScreenState();
}

class _HistoryFavScreenState extends State<HistoryFavScreen> {
  @override
  Widget build(BuildContext context) {
    // Usamos el parámetro pasado para definir el título
    final String screenTitle = widget.showFavorites ? "Favoritos" : "Historial";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              screenTitle,
              style: const TextStyle(
                color: Color(0xFFAE2535), // Tu rojo RoomieFind
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Container(
              height: 2,
              width: 30,
              color: const Color(0xFFAE2535),
              margin: const EdgeInsets.only(top: 4),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 10),
        children: [
          // Tarjeta 1
          _PropertyCard(
            title: "Student Experience",
            type: "Residencia",
            price: "600€",
            isSelected: widget.showFavorites, 
            imageUrl: "https://via.placeholder.com/150", 
          ),
          // Tarjeta 2 - Solo se muestra si no es favoritos (ejemplo)
          if (!widget.showFavorites)
            const _PropertyCard(
              title: "Residencia Kadora Granada",
              type: "Piso compartido",
              price: "350€",
              isSelected: false,
              imageUrl: "https://via.placeholder.com/150",
            ),
        ],
      ),
      // ELIMINADO: El bottomNavigationBar ya no está aquí porque lo gestiona MainWrapper
    );
  }
}

// --- WIDGET DE TARJETA (Mantenemos tu diseño) ---

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
                          color: const Color(0xFFAE2535),
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Text(
                  "4-6 guests · Entire Home · 5 beds · 3 bath\nWifi · Kitchen · Free Parking",
                  style: TextStyle(color: Colors.grey, fontSize: 10, height: 1.2),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text("5.0", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        Icon(Icons.star, color: Colors.orange, size: 12),
                        Text(" (1318 reviews)", style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                    Text(
                      "$price /mes",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
