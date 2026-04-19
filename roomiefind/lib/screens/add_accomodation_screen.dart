import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: AddAccommodationScreen()));

class AddAccommodationScreen extends StatefulWidget {
  const AddAccommodationScreen({super.key});

  @override
  State<AddAccommodationScreen> createState() => _AddAccommodationScreenState();
}

class _AddAccommodationScreenState extends State<AddAccommodationScreen> {
  // Controladores y estados
  final _descController = TextEditingController();
  bool isBusSelected = true;
  bool isMetroSelected = false;
  DateTime selectedDate = DateTime(1992, 11, 21);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.redAccent),
        title: const Text(
          "Agregar Nuevo Alojamiento",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Nombre del alojamiento"),
            _buildTextField("Alquiler de estudio en Calle Almona..."),

            const SizedBox(height: 15),
            _buildLabel("Tipo de alojamiento"),
            _buildDropdown(["Piso de Estudiantes", "Apartamento", "Casa"]),

            const SizedBox(height: 15),
            _buildLabel("Ubicación"),
            _buildTextField("Calle Imaginaria 21, Granada"),

            const SizedBox(height: 15),
            _buildLabel("Precio mensual"),
            _buildTextField("430€"),

            const SizedBox(height: 20),
            _buildLabel("Escribe una breve descripción"),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Lorem ipsum is simply dummy text...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(style: BorderStyle.none),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                "350 caracteres",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),
            _buildLabel("Transporte cercano (selecciona al menos 1)"),
            Row(
              children: [
                _buildTransportToggle(
                  "Autobús",
                  Icons.directions_bus,
                  isBusSelected,
                  (val) => setState(() => isBusSelected = val),
                ),
                const SizedBox(width: 20),
                _buildTransportToggle(
                  "Metro",
                  Icons.train,
                  isMetroSelected,
                  (val) => setState(() => isMetroSelected = val),
                ),
              ],
            ),

            const SizedBox(height: 20),
            _buildLabel("Fechas disponibles"),
            _buildDatePicker(),

            const SizedBox(height: 20),
            _buildLabel("Agregar fotos"),
            _buildPhotoGallery(),

            const SizedBox(height: 20),
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red[800],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  "PUBLICIDAD",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            _buildLabel("Servicios Incluidos"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildServiceIcon(Icons.bed, "Habitaciones", true),
                _buildServiceIcon(Icons.bathtub, "Agua", false),
                _buildServiceIcon(Icons.bolt, "Luz", false),
                _buildServiceIcon(Icons.wifi, "WIFI", false),
              ],
            ),

            const SizedBox(height: 30),
            _buildActionButton("Confirmar", Colors.red[800]!, Colors.white),
            const SizedBox(height: 10),
            _buildActionButton(
              "Volver al Inicio",
              Colors.red[200]!,
              Colors.red[900]!,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildDropdown(List<String> options) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options[0],
          isExpanded: true,
          items: options
              .map(
                (String value) =>
                    DropdownMenuItem(value: value, child: Text(value)),
              )
              .toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }

  Widget _buildTransportToggle(
    String label,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[700]),
        Text(label, style: const TextStyle(fontSize: 12)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.redAccent,
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("November/21/1992"),
          Icon(Icons.calendar_month, color: Colors.grey[700]),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            'https://via.placeholder.com/400x200',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            4,
            (index) => Container(
              width: 70,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceIcon(IconData icon, String label, bool isSelected) {
    return Container(
      width: 75,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: isSelected ? Colors.red : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
        color: isSelected ? Colors.red[50] : Colors.white,
      ),
      child: Column(
        children: [
          Icon(icon, color: isSelected ? Colors.red : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isSelected ? Colors.red : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color bgColor, Color textColor) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
