import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class LocationService {
  // User-Agent requerido por las políticas de Nominatim
  final String _userAgent = 'com.example.roomiefind'; 

  /// 1. Obtener coordenadas a partir de una dirección (Texto -> Coordenadas)
  Future<Map<String, dynamic>?> getCoordsFromAddress(String query) async {
    if (query.trim().isEmpty) return null;

    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1&addressdetails=1');
      
      final response = await http.get(url, headers: {'User-Agent': _userAgent});

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          return {
            'lat': double.parse(data[0]['lat']),
            'lon': double.parse(data[0]['lon']),
            'display_name': data[0]['display_name'],
            'address': data[0]['address'], // Contiene ciudad, calle, CP desglosado
          };
        }
      }
      return null;
    } catch (e) {
      print("Error en geocoding: $e");
      return null;
    }
  }

  /// 2. Obtener dirección a partir de coordenadas (Coordenadas -> Texto)
  /// Útil cuando el usuario mueve el marcador manualmente
  Future<Map<String, dynamic>?> getAddressFromCoords(LatLng position) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=${position.latitude}&lon=${position.longitude}&format=json&addressdetails=1');

      final response = await http.get(url, headers: {'User-Agent': _userAgent});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'display_name': data['display_name'],
          'address': data['address'], // Aquí viene street, city, postcode, etc.
        };
      }
      return null;
    } catch (e) {
      print("Error en reverse geocoding: $e");
      return null;
    }
  }
}