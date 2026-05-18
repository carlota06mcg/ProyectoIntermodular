import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http; // Necesitaremos http para buscar lugares
import 'package:roomiefind/models/property_model.dart';
import 'package:roomiefind/screens/Shared/Property/property_details.dart';
import 'package:roomiefind/viewmodels/property_viewmodel.dart';
import 'package:roomiefind/widgets/widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  PropertyModel? _selectedProperty; 
  bool _isSearchingLocation = false;
  
  // Guardamos los límites actuales de la pantalla del mapa
  LatLngBounds? _currentBounds;
  
  final Color primaryRed = const Color(0xFFB02A37);
  final LatLng _defaultCenter = const LatLng(37.177336, -3.598557); // Granada

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropertyViewModel>(context, listen: false).fetchProperties().then((_) {
        _centrarMapaEnPropiedades();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Función para buscar cualquier texto en OpenStreetMap y mover la cámara allí
  Future<void> _buscarYEnfocarLugar(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() => _isSearchingLocation = true);
    FocusScope.of(context).unfocus();

    try {
      // Afinamos la búsqueda añadiendo ", Granada" para que priorice tu zona de pruebas
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query + ", Granada")}&format=json&limit=1'
      );
      
      final response = await http.get(url, headers: {'User-Agent': 'roomiefind_app'});

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          
          // Movemos el mapa a la ubicación encontrada de forma instantánea
          _mapController.move(LatLng(lat, lon), 15.5);
          
          // Limpiamos selección anterior
          setState(() => _selectedProperty = null);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No se encontró esa zona. Intenta ser más específico.")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error buscando lugar: $e");
    } finally {
      setState(() => _isSearchingLocation = false);
    }
  }

  void _centrarMapaEnPropiedades() {
    final properties = Provider.of<PropertyViewModel>(context, listen: false).properties;
    final validProperties = properties.where((p) => p.latitude != null && p.longitude != null).toList();

    if (validProperties.isNotEmpty) {
      double totalLat = 0;
      double totalLng = 0;
      for (var p in validProperties) {
        totalLat += p.latitude!;
        totalLng += p.longitude!;
      }
      _mapController.move(LatLng(totalLat / validProperties.length, totalLng / validProperties.length), 14.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyVM = context.watch<PropertyViewModel>();
    final allProperties = propertyVM.properties;
    
    // FILTRADO DINÁMICO POR VISIBILIDAD DE PANTALLA (BBOX)
    final visibleProperties = allProperties.where((property) {
      if (property.latitude == null || property.longitude == null) return false;
      if (_currentBounds == null) return true; // Si aún no se ha calculado el radio, muestra todos

      final point = LatLng(property.latitude!, property.longitude!);
      // Comprueba si las coordenadas del piso están DENTRO del cuadrado visible de la pantalla
      return _currentBounds!.contains(point);
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          // 1. EL MAPA BASE
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 14.0,
              onMapReady: () {
                // Al cargar, guardamos los límites iniciales de la pantalla
                setState(() => _currentBounds = _mapController.camera.visibleBounds);
              },
              onPositionChanged: (position, hasGesture) {
                // ESTA ES LA CLAVE: Cada vez que el usuario arrastra el mapa, hace zoom o se mueve a una zona,
                // recalculamos los límites de la pantalla para filtrar los marcadores en tiempo real.
                setState(() {
                  _currentBounds = position.visibleBounds;
                });
              },
              onTap: (_, __) {
                setState(() => _selectedProperty = null);
                FocusScope.of(context).unfocus();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.roomiefind.app',
              ),
              
              // 2. CAPA DE MARCADORES QUE SE RECALCULAN POR VISIBILIDAD
              MarkerLayer(
                markers: visibleProperties.map((property) {
                  final bool isSelected = _selectedProperty?.id == property.id;
                  
                  return Marker(
                    point: LatLng(property.latitude!, property.longitude!),
                    width: 75,
                    height: 35,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedProperty = property);
                        _mapController.move(LatLng(property.latitude!, property.longitude!), 15.5);
                        FocusScope.of(context).unfocus();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryRed : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                          ],
                          border: Border.all(
                            color: isSelected ? Colors.white : primaryRed.withOpacity(0.5), 
                            width: 1.5
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${property.price.toInt()}€",
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 3. BARRA DE BÚSQUEDA GEOGRÁFICA SUPERIOR
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            right: 15,
            child: _buildFloatingSearchBar(),
          ),

          // INDICADOR DE CARGA (Para el loader de la API de mapas o Supabase)
          if (propertyVM.isLoading || _isSearchingLocation)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: MediaQuery.of(context).size.width * 0.45,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: CircularProgressIndicator(color: primaryRed),
              ),
            ),

          // 4. TARJETA FLOTANTE INFERIOR
          if (_selectedProperty != null)
            Positioned(
              bottom: 20,
              left: 15,
              right: 15,
              child: _buildPreviewCard(_selectedProperty!),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Icon(Icons.search, color: primaryRed),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => _buscarYEnfocarLugar(value), // Al pulsar "Buscar" en el teclado
              decoration: const InputDecoration(
                hintText: "Ej: PTS, Plaza de Toros, Centro...",
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 15),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchController.clear();
                  _selectedProperty = null;
                });
              },
              child: const Icon(Icons.clear, color: Colors.grey, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(PropertyModel property) {
    final String thumb = property.imageUrls.isNotEmpty ? property.imageUrls[0] : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailsScreen(property: property),
          ),
        );
      },
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              child: SizedBox(width: 110, height: 110, child: CustomPropertyImage(url: thumb)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(property.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                            const SizedBox(width: 2),
                            Expanded(child: Text("${property.locality}, ${property.city}", maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12))),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${property.price.toInt()}€/mes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryRed)),
                        Row(
                          children: [
                            if (property.services['transporte_bus'] == true)
                              Padding(padding: const EdgeInsets.only(right: 4), child: Icon(Icons.directions_bus_outlined, size: 16, color: Colors.grey[700])),
                            if (property.services['transporte_tren'] == true)
                              Icon(Icons.train_outlined, size: 16, color: Colors.grey[700]),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}