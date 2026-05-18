import 'dart:io';
import 'package:roomiefind/models/property_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PropertyService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================
  // 1. SUBIR IMÁGENES
  // ============================
  Future<List<String>> uploadImages(List<File> images, String propertyId) async {
    List<String> urls = [];

    for (var i = 0; i < images.length; i++) {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final String path = 'properties/$propertyId/$fileName';

      await _supabase.storage.from('property_images').upload(
            path,
            images[i],
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final String url = _supabase.storage.from('property_images').getPublicUrl(path);
      urls.add(url);
    }

    return urls;
  }

  // ============================
  // 2. CREAR PROPIEDAD
  // ============================
  Future<PropertyModel> createProperty(PropertyModel property, List<File> images) async {
    try {
      final response = await _supabase
          .from('properties')
          .insert(property.toJson())
          .select()
          .single();

      final String propertyId = response['id'].toString();

      List<String> urls = [];
      if (images.isNotEmpty) {
        urls = await uploadImages(images, propertyId);

        await _supabase
            .from('properties')
            .update({'imageUrls': urls})
            .eq('id', propertyId);
      }

      return PropertyModel.fromJson({
        ...response,
        'imageUrls': urls,
      });
    } catch (e) {
      print("Error creando propiedad: $e");
      rethrow;
    }
  }

  // ============================
  // 3. OBTENER PROPIEDADES
  // ============================
  Future<List<PropertyModel>> getProperties() async {
    try {
      final data = await _supabase.from('properties').select('*').order('created_at');
      return (data as List).map((json) => PropertyModel.fromJson(_normalizeJson(json))).toList();
    } catch (e) {
      print("Error obteniendo propiedades: $e");
      return [];
    }
  }

  Future<List<PropertyModel>> getPropertiesByOwner(String userId) async {
    try {
      final response = await _supabase
          .from('properties')
          .select('*')
          .eq('owner_id', userId)
          .order('created_at');

      return (response as List).map((json) => PropertyModel.fromJson(_normalizeJson(json))).toList();
    } catch (e) {
      print("Error obteniendo mis propiedades: $e");
      return [];
    }
  }

  // ============================
  // 4. ACTUALIZAR PROPIEDAD
  // ============================
Future<void> updateProperty(PropertyModel property, List<File> newImages) async {
  try {
    // Usamos ! porque estamos seguros de que existe un ID para actualizar
    await _supabase
        .from('properties')
        .update(property.toJson())
        .eq('id', property.id!); // <--- Cambio aquí

    if (newImages.isNotEmpty) {
      // Usamos ! también aquí
      final List<String> newUrls = await uploadImages(newImages, property.id!); // <--- Cambio aquí
      final List<String> allUrls = [...property.imageUrls, ...newUrls];

      await _supabase
          .from('properties')
          .update({'imageUrls': allUrls})
          .eq('id', property.id!); // <--- Cambio aquí
    }
  } catch (e) {
    print("Error actualizando propiedad: $e");
    rethrow;
  }
}

  // ============================
  // 5. ELIMINAR PROPIEDAD
  // ============================
Future<void> deleteProperty(String propertyId) async {
  try {
    // Añadimos .select() para confirmar que el RLS permitió el borrado
    final data = await _supabase
        .from('properties')
        .delete()
        .eq('id', propertyId)
        .select();

    // Si data está vacío, es que el RLS bloqueó el borrado (no eras el dueño)
    // o la propiedad ya no existía.
    if (data.isEmpty) {
      throw Exception("No se pudo eliminar: No tienes permisos o el alojamiento no existe.");
    }
  } on PostgrestException catch (e) {
    // Capturamos errores específicos de la base de datos (como el de las FK que vimos)
    throw Exception("Error de base de datos: ${e.message}");
  } catch (e) {
    throw Exception("Error inesperado al eliminar: $e");
  }
}

  // ============================
  // NORMALIZAR JSON
  // ============================
  Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    return {
      ...json,
      'imageUrls': json['imageUrls'] ?? [],
      'services': json['services'] ?? {},
      'additional_info': json['additional_info'] ?? {},
      'transport': json['transport']?.toString() ?? '', 
      'latitude': json['latitude'],
    'longitude': json['longitude']
    };
  }
}