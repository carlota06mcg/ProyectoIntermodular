import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roomiefind/models/property_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/property_service.dart';

class PropertyViewModel extends ChangeNotifier {
  final PropertyService _propertyService = PropertyService();
  final _supabase = Supabase.instance.client;

  // --- ESTADOS ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<PropertyModel> _allProperties = []; 
  List<PropertyModel> get properties => _allProperties;

  List<PropertyModel> _myProperties = []; 
  List<PropertyModel> get myProperties => _myProperties;

  // --- FAVORITOS ---
  List<String> _favoriteIds = [];
  List<String> get favoriteIds => _favoriteIds;

// --- HISTORIAL ---
  List<String> _historyIds = [];
  List<String> get historyIds => _historyIds;

  // --- MÉTODOS DE CARGA ---

  Future<void> fetchProperties() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = _supabase.auth.currentUser;
      final all = await _propertyService.getProperties();

      if (user != null) {
        // Excluir mis propias propiedades para no verlas en el buscador de estudiantes
        _allProperties = all.where((p) => p.ownerId != user.id).toList();
        // Aprovechamos para cargar los favoritos del usuario
        await fetchFavorites();
      } else {
        _allProperties = all;
      }
    } catch (e) {
      _errorMessage = "Error al cargar alojamientos: $e";
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMyProperties(String userId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _myProperties = await _propertyService.getPropertiesByOwner(userId);
    } catch (e) {
      _errorMessage = "Error al obtener tus propiedades: $e";
    } finally {
      _setLoading(false);
    }
  }

  // --- MÉTODOS DE FAVORITOS ---

  Future<void> fetchFavorites() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('favorites')
          .select('property_id')
          .eq('user_id', user.id);

      _favoriteIds = (data as List)
          .map((f) => f['property_id'].toString())
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error cargando favoritos: $e");
    }
  }

Future<void> toggleFavorite(String propertyId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final isAlreadyFav = _favoriteIds.contains(propertyId);

    try {
      if (isAlreadyFav) {
        _favoriteIds.remove(propertyId);
        notifyListeners();

        await _supabase
            .from('favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('property_id', propertyId);
        } else {
        // Usamos insert(0, ...) para que en la lista local 
        // el último ID SIEMPRE esté en la posición 0
        _favoriteIds.insert(0, propertyId); 
        notifyListeners();

        await _supabase.from('favorites').insert({
          'user_id': user.id,
          'property_id': propertyId,
        });
      }
    } catch (e) {
      // Revertir cambio local en caso de error
      if (isAlreadyFav) {
        _favoriteIds.insert(0, propertyId); // También aquí si quieres mantener el orden al revertir
      } else {
        _favoriteIds.remove(propertyId);
      }
      notifyListeners();
      debugPrint("Error al cambiar favorito: $e");
    }
  }

  //MÉTODOS PARA EL HISTORIAL DE VISITAS

// CARGAR HISTORIAL DESDE SUPABASE
  Future<void> loadHistory() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await _supabase
          .from('history')
          .select('property_id')
          .eq('user_id', user.id)
          .order('viewed_at', ascending: false) // El más reciente arriba
          .limit(20); // Limitamos a los últimos 20 vistos

      _historyIds = (data as List)
          .map((item) => item['property_id'].toString())
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint("Error cargando historial desde BD: $e");
    }
  }

  // GUARDAR EN EL HISTORIAL (UPSERT)
  Future<void> addToHistory(String propertyId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // 1. Actualización local inmediata para la UI
    _historyIds.remove(propertyId);
    _historyIds.insert(0, propertyId);
    if (_historyIds.length > 20) _historyIds.removeLast();
    notifyListeners();

    // 2. Guardado en Supabase
    try {
      await _supabase.from('history').upsert({
        'user_id': user.id,
        'property_id': propertyId,
        'viewed_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, property_id'); 
      // El onConflict hace que si ya existe, solo actualice el 'viewed_at'
    } catch (e) {
      debugPrint("Error al guardar historial en BD: $e");
    }
  }


  // --- MÉTODOS DE ACCIÓN (CRUD) ---

  Future<bool> publishProperty(PropertyModel property, List<XFile> xFiles) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      List<File> imageFiles = xFiles.map((x) => File(x.path)).toList();
      await _propertyService.createProperty(property, imageFiles);
      await fetchMyProperties(property.ownerId);
      return true;
    } catch (e) {
      _errorMessage = "Error al publicar: $e";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProperty(PropertyModel property, List<XFile> nuevasFotos) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      List<File> imageFiles = nuevasFotos.map((x) => File(x.path)).toList();
      await _propertyService.updateProperty(property, imageFiles);
      await fetchMyProperties(property.ownerId);
      return true;
    } catch (e) {
      _errorMessage = "Error al actualizar: $e";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteProperty(String propertyId, String userId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _propertyService.deleteProperty(propertyId);
      await fetchMyProperties(userId);
      return true;
    } catch (e) {
      _errorMessage = "Error al eliminar: $e";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteImagesFromStorage(List<String> urls) async {
    try {
      for (String url in urls) {
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;
        final filePath = pathSegments.skip(pathSegments.indexOf('propiedades') + 1).join('/');

        await _supabase.storage
            .from('propiedades') 
            .remove([filePath]);
      }
    } catch (e) {
      debugPrint("Error borrando archivos del Storage: $e");
    }
  }

  // --- AUXILIARES ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}