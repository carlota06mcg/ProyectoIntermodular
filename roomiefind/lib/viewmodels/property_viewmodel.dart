import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roomiefind/models/property_models.dart';
import '../services/property_service.dart';

class PropertyViewModel extends ChangeNotifier {
  final PropertyService _propertyService = PropertyService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Función para publicar la propiedad
  Future<bool> publishProperty(PropertyModel property, List<XFile> xFiles) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Convertimos XFile a File para el servicio
      List<File> imageFiles = xFiles.map((x) => File(x.path)).toList();

      await _propertyService.createProperty(property, imageFiles);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Error al publicar: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Dentro de PropertyViewModel
List<PropertyModel> _myProperties = [];
List<PropertyModel> get myProperties => _myProperties;

Future<void> fetchMyProperties(String userId) async {
  _isLoading = true;
  notifyListeners();

  try {
    // Usamos el servicio para traer solo las mías
    _myProperties = await _propertyService.getPropertiesByOwner(userId);
  } catch (e) {
    _errorMessage = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

// --- NUEVA SECCIÓN PARA EL ESTUDIANTE ---
  List<PropertyModel> _allProperties = [];
  List<PropertyModel> get properties => _allProperties; // El MainMenu busca este nombre

  Future<void> fetchProperties() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Llamamos al servicio para traer TODO lo disponible
      _allProperties = await _propertyService.getProperties();
    } catch (e) {
      _errorMessage = "Error al cargar alojamientos: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}