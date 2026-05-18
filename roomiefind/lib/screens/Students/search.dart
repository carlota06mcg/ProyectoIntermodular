import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  PropertyModel? _selectedProperty; 
  
  final Color primaryRed = const Color(0xFFB02A37);
  final LatLng _defaultCenter = const LatLng(37.177336, -3.598557); 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PropertyViewModel>(context, listen: false).fetchProperties().then((_) {
        _centrarMapaEnPropiedades();
      });
    });
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
      final double avgLat = totalLat / validProperties.length;
      final double avgLng = totalLng / validProperties.length;
      
      _mapController.move(LatLng(avgLat, avgLng), 14.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyVM = context.watch<PropertyViewModel>();
    final properties = propertyVM.properties;
    final propertiesWithCoords = properties.where((p) => p.latitude != null && p.longitude != null).toList();

    return Scaffold(
      body: Stack(
        children: [
          // 1. EL MAPA BASE
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 14.0,
              onTap: (_, __) {
                setState(() => _selectedProperty = null);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.roomiefind.app',
              ),
              
              // 2. CAPA DE MARCADORES PERSONALIZADOS (ESTILO AIRBNB)
              MarkerLayer(
                markers: propertiesWithCoords.map((property) {
                  final bool isSelected = _selectedProperty?.id == property.id;
                  
                  return Marker(
                    point: LatLng(property.latitude!, property.longitude!),
                    width: 75,
                    height: 35,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedProperty = property);
                        _mapController.move(LatLng(property.latitude!, property.longitude!), 15.0);
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

          // 3. INDICADOR DE CARGA
          if (propertyVM.isLoading)
            Positioned(
              top: 50,
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

  Widget _buildPreviewCard(PropertyModel property) {
    final String thumb = property.imageUrls.isNotEmpty ? property.imageUrls[0] : '';

    return GestureDetector(
      onTap: () {
        // Redirección directa utilizando la clase de tu archivo de Shared
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
              child: SizedBox(
                width: 110,
                height: 110,
                child: CustomPropertyImage(url: thumb),
              ),
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
                        Text(
                          property.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                "${property.locality}, ${property.city}",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${property.price.toInt()}€/mes",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryRed),
                        ),
                        Row(
                          children: [
                            if (property.services['transporte_bus'] == true)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(Icons.directions_bus_outlined, size: 16, color: Colors.grey[700]),
                              ),
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