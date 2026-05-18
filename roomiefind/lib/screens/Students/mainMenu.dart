import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/models/property_model.dart';
import 'package:roomiefind/screens/Shared/Property/property_details.dart';
import 'package:roomiefind/viewmodels/property_viewmodel.dart';
import 'package:roomiefind/widgets/widgets.dart'; // Para tu CustomPropertyImage

class MainmenuScreen extends StatefulWidget {
  const MainmenuScreen({super.key});

  @override
  State<MainmenuScreen> createState() => _MainmenuScreenState();
}

class _MainmenuScreenState extends State<MainmenuScreen> {
  final Color primaryColor = const Color(0xFFAE2535);
  final Color textDark = const Color(0xFF1A1A1A);
  final Color textMuted = const Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final propVM = Provider.of<PropertyViewModel>(context, listen: false);
      propVM.fetchProperties();
      propVM.loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<PropertyViewModel>(
        builder: (context, propVM, child) {
          if (propVM.isLoading) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          final allProps = propVM.properties;
          
          // Repartimos tus 6 pisos para rellenar las secciones como en tu mockup
          final recomendados = allProps.take(3).toList();
          final cercaDeTi = allProps.skip(1).take(4).toList(); // Necesita unos 4 para el grid horizontal doble
          final favoritosUHistorial = allProps.toList(); // Para la lista vertical "Populares para ti"

          return RefreshIndicator(
            onRefresh: () async {
              await propVM.fetchProperties();
              await propVM.loadHistory();
            },
            color: primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. SELECTOR DE UBICACIÓN
                  _buildLocationHeader(),

                  // 2. BARRA DE BÚSQUEDA
                  _buildSearchBar(),

                  // 3. BANNER DE PUBLICIDAD
                  _buildPromoBanner(),

                  // 4. SECCIÓN RECOMENDADOS (CARRUSEL GRANDE)
                  if (recomendados.isNotEmpty) ...[
                    _buildSectionTitle("Recomendados", showSeeAll: true),
                    _buildRecomendadosCarousel(recomendados, propVM),
                  ],

                  // 5. SECCIÓN CERCA DE TI (GRID HORIZONTAL DE 2 FILAS)
                  if (cercaDeTi.isNotEmpty) ...[
                    _buildSectionTitle("Cerca de ti", showSeeAll: true, labelSeeAll: "Ver todo"),
                    _buildCercaDeTiGrid(cercaDeTi),
                  ],

                  // 6. SECCIÓN POPULAR FOR YOU (LISTA VERTICAL)
                  _buildSectionTitle("Populares para ti", showSeeAll: true, labelSeeAll: "Ver todo"),
                  if (favoritosUHistorial.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No hay alojamientos todavía")))
                  else
                    _buildPopularVerticalList(favoritosUHistorial, propVM),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- COMPONENTES DE DISEÑO DIRECTOS ---

  Widget _buildLocationHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Ubicación", style: TextStyle(color: textMuted, fontSize: 12)),
              Icon(Icons.keyboard_arrow_down, color: primaryColor, size: 16),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: primaryColor, size: 18),
              const SizedBox(width: 4),
              Text(
                "Granada, España",
                style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Icon(Icons.search, color: primaryColor, size: 22),
                  const SizedBox(width: 10),
                  Text("Buscar", style: TextStyle(color: Colors.grey.shade400, fontSize: 15)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(Icons.tune, color: primaryColor, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      alignment: Alignment.centerLeft,
      child: const Text(
        "PUBLICIDAD",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showSeeAll = false, String labelSeeAll = "Ver todo"}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
          if (showSeeAll)
            Text(labelSeeAll, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primaryColor)),
        ],
      ),
    );
  }

  // 4. CARRUSEL RECOMENDADOS (TARJETAS GRANDES CON CONTENIDO SUPERPUESTO)
  Widget _buildRecomendadosCarousel(List<PropertyModel> list, PropertyViewModel vm) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 10),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final p = list[index];
          final bool isFav = p.id != null && vm.favoriteIds.contains(p.id);
          final String img = p.imageUrls.isNotEmpty ? p.imageUrls[0] : '';

          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: p))),
            child: Container(
              width: 240,
              margin: const EdgeInsets.only(right: 15),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: CustomPropertyImage(url: img),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Text("${p.price.toInt()}€/mes", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    left: 15,
                    right: 15,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.white70, size: 12),
                                  const SizedBox(width: 2),
                                  Expanded(child: Text("${p.locality}, ${p.city}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () { if (p.id != null) vm.toggleFavorite(p.id!); },
                          child: Container(
                            height: 34, width: 34,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 18),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 5. CERCA DE TI (GRID HORIZONTAL DE 2 FILAS COMPACTAS)
  Widget _buildCercaDeTiGrid(List<PropertyModel> list) {
    return SizedBox(
      height: 160,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.32, 
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final p = list[index];
          final String img = p.imageUrls.isNotEmpty ? p.imageUrls[0] : '';

          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: p))),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(width: 70, height: 70, child: CustomPropertyImage(url: img)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text("${p.locality}, ${p.city}", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: textMuted, fontSize: 11)),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${p.price.toInt()}€/mes", style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 12)),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange, size: 12),
                              Text(" 4.7", style: TextStyle(color: textDark, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // 6. POPULAR FOR YOU (LISTA VERTICAL TRADICIONAL LIMPIA)
  Widget _buildPopularVerticalList(List<PropertyModel> list, PropertyViewModel vm) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final p = list[index];
        final bool isFav = p.id != null && vm.favoriteIds.contains(p.id);
        final String img = p.imageUrls.isNotEmpty ? p.imageUrls[0] : '';

        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: p))),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(width: 85, height: 85, child: CustomPropertyImage(url: img)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text("${p.locality}, ${p.city}", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: textMuted, fontSize: 12)),
                      const SizedBox(height: 6),
                      Text("${p.price.toInt()}€/mes", style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () { if (p.id != null) vm.toggleFavorite(p.id!); },
                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red, size: 22),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        Text(" 4.5", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textDark)),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}