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
      final String path = 'properties/$propertyId/img_$i.jpg';

      await _supabase.storage.from('property_images').upload(
        path,
        images[i],
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final String url =
          _supabase.storage.from('property_images').getPublicUrl(path);

      urls.add(url);
    }

    return urls;
  }

  // ============================
  // 2. CREAR PROPIEDAD
  // ============================
  Future<PropertyModel> createProperty(
      PropertyModel property, List<File> images) async {
    try {
      // Insertamos y obtenemos el registro completo
      final response = await _supabase
          .from('properties')
          .insert(property.toJson())
          .select()
          .single();

      final String propertyId = response['id'];

      // Subimos imágenes si existen
      List<String> urls = [];
      if (images.isNotEmpty) {
        urls = await uploadImages(images, propertyId);

        await _supabase
            .from('properties')
            .update({'imageUrls': urls})
            .eq('id', propertyId);
      }

      // Devolvemos el modelo completo
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
  // 3. OBTENER TODAS LAS PROPIEDADES
  // ============================
  Future<List<PropertyModel>> getProperties() async {
    try {
      final data = await _supabase.from('properties').select('*');

      return (data as List).map((json) {
        return PropertyModel.fromJson(_normalizeJson(json));
      }).toList();
    } catch (e) {
      print("Error obteniendo propiedades: $e");
      return [];
    }
  }

  // ============================
  // 4. OBTENER PROPIEDADES DEL DUEÑO
  // ============================
  Future<List<PropertyModel>> getPropertiesByOwner(String userId) async {
    try {
      final response = await _supabase
          .from('properties')
          .select('*')
          .eq('owner_id', userId);

      return (response as List).map((json) {
        return PropertyModel.fromJson(_normalizeJson(json));
      }).toList();
    } catch (e) {
      print("Error obteniendo mis propiedades: $e");
      return [];
    }
  }

  // ============================
  // 5. ACTUALIZAR PROPIEDAD
  // ============================
  Future<void> updateProperty(
      PropertyModel property, List<File> newImages) async {
    try {
      // 1. Actualizamos datos base
      await _supabase
          .from('properties')
          .update(property.toJson())
          .eq('id', property.id);

      // 2. Subimos nuevas imágenes
      if (newImages.isNotEmpty) {
        final List<String> newUrls =
            await uploadImages(newImages, property.id);

        final List<String> allUrls = [...property.imageUrls, ...newUrls];

        await _supabase
            .from('properties')
            .update({'imageUrls': allUrls})
            .eq('id', property.id);
      }
    } catch (e) {
      print("Error actualizando propiedad: $e");
      rethrow;
    }
  }

  // ============================
  // 6. ELIMINAR PROPIEDAD
  // ============================
  Future<void> deleteProperty(String propertyId) async {
    try {
      await _supabase.from('properties').delete().eq('id', propertyId);
    } catch (e) {
      throw Exception("Error al eliminar la propiedad: $e");
    }
  }

  // ============================
  // NORMALIZAR JSONB
  // ============================
  Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    return {
      ...json,
      'imageUrls': json['imageUrls'] ?? [],
      'transport': json['transport'] is List ? {} : json['transport'],
      'services': json['services'] is List ? {} : json['services'],
      'additional_info':
          json['additional_info'] is List ? {} : json['additional_info'],

    };
  }
}
