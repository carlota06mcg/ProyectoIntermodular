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

  // Listas de datos
  List<PropertyModel> _allProperties = []; // Para estudiantes
  List<PropertyModel> get properties => _allProperties;

  List<PropertyModel> _myProperties = []; // Para el dueño
  List<PropertyModel> get myProperties => _myProperties;

  // --- MÉTODOS DE CARGA ---

  // Obtener todos los alojamientos (Modo Estudiante)
Future<void> fetchProperties() async {
  _setLoading(true);
  _errorMessage = null;

  try {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    final all = await _propertyService.getProperties();

    // 🔥 FILTRO: excluir propiedades del usuario actual
    _allProperties = all.where((p) => p.ownerId != userId).toList();

  } catch (e) {
    _errorMessage = "Error al cargar alojamientos: $e";
  } finally {
    _setLoading(false);
  }
}


  // Obtener mis alojamientos (Modo Propietario)
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

  // 1. PUBLICAR
  Future<bool> publishProperty(PropertyModel property, List<XFile> xFiles) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      List<File> imageFiles = xFiles.map((x) => File(x.path)).toList();
      await _propertyService.createProperty(property, imageFiles);
      
      // Refrescamos la lista local del dueño después de crear
      await fetchMyProperties(property.ownerId);
      
      return true;
    } catch (e) {
      _errorMessage = "Error al publicar: $e";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 2. ACTUALIZAR
  Future<bool> updateProperty(PropertyModel property, List<XFile> nuevasFotos) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      List<File> imageFiles = nuevasFotos.map((x) => File(x.path)).toList();
      await _propertyService.updateProperty(property, imageFiles);
      
      // Refrescamos la lista local para ver los cambios aplicados
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
    
    // Refrescamos la lista local inmediatamente
    await fetchMyProperties(userId);
    
    return true;
  } catch (e) {
    _errorMessage = e.toString();
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