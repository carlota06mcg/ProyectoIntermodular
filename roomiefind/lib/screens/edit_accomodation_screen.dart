import 'package:flutter/material.dart';

class Alojamiento {
  String nombre;
  String tipo;
  String ubicacion;
  double precio;
  String descripcion;

  Alojamiento({
    required this.nombre,
    required this.tipo,
    required this.ubicacion,
    required this.precio,
    required this.descripcion,
  });
}

class EditAccommodationScreen extends StatefulWidget {
  final Alojamiento?
  alojamientoExistente; // Si es nulo, es "Nuevo", si no, es "Editar"

  const EditAccommodationScreen({super.key, this.alojamientoExistente});

  @override
  State<EditAccommodationScreen> createState() =>
      _EditAccommodationScreenState();
}

class _EditAccommodationScreenState extends State<EditAccommodationScreen> {
  // Declaramos los controladores
  late TextEditingController _nombreController;
  late TextEditingController _ubicacionController;
  late TextEditingController _precioController;
  late TextEditingController _descController;

  String _tipoSeleccionado = "Piso de Estudiantes";

  @override
  void initState() {
    super.initState();

    // Si recibimos un alojamiento, rellenamos los controladores con sus datos
    // Si no, los dejamos vacíos
    _nombreController = TextEditingController(
      text: widget.alojamientoExistente?.nombre ?? "",
    );
    _ubicacionController = TextEditingController(
      text: widget.alojamientoExistente?.ubicacion ?? "",
    );
    _precioController = TextEditingController(
      text: widget.alojamientoExistente?.precio.toString() ?? "",
    );
    _descController = TextEditingController(
      text: widget.alojamientoExistente?.descripcion ?? "",
    );

    if (widget.alojamientoExistente != null) {
      _tipoSeleccionado = widget.alojamientoExistente!.tipo;
    }
  }

  @override
  void dispose() {
    // Es importante limpiar los controladores al cerrar la pantalla
    _nombreController.dispose();
    _ubicacionController.dispose();
    _precioController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool esEdicion = widget.alojamientoExistente != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? "Editar Alojamiento" : "Nuevo Alojamiento"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Nombre del alojamiento"),
            _buildTextField(_nombreController, "Ej: Alquiler de estudio..."),

            const SizedBox(height: 15),
            _buildLabel("Tipo de alojamiento"),
            _buildDropdown(["Piso de Estudiantes", "Apartamento", "Casa"]),

            const SizedBox(height: 15),
            _buildLabel("Ubicación"),
            _buildTextField(_ubicacionController, "Dirección completa"),

            const SizedBox(height: 15),
            _buildLabel("Precio mensual"),
            _buildTextField(_precioController, "0.00€", isNumber: true),

            const SizedBox(height: 15),
            _buildLabel("Descripción"),
            _buildTextField(_descController, "Escribe aquí...", maxLines: 4),

            const SizedBox(height: 30),

            // Botón que cambia de texto según el modo
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                ),
                onPressed: () {
                  // Aquí iría la lógica para GUARDAR los cambios
                  final datosActualizados = {
                    "nombre": _nombreController.text,
                    "precio": _precioController.text,
                    // ... etc
                  };
                  print("Guardando: $datosActualizados");
                  Navigator.pop(context); // Volver atrás al terminar
                },
                child: Text(
                  esEdicion ? "GUARDAR CAMBIOS" : "CONFIRMAR",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS REUTILIZABLES CON CONTROLADORES ---

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller, // ESTO ES LO CLAVE PARA EDITAR
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDropdown(List<String> options) {
    return DropdownButtonFormField<String>(
      value: _tipoSeleccionado,
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (val) => setState(() => _tipoSeleccionado = val!),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
