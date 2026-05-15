import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'property_detail_stats_screen.dart';

class OwnerStatsScreen extends StatefulWidget {
  const OwnerStatsScreen({super.key});

  @override
  State<OwnerStatsScreen> createState() => _OwnerStatsScreenState();
}

class _OwnerStatsScreenState extends State<OwnerStatsScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _myProperties = [];

  @override
  void initState() {
    super.initState();
    _loadOwnerProperties();
  }

  Future<void> _loadOwnerProperties() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      final data = await _supabase
          .from('properties')
          .select()
          .eq('owner_id', userId as Object);

      setState(() {
        _myProperties = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error cargando propiedades: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Estadísticas", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFB82D41)))
        : _myProperties.isEmpty
          ? const Center(child: Text("No tienes propiedades publicadas"))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _myProperties.length,
              itemBuilder: (context, index) {
                final property = _myProperties[index];
                return _buildPropertyCard(context, property);
              },
            ),
    );
  }

 Widget _buildPropertyCard(BuildContext context, Map<String, dynamic> property) {
  // 1. Extraemos la lista de imágenes
  final List<dynamic>? urls = property['imageUrls'];
  
  // 2. Cogemos la primera si existe y no está vacía
  final String? firstImageUrl = (urls != null && urls.isNotEmpty) 
      ? urls[0].toString() 
      : null;

  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailStatsScreen(property: property),
      ),
    ),
    child: Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: firstImageUrl != null 
              ? Image.network(
                  firstImageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                )
              : Container(
                  height: 180, 
                  color: Colors.grey.shade200, 
                  child: const Icon(Icons.home_work_outlined, size: 50, color: Colors.grey),
                ),
          ),
          // ... resto del código (título, rating, etc.) igual que antes
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    property['title'] ?? 'Sin título', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(" ${(property['rating'] ?? 0.0)}"),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}