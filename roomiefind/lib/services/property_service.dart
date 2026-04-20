import 'dart:io';
import 'package:roomiefind/models/property_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PropertyService {
  // Definimos la variable como _supabase
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Subir imágenes al Storage y obtener sus URLs
  Future<List<String>> uploadImages(List<File> images, String propertyId) async {
    List<String> urls = [];
    try {
      for (var i = 0; i < images.length; i++) {
        final String path = 'properties/$propertyId/img_$i.jpg';
        
        // Subida del archivo
        await _supabase.storage.from('property_images').upload(
          path, 
          images[i],
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

        // Obtención de la URL pública
        final String url = _supabase.storage.from('property_images').getPublicUrl(path);
        urls.add(url);
      }
    } catch (e) {
      print("Error subiendo imágenes: $e");
    }
    return urls;
  }

  // 2. Guardar la propiedad en la base de datos
  Future<void> createProperty(PropertyModel property, List<File> images) async {
    try {
      // Insertamos la propiedad
      final response = await _supabase.from('properties').insert(property.toJson()).select().single();
      final String propertyId = response['id'].toString();

      // Si hay imágenes, las subimos y actualizamos el registro
      if (images.isNotEmpty) {
        final List<String> urls = await uploadImages(images, propertyId);
        await _supabase.from('properties').update({'images': urls}).eq('id', propertyId);
      }
    } catch (e) {
      print("Error creando propiedad: $e");
      rethrow;
    }
  }

  // 3. Obtener todas las propiedades (Para el Estudiante)
  Future<List<PropertyModel>> getProperties() async {
    try {
      final data = await _supabase.from('properties').select();
      return (data as List).map((json) => PropertyModel.fromJson(json)).toList();
    } catch (e) {
      print("Error obteniendo propiedades: $e");
      return [];
    }
  }

  // 4. Obtener solo mis propiedades (Para el Propietario)
  Future<List<PropertyModel>> getPropertiesByOwner(String userId) async {
    try {
      // CAMBIO: Usamos _supabase en lugar de client
      final response = await _supabase
          .from('properties')
          .select()
          .eq('owner_id', userId);

      return (response as List).map((json) => PropertyModel.fromJson(json)).toList();
    } catch (e) {
      print("Error obteniendo mis propiedades: $e");
      return [];
    }
  }

  // 5. Actualizar propiedad existente (Para el Propietario)
  Future<void> updateProperty(PropertyModel property, List<File> newImages) async {
    try {
      if (property.id == null) {
        throw Exception("El ID de la propiedad no puede ser nulo para actualizar");
      }

      // 1. Actualizamos los datos de texto, números y booleanos (el toJson se encarga del formato)
      await _supabase
          .from('properties')
          .update(property.toJson())
          .eq('id', property.id!);

      // 2. Si el usuario seleccionó NUEVAS imágenes en la edición, las subimos
      if (newImages.isNotEmpty) {
        // Aprovechamos el método que ya tienes para subir y obtener URLs
        final List<String> newUrls = await uploadImages(newImages, property.id!);
        
        // Juntamos las imágenes que ya tenía en Supabase con las nuevas
        final List<String> allUrls = [...property.imageUrls, ...newUrls];

        // Hacemos un segundo update solo para guardar la lista de imágenes completa
        await _supabase
            .from('properties')
            .update({'images': allUrls})
            .eq('id', property.id!);
      }
    } catch (e) {
      print("Error actualizando propiedad: $e");
      rethrow;
    }
  }
  // 6. Eliminar propiedad (Para el Propietario)
  Future<void> deleteProperty(String propertyId) async {
  try {
    await _supabase.from('properties').delete().eq('id', propertyId);
  } catch (e) {
    throw Exception("Error al eliminar la propiedad: $e");
  }
}
}