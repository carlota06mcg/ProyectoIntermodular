import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/models/property_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../viewmodels/property_viewmodel.dart';

class FormularioAlojamientoScreen extends StatefulWidget {
  final PropertyModel? propertyAEditar;
  const FormularioAlojamientoScreen({Key? key, this.propertyAEditar}) : super(key: key);

  @override
  _FormularioAlojamientoScreenState createState() => _FormularioAlojamientoScreenState();
}

class _FormularioAlojamientoScreenState extends State<FormularioAlojamientoScreen> {
  final Color primaryRed = const Color(0xFFB02A37);
  final Color inputFillColor = const Color(0xFFF5F5F5);

  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _descripcionController;
  late TextEditingController _calleController;
  late TextEditingController _ciudadController;
  late TextEditingController _localidadController;
  late TextEditingController _cpController;
  
  bool _tieneBus = false;
  bool _tieneTren = false;

  final ImagePicker _picker = ImagePicker();
  List<XFile> _imagenesSeleccionadas = []; // Fotos nuevas locales
  List<String> _urlsABorrar = [];         // URLs de Supabase marcadas para eliminar
  
  String _tipoSeleccionado = 'Piso Compartido';
  final List<String> _tiposAlojamiento = ['Estudio', 'Piso Compartido', 'Residencia'];

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
    
    if (esEdicion && p?.services != null) {
      _tieneBus = p!.services['transporte_bus'] ?? false;
      _tieneTren = p!.services['transporte_tren'] ?? false;
    }

    if (esEdicion && p != null) {
      _tipoSeleccionado = p.type;
      servAgua = p.services['agua'] ?? false;
      servLuz = p.services['luz'] ?? false;
      servWifi = p.services['wifi'] ?? false;
      servCocina = p.services['cocina'] ?? false;
      servLavadora = p.services['lavadora'] ?? false;
      resHabIndiv = p.services['hab_individual'] ?? false;
      resHabComp = p.services['hab_compartida'] ?? false;
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
    _nombreController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    _calleController.dispose();
    _ciudadController.dispose();
    _localidadController.dispose();
    _cpController.dispose();
    super.dispose();
  }

  Future<void> _procesarFormulario() async {
    final propVM = Provider.of<PropertyViewModel>(context, listen: false);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // 1. ELIMINACIÓN FÍSICA DEL STORAGE (Si hay fotos para borrar)
    if (_urlsABorrar.isNotEmpty) {
      await propVM.deleteImagesFromStorage(_urlsABorrar);
    }

    // 2. Filtrar URLs que se mantienen en la base de datos
    final List<String> urlsFinales = esEdicion 
        ? widget.propertyAEditar!.imageUrls.where((url) => !_urlsABorrar.contains(url)).toList()
        : [];

    List<String> transporteSeleccionado = [];
    if (_tieneBus) transporteSeleccionado.add("Bus");
    if (_tieneTren) transporteSeleccionado.add("Tren/Metro");
    String transportString = transporteSeleccionado.isEmpty ? "Ninguno" : transporteSeleccionado.join(", ");

    final propiedadData = PropertyModel(
      id: esEdicion ? widget.propertyAEditar!.id : null,
      ownerId: user.id,
      title: _nombreController.text,
      type: _tipoSeleccionado,
      streetNameNumber: _calleController.text,
      city: _ciudadController.text,
      locality: _localidadController.text,
      zipCode: _cpController.text,
      price: double.tryParse(_precioController.text) ?? 0.0,
      description: _descripcionController.text,
      imageUrls: urlsFinales, // Enviamos la lista limpia
      transport: transportString, 
      services: _tipoSeleccionado == 'Residencia' 
        ? {
            "cocina": servCocina,
            "transporte_bus": _tieneBus,
            "transporte_tren": _tieneTren,
            "hab_individual": resHabIndiv, "hab_compartida": resHabComp, 
            "desayuno": resDesayuno, "almuerzo": resAlmuerzo, 
            "cena": resCena, "gym": resGym, "salas_estudio": resSalas
          }
        : {
            "agua": servAgua, "luz": servLuz, "wifi": servWifi, 
            "cocina": servCocina, "lavadora": servLavadora,
            "transporte_bus": _tieneBus,
            "transporte_tren": _tieneTren,
          },
      additionalInfo: {"mascotas": infoMascotas, "fumadores": infoFumadores, "mixto": infoMixto, "solo_hombres": infoSoloHombres, "solo_mujeres": infoSoloMujeres},
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
                  _buildTextField(_nombreController, "Ej: Mi estudio centro"),
                  
                  _buildLabel("Tipo de Alojamiento"),
                  DropdownButtonFormField<String>(
                    value: _tipoSeleccionado,
                    decoration: InputDecoration(filled: true, fillColor: inputFillColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    items: _tiposAlojamiento.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) => setState(() => _tipoSeleccionado = val!),
                  ),

                  _buildLabel("Ubicación"),
                  _buildTextField(_calleController, "Calle y número"),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_ciudadController, "Ciudad")),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField(_localidadController, "Localidad")),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(_cpController, "Código Postal", isNumber: true),

                  _buildLabel("Precio mensual"),
                  _buildTextField(_precioController, "€", isNumber: true),

                  _buildLabel("Descripción del alojamiento"),
                  _buildTextField(_descripcionController, "Cuéntanos más...", maxLines: 5),

                  _buildLabel("Transporte cercano"),
                  SwitchListTile(
                    title: const Text("Autobús"),
                    secondary: Icon(Icons.directions_bus, color: _tieneBus ? primaryRed : Colors.grey),
                    value: _tieneBus,
                    activeColor: primaryRed,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (bool value) => setState(() => _tieneBus = value),
                  ),
                  SwitchListTile(
                    title: const Text("Tren / Metro"),
                    secondary: Icon(Icons.train, color: _tieneTren ? primaryRed : Colors.grey),
                    value: _tieneTren,
                    activeColor: primaryRed,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (bool value) => setState(() => _tieneTren = value),
                  ),

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

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(top: 20, bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, int maxLines = 1}) => TextField(
    controller: controller, 
    keyboardType: isNumber ? TextInputType.number : (maxLines > 1 ? TextInputType.multiline : TextInputType.text),
    maxLines: maxLines,
    decoration: InputDecoration(hintText: hint, filled: true, fillColor: inputFillColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
  );

  Widget _buildDynamicServices() {
    bool isRes = _tipoSeleccionado == 'Residencia';
    return Wrap(
      spacing: 8,
      children: [
        FilterChip(
          label: const Text("Cocina"), 
          selected: servCocina, 
          onSelected: (v) => setState(() => servCocina = v),
          selectedColor: primaryRed.withOpacity(0.2),
        ),
        if (isRes) ...[
          FilterChip(label: const Text("Hab. Individual"), selected: resHabIndiv, onSelected: (v) => setState(() { resHabIndiv = v; if(v) resHabComp = false; })),
          FilterChip(label: const Text("Hab. Compartida"), selected: resHabComp, onSelected: (v) => setState(() { resHabComp = v; if(v) resHabIndiv = false; })),
          FilterChip(label: const Text("Desayuno"), selected: resDesayuno, onSelected: (v) => setState(() => resDesayuno = v)),
          FilterChip(label: const Text("Almuerzo"), selected: resAlmuerzo, onSelected: (v) => setState(() => resAlmuerzo = v)),
          FilterChip(label: const Text("Gym"), selected: resGym, onSelected: (v) => setState(() => resGym = v)),
        ] else ...[
          FilterChip(label: const Text("Agua"), selected: servAgua, onSelected: (v) => setState(() => servAgua = v)),
          FilterChip(label: const Text("Luz"), selected: servLuz, onSelected: (v) => setState(() => servLuz = v)),
          FilterChip(label: const Text("WiFi"), selected: servWifi, onSelected: (v) => setState(() => servWifi = v)),
          FilterChip(label: const Text("Lavadora"), selected: servLavadora, onSelected: (v) => setState(() => servLavadora = v)),
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
    // Filtrar fotos que ya estaban en Supabase y que NO hemos marcado para borrar
    final List<String> fotosExistentes = (widget.propertyAEditar?.imageUrls ?? [])
        .where((url) => !_urlsABorrar.contains(url))
        .toList();

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            final List<XFile> imagenes = await _picker.pickMultiImage();
            if (imagenes.isNotEmpty) setState(() => _imagenesSeleccionadas.addAll(imagenes));
          }, 
          icon: const Icon(Icons.add_a_photo), 
          label: const Text("Añadir Fotos")
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8
          ),
          itemCount: fotosExistentes.length + _imagenesSeleccionadas.length,
          itemBuilder: (ctx, i) {
            if (i < fotosExistentes.length) {
              // FOTO REMOTA (Supabase)
              final url = fotosExistentes[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(url, fit: BoxFit.cover)),
                  Positioned(
                    right: 0, top: 0,
                    child: IconButton(
                      icon: const CircleAvatar(backgroundColor: Colors.red, radius: 10, child: Icon(Icons.close, size: 12, color: Colors.white)),
                      onPressed: () => setState(() => _urlsABorrar.add(url)),
                    )
                  ),
                ],
              );
            } else {
              // FOTO LOCAL (Nueva)
              final localIndex = i - fotosExistentes.length;
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_imagenesSeleccionadas[localIndex].path), fit: BoxFit.cover)),
                  Positioned(
                    right: 0, top: 0,
                    child: IconButton(
                      icon: const CircleAvatar(backgroundColor: Colors.black, radius: 10, child: Icon(Icons.close, size: 12, color: Colors.white)),
                      onPressed: () => setState(() => _imagenesSeleccionadas.removeAt(localIndex)),
                    )
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, Color bg, Color txt, VoidCallback onPres) => SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: bg, foregroundColor: txt, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 15)), onPressed: onPres, child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold))));
}