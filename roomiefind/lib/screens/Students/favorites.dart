import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/widgets/property_card.dart';
import 'package:roomiefind/models/property_model.dart';
import 'package:roomiefind/viewmodels/property_viewmodel.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Cargamos los datos al entrar por si acaso no están sincronizados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropertyViewModel>(context, listen: false).fetchProperties();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFAE2535);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Mis Favoritos",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Container(
              height: 2,
              width: 30,
              color: primaryColor,
              margin: const EdgeInsets.only(top: 4),
            ),
          ],
        ),
      ),
body: Consumer<PropertyViewModel>(
        builder: (context, vm, child) {
          // 1. Creamos un mapa de las propiedades para buscarlas rápido por ID
          final Map<String, PropertyModel> allPropsMap = {
            for (var p in vm.properties) p.id!: p
          };

          // 2. Construimos la lista de favoritos siguiendo el orden EXACTO de vm.favoriteIds
          // Como en el ViewModel insertamos al principio (posición 0), 
          // esta lista ya saldrá ordenada correctamente.
          final List<PropertyModel> misFavoritos = vm.favoriteIds
              .where((id) => allPropsMap.containsKey(id)) // Solo si la propiedad existe en la lista global
              .map((id) => allPropsMap[id]!)
              .toList();

          if (vm.isLoading && misFavoritos.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          }
          if (misFavoritos.isEmpty) {
            return _buildEmptyState(primaryColor);
          }

          return RefreshIndicator(
            onRefresh: () => vm.fetchProperties(),
            color: primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: misFavoritos.length,
              itemBuilder: (context, index) {
                return PropertyCard(
                  property: misFavoritos[index],
                  esPropietario: false,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: color.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            "Aún no tienes favoritos",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Explora alojamientos y pulsa el corazón para guardarlos aquí.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }
}