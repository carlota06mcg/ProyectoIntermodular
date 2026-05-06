import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roomiefind/models/property_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/property_service.dart';

class PropertyViewModel extends ChangeNotifier {
  final PropertyService _propertyService = PropertyService();

  // --- ESTADOS ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<PropertyModel> _allProperties = []; 
  List<PropertyModel> get properties => _allProperties;

  List<PropertyModel> _myProperties = []; 
  List<PropertyModel> get myProperties => _myProperties;

  // --- MÉTODOS DE CARGA ---

  Future<void> fetchProperties() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final all = await _propertyService.getProperties();

      if (user != null) {
        // Excluir mis propias propiedades para no verlas en el buscador de estudiantes
        _allProperties = all.where((p) => p.ownerId != user.id).toList();
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

  // --- MÉTODOS DE ACCIÓN (CRUD) ---

  Future<bool> publishProperty(PropertyModel property, List<XFile> xFiles) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Convertimos XFile a File para el servicio
      List<File> imageFiles = xFiles.map((x) => File(x.path)).toList();
      
      // El servicio ahora recibirá el modelo con los nuevos campos de dirección y servicios
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