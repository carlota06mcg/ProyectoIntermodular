import 'package:flutter/material.dart';

class PropertyDetailStatsScreen extends StatelessWidget {
  final Map<String, dynamic> property;

  const PropertyDetailStatsScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(property['title'] ?? "Detalles", 
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de cabecera rápida
            if (property['image_url'] != null)
              Image.network(property['image_url'], height: 200, width: double.infinity, fit: BoxFit.cover),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Rendimiento", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  // Tarjetas de Likes y Rating
                  Row(
                    children: [
                      _buildStatCard("Total Likes", "84", Icons.favorite, Colors.redAccent),
                      const SizedBox(width: 15),
                      _buildStatCard("Calificación", (property['rating'] ?? 0.0).toString(), Icons.star, Colors.amber),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text("Visualizaciones (Clicks)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const Divider(),
                  
                  // Métricas temporales locales
                  _buildClickRow("Último día", "12"),
                  _buildClickRow("Última semana", "145"),
                  _buildClickRow("Último mes", "610"),

                  const SizedBox(height: 40),
                  
                  // RESEÑAS (ESTO ES LOCAL POR AHORA)
                  const Text("Reseñas de inquilinos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildReviewItem("Lucía M.", "El piso está genial y el dueño es muy atento.", 5),
                  _buildReviewItem("Andrés G.", "Buena estancia, aunque el check-in se retrasó un poco.", 4),
                  _buildReviewItem("Kevin S.", "Todo perfecto, muy recomendable para estudiantes.", 5),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildClickRow(String period, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(period, style: const TextStyle(fontSize: 15)),
          Text("$count clics", style: const TextStyle(color: Color(0xFFB82D41), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, String comment, int stars) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(children: List.generate(5, (i) => Icon(Icons.star, size: 12, color: i < stars ? Colors.amber : Colors.grey))),
            ],
          ),
          const SizedBox(height: 5),
          Text(comment, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
      ),
    );
  }
}