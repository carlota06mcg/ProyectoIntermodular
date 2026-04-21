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
  // --- CONFIGURACIÓN DE ESTILO ---
  final Color primaryRed = const Color(0xFFB02A37);
  final Color lightRed = const Color(0xFFF8D7DA);
  final Color inputFillColor = const Color(0xFFF5F5F5);

  // --- CONTROLADORES ---
  late TextEditingController _nombreController;
  late TextEditingController _ubicacionController;
  late TextEditingController _precioController;
  late TextEditingController _descripcionController;
  late TextEditingController _fechaController;

  // --- ESTADO ---
  final ImagePicker _picker = ImagePicker();
  List<XFile> _imagenesSeleccionadas = [];
  
  bool get esEdicion => widget.propertyAEditar != null;

  bool tieneAutobus = false;
  bool tieneMetro = false;
  bool servHabIndiv = false;
  bool servAgua = false;
  bool servLuz = false;
  bool servWifi = false;
  bool infoMascotas = false;
  bool infoFumadores = false;
  bool infoSoloHyM = false;
  bool infoCompartido = false;

  @override
  void initState() {
    super.initState();
    final p = widget.propertyAEditar;

    _nombreController = TextEditingController(text: esEdicion ? p!.title : '');
    _ubicacionController = TextEditingController(text: esEdicion ? p!.location : '');
    _precioController = TextEditingController(text: esEdicion ? p!.price.toString() : '');
    _descripcionController = TextEditingController(text: esEdicion ? p!.description : '');
    _fechaController = TextEditingController(text: 'Seleccionar fecha');

    if (esEdicion && p != null) {
      tieneAutobus = p.transport['autobus'] ?? false;
      tieneMetro = p.transport['metro'] ?? false;
      servHabIndiv = p.services['habitacion_individual'] ?? false;
      servAgua = p.services['agua'] ?? false;
      servLuz = p.services['luz'] ?? false;
      servWifi = p.services['wifi'] ?? false;
      infoMascotas = p.additionalInfo['mascotas'] ?? false;
      infoFumadores = p.additionalInfo['fumadores'] ?? false;
      infoSoloHyM = p.additionalInfo['solo_hombres_mujeres'] ?? false;
      infoCompartido = p.additionalInfo['compartido'] ?? false;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _ubicacionController.dispose();
    _precioController.dispose();
    _descripcionController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFotos() async {
    final List<XFile> imagenes = await _picker.pickMultiImage();
    if (imagenes.isNotEmpty) {
      setState(() => _imagenesSeleccionadas.addAll(imagenes));
    }
  }

  Future<void> _procesarFormulario() async {
    final propVM = Provider.of<PropertyViewModel>(context, listen: false);
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      _showSnackBar("Debes iniciar sesión para publicar", Colors.red);
      return;
    }

    if (_nombreController.text.isEmpty || _precioController.text.isEmpty) {
      _showSnackBar("Rellena los campos obligatorios", Colors.orange);
      return;
    }

final propiedadData = PropertyModel(
  id: esEdicion
      ? widget.propertyAEditar!.id
      : "temp_${DateTime.now().millisecondsSinceEpoch}",
  ownerId: user.id,
  title: _nombreController.text,
  type: "Piso de Estudiantes",
  location: _ubicacionController.text,
  price: double.tryParse(_precioController.text) ?? 0.0,
  description: _descripcionController.text,
  imageUrls: esEdicion ? widget.propertyAEditar!.imageUrls : [],
  transport: {"autobus": tieneAutobus, "metro": tieneMetro},
  services: {
    "habitacion_individual": servHabIndiv,
    "agua": servAgua,
    "luz": servLuz,
    "wifi": servWifi,
  },
  additionalInfo: {
    "mascotas": infoMascotas,
    "fumadores": infoFumadores,
    "solo_hombres_mujeres": infoSoloHyM,
    "compartido": infoCompartido,
  },
  availableDate: DateTime.now(),
);


    bool exito;
    if (esEdicion) {
      exito = await propVM.updateProperty(propiedadData, _imagenesSeleccionadas);
    } else {
      exito = await propVM.publishProperty(propiedadData, _imagenesSeleccionadas);
    }

    if (exito && mounted) {
      _showSnackBar(esEdicion ? "¡Actualizado!" : "¡Publicado!", Colors.green);
      Navigator.pop(context);
    } else if (mounted) {
      _showSnackBar(propVM.errorMessage ?? "Error al guardar", Colors.red);
    }
  }

  void _showSnackBar(String m, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<PropertyViewModel>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: primaryRed), onPressed: () => Navigator.pop(context)),
        title: Text(esEdicion ? "Editar Alojamiento" : "Nuevo Alojamiento",
            style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryRed))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Nombre del alojamiento"),
                  _buildTextField(_nombreController, "Ej: Apartamento luminoso"),
                  _buildLabel("Ubicación"),
                  _buildTextField(_ubicacionController, "Calle, Número, Ciudad"),
                  _buildLabel("Precio mensual"),
                  _buildTextField(_precioController, "€000", isNumber: true),
                  _buildLabel("Descripción"),
                  _buildTextArea(_descripcionController, "Cuéntanos más..."),
                  
                  _buildLabel("Transporte cercano"),
                  Row(
                    children: [
                      _buildTransportIcon(Icons.directions_bus, "Autobús", tieneAutobus, (v) => setState(() => tieneAutobus = v)),
                      const SizedBox(width: 30),
                      _buildTransportIcon(Icons.directions_subway, "Metro", tieneMetro, (v) => setState(() => tieneMetro = v)),
                    ],
                  ),

                  _buildLabel("Fotos"),
                  _buildPhotoSection(),

                  const SizedBox(height: 20),
                  _buildLabel("Servicios Incluidos"),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildServiceItem(Icons.bed, "Hab. Individual", servHabIndiv, () => setState(() => servHabIndiv = !servHabIndiv)),
                        _buildServiceItem(Icons.opacity, "Agua", servAgua, () => setState(() => servAgua = !servAgua)),
                        _buildServiceItem(Icons.whatshot, "Luz", servLuz, () => setState(() => servLuz = !servLuz)),
                        _buildServiceItem(Icons.wifi, "WiFi", servWifi, () => setState(() => servWifi = !servWifi)),
                      ],
                    ),
                  ),

                  _buildLabel("Información Adicional"),
                  _buildCheckboxItem("Mascotas", infoMascotas, (v) => setState(() => infoMascotas = v!)),
                  _buildCheckboxItem("Apto fumadores", infoFumadores, (v) => setState(() => infoFumadores = v!)),
                  _buildCheckboxItem("Solo hombres/mujeres", infoSoloHyM, (v) => setState(() => infoSoloHyM = v!)),
                  _buildCheckboxItem("Compartido", infoCompartido, (v) => setState(() => infoCompartido = v!)),

                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(child: _buildActionButton(esEdicion ? "Guardar" : "Confirmar", primaryRed, Colors.white, _procesarFormulario)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildActionButton("Cancelar", lightRed, primaryRed, () => Navigator.pop(context))),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text("$text *", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
  );

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) => TextField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      hintText: hint, filled: true, fillColor: inputFillColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );

  Widget _buildTextArea(TextEditingController controller, String hint) => TextField(
    controller: controller, maxLines: 4,
    decoration: InputDecoration(
      hintText: hint, filled: true, fillColor: inputFillColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );

  Widget _buildTransportIcon(IconData icon, String label, bool isSelected, Function(bool) onChanged) => Column(
    children: [
      Icon(icon, color: isSelected ? primaryRed : Colors.grey),
      Text(label, style: const TextStyle(fontSize: 10)),
      Switch(value: isSelected, onChanged: onChanged, activeColor: primaryRed),
    ],
  );

  Widget _buildPhotoSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _seleccionarFotos,
          child: Container(
            height: 120, width: double.infinity,
            decoration: BoxDecoration(color: inputFillColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
            child: const Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
          ),
        ),
        if (_imagenesSeleccionadas.isNotEmpty)
          Container(
            height: 80, margin: const EdgeInsets.only(top: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imagenesSeleccionadas.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(_imagenesSeleccionadas[i].path), width: 80, height: 80, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildServiceItem(IconData icon, String label, bool isSelected, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.all(10), width: 90,
      decoration: BoxDecoration(
        color: isSelected ? lightRed : Colors.white,
        border: Border.all(color: isSelected ? primaryRed : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [Icon(icon, color: primaryRed, size: 20), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9))]),
    ),
  );

  Widget _buildCheckboxItem(String title, bool value, Function(bool?) onChanged) => CheckboxListTile(
    title: Text(title, style: const TextStyle(fontSize: 13)), value: value, onChanged: onChanged,
    activeColor: primaryRed, dense: true, contentPadding: EdgeInsets.zero,
  );

  Widget _buildActionButton(String text, Color bg, Color txt, VoidCallback onPres) => ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: bg, foregroundColor: txt, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 15)),
    onPressed: onPres, child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}