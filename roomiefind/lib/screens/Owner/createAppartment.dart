import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/models/property_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../viewmodels/property_viewmodel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/location_service.dart';
import 'dart:async';

class FormularioAlojamientoScreen extends StatefulWidget {
  final PropertyModel? propertyAEditar;
  const FormularioAlojamientoScreen({Key? key, this.propertyAEditar}) : super(key: key);

  @override
  _FormularioAlojamientoScreenState createState() => _FormularioAlojamientoScreenState();
}

class _FormularioAlojamientoScreenState extends State<FormularioAlojamientoScreen> {
  final Color primaryRed = const Color(0xFFB02A37);
  final Color inputFillColor = const Color(0xFFF5F5F5);

  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  
  double? _lat;
  double? _lon;
  bool _isLocating = false;
  Timer? _debounce;


  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _descripcionController;
  late TextEditingController _calleController;
  late TextEditingController _ciudadController;
  late TextEditingController _localidadController;
  late TextEditingController _cpController;
  
  bool _tieneBus = false;
  bool _tieneTren = false;
  String _tipoSeleccionado = 'Piso Compartido';
  final List<String> _tiposAlojamiento = ['Estudio', 'Piso Compartido', 'Residencia'];

  final ImagePicker _picker = ImagePicker();
  List<XFile> _imagenesSeleccionadas = []; 
  List<String> _urlsABorrar = []; 

  bool get esEdicion => widget.propertyAEditar != null;

  // Estados de servicios
  bool servAgua = false, servLuz = false, servWifi = false, servCocina = false, servLavadora = false;
  bool resHabIndiv = false, resHabComp = false, resDesayuno = false, resAlmuerzo = false, resCena = false, resGym = false, resSalas = false;
  bool infoMascotas = false, infoFumadores = false, infoMixto = false, infoSoloHombres = false, infoSoloMujeres = false;

  @override
  void initState() {
    super.initState();
    final p = widget.propertyAEditar;

    _nombreController = TextEditingController(text: esEdicion ? p!.title : '');
    _precioController = TextEditingController(text: esEdicion ? p!.price.toString() : '');
    _descripcionController = TextEditingController(text: esEdicion ? p!.description : '');
    _calleController = TextEditingController(text: esEdicion ? p!.streetNameNumber : '');
    _ciudadController = TextEditingController(text: esEdicion ? p!.city : '');
    _localidadController = TextEditingController(text: esEdicion ? p!.locality : '');
    _cpController = TextEditingController(text: esEdicion ? p!.zipCode : '');
    
    if (esEdicion) {
      _lat = p!.latitude;
      _lon = p!.longitude;
    }

    if (esEdicion && p?.services != null) {
      _tieneBus = p!.services['transporte_bus'] ?? false;
      _tieneTren = p!.services['transporte_tren'] ?? false;
      _tipoSeleccionado = p.type;
      servWifi = p.services['wifi'] ?? false;
      servCocina = p.services['cocina'] ?? false;
      resHabIndiv = p.services['hab_individual'] ?? false;
      resHabComp = p.services['hab_compartida'] ?? false;
      servAgua = p.services['agua'] ?? false;
      servLuz = p.services['luz'] ?? false;
      servLavadora = p.services['lavadora'] ?? false;
      resDesayuno = p.services['desayuno'] ?? false;
      resAlmuerzo = p.services['almuerzo'] ?? false;
      resCena = p.services['cena'] ?? false;
      resGym = p.services['gym'] ?? false;
      resSalas = p.services['salas_estudio'] ?? false;
      infoMascotas = p.additionalInfo['mascotas'] ?? false;
      infoFumadores = p.additionalInfo['fumadores'] ?? false;
      infoMixto = p.additionalInfo['mixto'] ?? false;
      infoSoloHombres = p.additionalInfo['solo_hombres'] ?? false;
      infoSoloMujeres = p.additionalInfo['solo_mujeres'] ?? false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nombreController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    _calleController.dispose();
    _ciudadController.dispose();
    _localidadController.dispose();
    _cpController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE GEOLOCALIZACIÓN IMPLEMENTADA ---

  Future<void> _verificarUbicacion() async {
    if (_calleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Escribe al menos la calle y el número")),
      );
      return;
    }

    setState(() => _isLocating = true);
    
    // Buscamos con la mayor info posible para precisión
    final direccion = "${_calleController.text}, ${_ciudadController.text}, ${_cpController.text}, España";
    final result = await _locationService.getCoordsFromAddress(direccion);

    if (result != null) {
      setState(() {
        _lat = result['lat'];
        _lon = result['lon'];
        _isLocating = false;
      });
      _mapController.move(LatLng(_lat!, _lon!), 17.0);
    } else {
      setState(() => _isLocating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo encontrar la ubicación exacta")),
      );
    }
  }

Future<void> _actualizarDireccionDesdeMapa(LatLng position) async {
  // Validación crítica para evitar la excepción
  if (!position.latitude.isFinite || !position.longitude.isFinite) return;

  if (_debounce?.isActive ?? false) _debounce!.cancel();

  _debounce = Timer(const Duration(milliseconds: 600), () async {
    // Actualizamos las coordenadas internas para el marcador
    setState(() {
      _lat = position.latitude;
      _lon = position.longitude;
    });

    try {
      final result = await _locationService.getAddressFromCoords(position);
      if (result != null && result['address'] != null && mounted) {
        final addr = result['address'];
        setState(() {
          _calleController.text = "${addr['road'] ?? ''} ${addr['house_number'] ?? ''}".trim();
          _ciudadController.text = addr['city'] ?? addr['town'] ?? addr['village'] ?? '';
          _cpController.text = addr['postcode'] ?? '';
          _localidadController.text = addr['suburb'] ?? addr['neighbourhood'] ?? '';
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  });
}
  // --- WIDGET DEL MAPA INTERACTIVO ---

  Widget _buildInteractiveMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[200], border: Border.all(color: Colors.grey.shade300)),
            child: _lat == null 
              ? const Center(child: Text("Busca una dirección para activar el mapa", style: TextStyle(color: Colors.grey)))
:FlutterMap(
  mapController: _mapController,
  options: MapOptions(
    initialCenter: LatLng(_lat!, _lon!),
    initialZoom: 17.0,
    // CAMBIO AQUÍ: Usamos MapCamera en lugar de MapPosition
    onPositionChanged: (MapCamera camera, bool hasGesture) {
      if (hasGesture) {
        // La cámara siempre tiene un centro válido (center)
        _actualizarDireccionDesdeMapa(camera.center);
      }
    },
  ),
  children: [
    TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.roomiefind.app',
      tileDisplay: const TileDisplay.fadeIn(duration: Duration(milliseconds: 300)),
    ),
    MarkerLayer(
      markers: [
        Marker(
          point: LatLng(_lat!, _lon!),
          width: 45,
          height: 45,
          child: Icon(Icons.location_pin, color: primaryRed, size: 45),
        ),
      ],
    ),
  ],
)
          ),
        ),
        if (_lat != null)
          const Padding(
            padding: EdgeInsets.only(top: 6, left: 4),
            child: Text("📍 Arrastra el mapa para ajustar el pin sobre el portal.", 
              style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }

  // ---------------------------------

  Future<void> _procesarFormulario() async {
    final propVM = Provider.of<PropertyViewModel>(context, listen: false);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    if (_urlsABorrar.isNotEmpty) await propVM.deleteImagesFromStorage(_urlsABorrar);

    final List<String> urlsFinales = esEdicion 
        ? widget.propertyAEditar!.imageUrls.where((url) => !_urlsABorrar.contains(url)).toList()
        : [];

    Map<String, bool> servicesMap = {
      "wifi": servWifi, "cocina": servCocina, "hab_individual": resHabIndiv,
      "hab_compartida": resHabComp, "transporte_bus": _tieneBus, "transporte_tren": _tieneTren,
    };

    if (_tipoSeleccionado == 'Residencia') {
      servicesMap.addAll({"desayuno": resDesayuno, "almuerzo": resAlmuerzo, "cena": resCena, "gym": resGym, "salas_estudio": resSalas});
    } else {
      servicesMap.addAll({"agua": servAgua, "luz": servLuz, "lavadora": servLavadora});
    }

    final propiedadData = PropertyModel(
      id: esEdicion ? widget.propertyAEditar!.id : null,
      ownerId: user.id,
      title: _nombreController.text,
      type: _tipoSeleccionado,
      streetNameNumber: _calleController.text,
      city: _ciudadController.text,
      locality: _localidadController.text,
      zipCode: _cpController.text,
      latitude: _lat,
      longitude: _lon,
      price: double.tryParse(_precioController.text) ?? 0.0,
      description: _descripcionController.text,
      imageUrls: urlsFinales,
      transport: "${_tieneBus ? 'Bus ' : ''}${_tieneTren ? 'Tren' : ''}".trim(), 
      services: servicesMap,
      additionalInfo: {
        "mascotas": infoMascotas, "fumadores": infoFumadores, "mixto": infoMixto, 
        "solo_hombres": infoSoloHombres, "solo_mujeres": infoSoloMujeres
      },
    );

    bool exito = esEdicion 
        ? await propVM.updateProperty(propiedadData, _imagenesSeleccionadas)
        : await propVM.publishProperty(propiedadData, _imagenesSeleccionadas);

    if (exito && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PropertyViewModel>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryRed),
        title: Text(esEdicion ? "Editar" : "Nuevo Alojamiento", 
          style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryRed))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Nombre del alojamiento"),
                  _buildTextField(_nombreController, "Ej: Estudio centro individual"),
                  
                  _buildLabel("Tipo de Alojamiento"),
                  DropdownButtonFormField<String>(
                    value: _tipoSeleccionado,
                    decoration: InputDecoration(filled: true, fillColor: inputFillColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    items: _tiposAlojamiento.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _tipoSeleccionado = val!),
                  ),

                  _buildLabel("Ubicación"),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_calleController, "Calle y número")),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _isLocating ? null : _verificarUbicacion,
                        style: IconButton.styleFrom(backgroundColor: primaryRed),
                        icon: _isLocating 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.location_searching),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 15),
                  _buildInteractiveMap(), // EL MAPA INTERACTIVO AQUÍ
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(child: _buildTextField(_ciudadController, "Ciudad")),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField(_localidadController, "Localidad/Barrio")),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(_cpController, "Código Postal", isNumber: true),

                  _buildLabel("Precio mensual"),
                  _buildTextField(_precioController, "€", isNumber: true),

                  _buildLabel("Descripción"),
                  _buildTextField(_descripcionController, "Cuéntanos más...", maxLines: 5),

                  _buildLabel("Transporte cercano"),
                  _buildSwitch(Icons.directions_bus, "Autobús", _tieneBus, (v) => setState(() => _tieneBus = v)),
                  _buildSwitch(Icons.train, "Tren / Metro", _tieneTren, (v) => setState(() => _tieneTren = v)),

                  _buildLabel("Fotos"),
                  _buildPhotoGrid(),

                  _buildLabel("Servicios Incluidos"),
                  _buildDynamicServices(),

                  _buildLabel("Información Adicional"),
                  _buildInfoChecks(),

                  const SizedBox(height: 40),
                  _buildActionButton(esEdicion ? "Guardar Cambios" : "Publicar", primaryRed, Colors.white, _procesarFormulario),
                ],
              ),
            ),
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(top: 20, bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) => TextField(
    controller: controller, 
    keyboardType: isNumber ? TextInputType.number : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
    maxLines: maxLines,
    decoration: InputDecoration(hintText: hint, filled: true, fillColor: inputFillColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
  );

  Widget _buildSwitch(IconData icon, String label, bool value, Function(bool) onChanged) => SwitchListTile(
    title: Text(label), secondary: Icon(icon, color: value ? primaryRed : Colors.grey),
    value: value, activeColor: primaryRed, contentPadding: EdgeInsets.zero, onChanged: onChanged,
  );

  Widget _buildDynamicServices() {
    bool isRes = _tipoSeleccionado == 'Residencia';
    return Wrap(
      spacing: 8, runSpacing: 4,
      children: [
        FilterChip(label: const Text("WiFi"), selected: servWifi, onSelected: (v) => setState(() => servWifi = v), selectedColor: primaryRed.withOpacity(0.2)),
        FilterChip(label: const Text("Cocina"), selected: servCocina, onSelected: (v) => setState(() => servCocina = v), selectedColor: primaryRed.withOpacity(0.2)),
        FilterChip(label: const Text("Hab. Individual"), selected: resHabIndiv, onSelected: (v) => setState(() { resHabIndiv = v; if(v) resHabComp = false; }), selectedColor: primaryRed.withOpacity(0.2)),
        FilterChip(label: const Text("Hab. Compartida"), selected: resHabComp, onSelected: (v) => setState(() { resHabComp = v; if(v) resHabIndiv = false; }), selectedColor: primaryRed.withOpacity(0.2)),
        if (isRes) ...[
          FilterChip(label: const Text("Desayuno"), selected: resDesayuno, onSelected: (v) => setState(() => resDesayuno = v), selectedColor: primaryRed.withOpacity(0.2)),
          FilterChip(label: const Text("Almuerzo"), selected: resAlmuerzo, onSelected: (v) => setState(() => resAlmuerzo = v), selectedColor: primaryRed.withOpacity(0.2)),
          FilterChip(label: const Text("Cena"), selected: resCena, onSelected: (v) => setState(() => resCena = v), selectedColor: primaryRed.withOpacity(0.2)),
          FilterChip(label: const Text("Gym"), selected: resGym, onSelected: (v) => setState(() => resGym = v), selectedColor: primaryRed.withOpacity(0.2)),
          FilterChip(label: const Text("Salas Estudio"), selected: resSalas, onSelected: (v) => setState(() => resSalas = v), selectedColor: primaryRed.withOpacity(0.2)),
        ] else ...[
          FilterChip(label: const Text("Agua"), selected: servAgua, onSelected: (v) => setState(() => servAgua = v), selectedColor: primaryRed.withOpacity(0.2)),
          FilterChip(label: const Text("Luz"), selected: servLuz, onSelected: (v) => setState(() => servLuz = v), selectedColor: primaryRed.withOpacity(0.2)),
          FilterChip(label: const Text("Lavadora"), selected: servLavadora, onSelected: (v) => setState(() => servLavadora = v), selectedColor: primaryRed.withOpacity(0.2)),
        ],
      ],
    );
  }

  Widget _buildInfoChecks() {
    return Column(
      children: [
        CheckboxListTile(title: const Text("Acepta Mascotas"), value: infoMascotas, onChanged: (v) => setState(() => infoMascotas = v!), activeColor: primaryRed),
        CheckboxListTile(title: const Text("Apto Fumadores"), value: infoFumadores, onChanged: (v) => setState(() => infoFumadores = v!), activeColor: primaryRed),
        CheckboxListTile(title: const Text("Mixto"), value: infoMixto, onChanged: (v) => setState(() { infoMixto = v!; if(v) { infoSoloHombres = false; infoSoloMujeres = false; } }), activeColor: primaryRed),
        CheckboxListTile(title: const Text("Solo Hombres"), value: infoSoloHombres, onChanged: (v) => setState(() { infoSoloHombres = v!; if(v) { infoSoloMujeres = false; infoMixto = false; } }), activeColor: primaryRed),
        CheckboxListTile(title: const Text("Solo Mujeres"), value: infoSoloMujeres, onChanged: (v) => setState(() { infoSoloMujeres = v!; if(v) { infoSoloHombres = false; infoMixto = false; } }), activeColor: primaryRed),
      ],
    );
  }

  Widget _buildPhotoGrid() {
    final List<String> fotosExistentes = (widget.propertyAEditar?.imageUrls ?? []).where((url) => !_urlsABorrar.contains(url)).toList();
    return Column(
      children: [
        ElevatedButton.icon(onPressed: () async {
          final List<XFile> imagenes = await _picker.pickMultiImage();
          if (imagenes.isNotEmpty) setState(() => _imagenesSeleccionadas.addAll(imagenes));
        }, icon: const Icon(Icons.add_a_photo), label: const Text("Añadir Fotos")),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemCount: fotosExistentes.length + _imagenesSeleccionadas.length,
          itemBuilder: (ctx, i) {
            if (i < fotosExistentes.length) {
              final url = fotosExistentes[i];
              return Stack(fit: StackFit.expand, children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(url, fit: BoxFit.cover)),
                Positioned(right: 0, top: 0, child: IconButton(icon: const CircleAvatar(backgroundColor: Colors.red, radius: 10, child: Icon(Icons.close, size: 12, color: Colors.white)), onPressed: () => setState(() => _urlsABorrar.add(url))))
              ]);
            } else {
              final localIndex = i - fotosExistentes.length;
              return Stack(fit: StackFit.expand, children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_imagenesSeleccionadas[localIndex].path), fit: BoxFit.cover)),
                Positioned(right: 0, top: 0, child: IconButton(icon: const CircleAvatar(backgroundColor: Colors.black, radius: 10, child: Icon(Icons.close, size: 12, color: Colors.white)), onPressed: () => setState(() => _imagenesSeleccionadas.removeAt(localIndex))))
              ]);
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, Color bg, Color txt, VoidCallback onPres) => SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: bg, foregroundColor: txt, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 15)), onPressed: onPres, child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold))));
}