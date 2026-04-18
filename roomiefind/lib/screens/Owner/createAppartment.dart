import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FormularioAlojamientoScreen extends StatefulWidget {
  final Map<String, dynamic>? alojamientoAEditar;

  const FormularioAlojamientoScreen({Key? key, this.alojamientoAEditar}) : super(key: key);

  @override
  _FormularioAlojamientoScreenState createState() => _FormularioAlojamientoScreenState();
}

class _FormularioAlojamientoScreenState extends State<FormularioAlojamientoScreen> {
  // --- CONFIGURACIÓN DE COLORES ---
  final Color primaryRed = const Color(0xFFB02A37);
  final Color lightRed = const Color(0xFFF8D7DA);
  final Color inputFillColor = const Color(0xFFF5F5F5);

  // --- CONTROLADORES DE TEXTO ---
  late TextEditingController _nombreController;
  late TextEditingController _ubicacionController;
  late TextEditingController _precioController;
  late TextEditingController _descripcionController;
  late TextEditingController _fechaController;

  // --- ESTADO DE IMÁGENES ---
  final ImagePicker _picker = ImagePicker();
  List<XFile> _imagenesSeleccionadas = [];

  // --- ESTADOS DE SELECCIÓN ---
  bool get esEdicion => widget.alojamientoAEditar != null;
  
  bool tieneAutobus = true;
  bool tieneMetro = false;

  bool servHabIndiv = true;
  bool servAgua = false;
  bool servLuz = false;
  bool servWifi = false;

  bool infoMascotas = true;
  bool infoFumadores = false;
  bool infoSoloHyM = true;
  bool infoCompartido = false;

  @override
  void initState() {
    super.initState();
    // Inicialización de controladores
    _nombreController = TextEditingController(text: esEdicion ? widget.alojamientoAEditar!['nombre'] : '');
    _ubicacionController = TextEditingController(text: esEdicion ? widget.alojamientoAEditar!['ubicacion'] : '');
    _precioController = TextEditingController(text: esEdicion ? widget.alojamientoAEditar!['precio'] : '');
    _descripcionController = TextEditingController(text: esEdicion ? widget.alojamientoAEditar!['descripcion'] : '');
    _fechaController = TextEditingController(text: esEdicion ? widget.alojamientoAEditar!['fecha'] : 'Noviembre / 21 / 1990');
    
    // Si quisieras cargar los bools en modo edición, lo harías aquí:
    // tieneAutobus = widget.alojamientoAEditar?['autobus'] ?? true;
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

  // --- LÓGICA DE FOTOS ---
  Future<void> _seleccionarFotos() async {
    final List<XFile> imagenes = await _picker.pickMultiImage();
    if (imagenes.isNotEmpty) {
      setState(() {
        _imagenesSeleccionadas.addAll(imagenes);
      });
    }
  }

  // --- CAPTURA DE TODOS LOS DATOS ---
  void _procesarFormulario() {
    final Map<String, dynamic> datosCompletos = {
      "nombre": _nombreController.text,
      "ubicacion": _ubicacionController.text,
      "precio": _precioController.text,
      "descripcion": _descripcionController.text,
      "fecha": _fechaController.text,
      "fotos_rutas": _imagenesSeleccionadas.map((e) => e.path).toList(),
      "transporte": {
        "autobus": tieneAutobus,
        "metro": tieneMetro,
      },
      "servicios": {
        "habitacion_individual": servHabIndiv,
        "agua": servAgua,
        "luz": servLuz,
        "wifi": servWifi,
      },
      "informacion_adicional": {
        "mascotas": infoMascotas,
        "fumadores": infoFumadores,
        "solo_hombres_mujeres": infoSoloHyM,
        "compartido": infoCompartido,
      },
      "modo": esEdicion ? "UPDATE" : "CREATE"
    };

    print("=== ENVÍO COMPLETO DE DATOS ===");
    print(datosCompletos);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(esEdicion ? "Guardando cambios..." : "Publicando alojamiento..."),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryRed),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          esEdicion ? "Editar Alojamiento" : "Agregar Nuevo Alojamiento",
          style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Nombre del alojamiento"),
            _buildTextField(_nombreController, "Ej: Apartamento luminoso"),

            _buildLabel("Tipo de alojamiento"),
            _buildDropdownField("Piso de Estudiantes"),

            _buildLabel("Ubicación"),
            _buildTextField(_ubicacionController, "Calle, Número, Ciudad"),

            _buildLabel("Precio mensual"),
            _buildTextField(_precioController, "€000", isNumber: true),

            _buildLabel("Escribe una breve descripción"),
            _buildTextArea(_descripcionController, "Cuéntanos más sobre el lugar..."),

            _buildLabel("Transporte cercano"),
            Row(
              children: [
                _buildTransportIcon(Icons.directions_bus, "Autobús", tieneAutobus, (val) => setState(() => tieneAutobus = val)),
                const SizedBox(width: 30),
                _buildTransportIcon(Icons.directions_subway, "Metro", tieneMetro, (val) => setState(() => tieneMetro = val)),
              ],
            ),

            _buildLabel("Fechas disponibles"),
            _buildTextField(_fechaController, "Seleccionar fecha", suffixIcon: Icons.calendar_today_outlined),

            _buildLabel("Agregar fotos"),
            _buildPhotoSection(),

            const SizedBox(height: 20),
            _buildBannerPublicidad(),

            _buildLabel("Servicios Incluidos"),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildServiceItem(Icons.bed, "Habitaciones\nIndividuales", servHabIndiv, () => setState(() => servHabIndiv = !servHabIndiv)),
                  _buildServiceItem(Icons.opacity, "Agua", servAgua, () => setState(() => servAgua = !servAgua)),
                  _buildServiceItem(Icons.whatshot, "Luz", servLuz, () => setState(() => servLuz = !servLuz)),
                  _buildServiceItem(Icons.wifi, "WiFi", servWifi, () => setState(() => servWifi = !servWifi)),
                ],
              ),
            ),

            _buildLabel("Información Adicional"),
            _buildCheckboxItem("Mascotas", infoMascotas, (val) => setState(() => infoMascotas = val!)),
            _buildCheckboxItem("Apto para fumadores", infoFumadores, (val) => setState(() => infoFumadores = val!)),
            _buildCheckboxItem("Solo hombres y mujeres", infoSoloHyM, (val) => setState(() => infoSoloHyM = val!)),
            _buildCheckboxItem("Alojamiento compartido", infoCompartido, (val) => setState(() => infoCompartido = val!)),

            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(child: _buildActionButton(esEdicion ? "Guardar" : "Confirmar", primaryRed, Colors.white, _procesarFormulario)),
                const SizedBox(width: 15),
                Expanded(child: _buildActionButton("Cancelar", lightRed, primaryRed, () => Navigator.pop(context))),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text("$text *", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, IconData? suffixIcon}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: inputFillColor,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }

  Widget _buildTextArea(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(15),
      ),
    );
  }

  Widget _buildDropdownField(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: inputFillColor, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: [DropdownMenuItem(child: Text(value), value: value)],
          onChanged: (v) {},
        ),
      ),
    );
  }

  Widget _buildTransportIcon(IconData icon, String label, bool isSelected, Function(bool) onChanged) {
    return Column(
      children: [
        Icon(icon, size: 30, color: isSelected ? Colors.black : Colors.grey),
        Text(label, style: const TextStyle(fontSize: 12)),
        Switch(value: isSelected, onChanged: onChanged, activeColor: primaryRed),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _seleccionarFotos,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: inputFillColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade300),
              image: _imagenesSeleccionadas.isNotEmpty
                  ? DecorationImage(image: FileImage(File(_imagenesSeleccionadas[0].path)), fit: BoxFit.cover)
                  : null,
            ),
            child: _imagenesSeleccionadas.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, color: primaryRed, size: 40),
                      const Text("Añadir fotos", style: TextStyle(color: Colors.grey)),
                    ],
                  )
                : null,
          ),
        ),
        if (_imagenesSeleccionadas.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imagenesSeleccionadas.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(image: FileImage(File(_imagenesSeleccionadas[index].path)), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => _imagenesSeleccionadas.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 14, color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildBannerPublicidad() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: primaryRed, borderRadius: BorderRadius.circular(12)),
      child: const Center(
        child: Text("PUBLICIDAD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(12),
        width: 100,
        decoration: BoxDecoration(
          color: isSelected ? lightRed : Colors.white,
          border: Border.all(color: isSelected ? primaryRed : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryRed),
            const SizedBox(height: 5),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: primaryRed, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxItem(String title, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: primaryRed,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.trailing,
      dense: true,
    );
  }

  Widget _buildActionButton(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}