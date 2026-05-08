import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/models/property_model.dart';
import 'package:roomiefind/screens/Shared/Chat/chat-plantilla.dart';
import 'package:roomiefind/viewmodels/chat_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roomiefind/widgets/widgets.dart'; 

class PropertyDetailsScreen extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailsScreen({Key? key, required this.property}) : super(key: key);

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  late PropertyModel _currentProperty;
  late String _selectedImageUrl;
  bool _isLoading = true; 
  
  final Color primaryRed = const Color(0xFFB02A37);
  final Color secondaryGrey = const Color(0xFF757575);

  @override
  void initState() {
    super.initState();
    _currentProperty = widget.property;
    _selectedImageUrl = _currentProperty.imageUrls.isNotEmpty 
        ? _currentProperty.imageUrls[0] 
        : '';
    _refreshPropertyData();
  }

  Future<void> _refreshPropertyData() async {
    if (widget.property.id == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('properties') 
          .select()
          .eq('id', widget.property.id!) 
          .single();

      if (mounted) {
        setState(() {
          _currentProperty = PropertyModel.fromJson(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error al refrescar propiedad: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openFullScreenGallery(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenGallery(
          imageUrls: _currentProperty.imageUrls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final bool esPropietario = currentUser?.id == _currentProperty.ownerId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryRed, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Más Información",
          style: TextStyle(color: primaryRed, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 15),
              child: Center(child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFB02A37)))),
            )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPropertyData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _currentProperty.title,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryRed),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.ios_share, color: primaryRed),
                        const SizedBox(width: 15),
                        Icon(Icons.favorite_border, color: primaryRed),
                      ],
                    )
                  ],
                ),
              ),

              _buildLocationHeader(),
              const SizedBox(height: 15),
              _buildQuickTransport(),
              const SizedBox(height: 20),
              _buildGallerySection(),
              _buildPriceAndRating(),

              const Divider(indent: 20, endIndent: 20),

              _buildSectionTitle("Descripción"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _currentProperty.description,
                  style: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 14),
                ),
              ),

              const SizedBox(height: 25),
              _buildSectionTitle("Suministros y servicios incluidos"),
              _buildServicesGrid(),

              const SizedBox(height: 25),
              _buildSectionTitle("Información adicional"),
              _buildAdditionalInfo(),

              const SizedBox(height: 25),
              _buildSectionTitle("Ubicación exacta"),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: const DecorationImage(
                    image: NetworkImage("https://i.stack.imgur.com/HILXw.png"), 
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 120), 
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomAction(esPropietario, _currentProperty.ownerId),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: primaryRed, fontSize: 16)),
    );
  }

  Widget _buildLocationHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "${_currentProperty.locality}, ${_currentProperty.city}",
                  style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 2),
            child: Text(
              "${_currentProperty.streetNameNumber} · ${_currentProperty.zipCode}",
              style: TextStyle(color: secondaryGrey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTransport() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (_currentProperty.services['transporte_bus'] == true)
            _transportIcon(Icons.directions_bus_outlined, "Bus"),
          if (_currentProperty.services['transporte_tren'] == true)
            _transportIcon(Icons.train_outlined, "Tren/Metro"),
        ],
      ),
    );
  }

  Widget _transportIcon(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 20),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildPriceAndRating() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "${_currentProperty.price.toInt()}€",
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                TextSpan(
                  text: " /mes",
                  style: TextStyle(fontSize: 16, color: secondaryGrey),
                ),
              ],
            ),
          ),
          const Row(
            children: [
              Icon(Icons.star, color: Color(0xFFFFB100), size: 20),
              Text(" 4,8", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(" (500)", style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid() {
    final services = _currentProperty.services;
    List<Widget> items = [];
    
    // Mapeo completo de iconos y etiquetas legibles
    final map = {
      'wifi': {'icon': Icons.wifi, 'label': 'WiFi'},
      'agua': {'icon': Icons.water_drop_outlined, 'label': 'Agua'},
      'luz': {'icon': Icons.lightbulb_outline, 'label': 'Luz'},
      'gas': {'icon': Icons.local_fire_department_outlined, 'label': 'Gas'},
      'lavadora': {'icon': Icons.local_laundry_service_outlined, 'label': 'Lavadora'},
      'cocina': {'icon': Icons.soup_kitchen_outlined, 'label': 'Cocina'},
      'gym': {'icon': Icons.fitness_center, 'label': 'Gimnasio'},
      'desayuno': {'icon': Icons.coffee_outlined, 'label': 'Desayuno'},
      'almuerzo': {'icon': Icons.restaurant_menu, 'label': 'Almuerzo'},
      'cena': {'icon': Icons.nightlight_round, 'label': 'Cena'},
      'salas_estudio': {'icon': Icons.menu_book, 'label': 'Salas estudio'},
      'hab_individual': {'icon': Icons.person_outline, 'label': 'Individual'},
      'hab_compartida': {'icon': Icons.groups_outlined, 'label': 'Compartida'},
      'limpieza': {'icon': Icons.cleaning_services_outlined, 'label': 'Limpieza'},
    };

    map.forEach((key, data) {
      if (services[key] == true) {
        items.add(_buildServiceItem(data['icon'] as IconData, data['label'] as String));
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 20, 
        runSpacing: 15, 
        children: items.isEmpty ? [const Text("No se especifican suministros.")] : items
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String label) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width / 2) - 40,
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.black87), 
          const SizedBox(width: 10), 
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14)))
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    final info = _currentProperty.additionalInfo;
    List<Widget> chips = [];

    if (info['mascotas'] == true) {
      chips.add(_infoChip("Apto mascotas", Icons.pets, Colors.green[700]!));
    } else if (info['mascotas'] == false) {
      chips.add(_infoChip("No apto mascotas", Icons.do_not_disturb_on_outlined, secondaryGrey));
    }

    if (info['fumadores'] == true) {
      chips.add(_infoChip("Apto fumadores", Icons.smoking_rooms, Colors.orange[800]!));
    } else if (info['fumadores'] == false) {
      chips.add(_infoChip("No fumadores", Icons.smoke_free, secondaryGrey));
    }

    if (info['mixto'] == true) {
      chips.add(_infoChip("MIXTO", Icons.wc, primaryRed));
    }
    if (info['solo_mujeres'] == true) {
      chips.add(_infoChip("SOLO MUJERES", Icons.woman, primaryRed));
    }
    if (info['solo_hombres'] == true) {
      chips.add(_infoChip("SOLO HOMBRES", Icons.man, primaryRed));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: chips.isEmpty 
          ? [const Text("Sin restricciones especificadas", style: TextStyle(fontSize: 13, color: Colors.grey))] 
          : chips,
      ),
    );
  }

  Widget _infoChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: color), const SizedBox(width: 8), Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600))]),
    );
  }

  Widget _buildGallerySection() {
    if (_currentProperty.imageUrls.isEmpty) return const SizedBox();
    return Column(
      children: [
        GestureDetector(
          onTap: () => _openFullScreenGallery(_currentProperty.imageUrls.indexOf(_selectedImageUrl)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 250,
            width: double.infinity,
            child: ClipRRect(borderRadius: BorderRadius.circular(15), child: CustomPropertyImage(url: _selectedImageUrl)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _currentProperty.imageUrls.length,
            itemBuilder: (context, index) {
              final url = _currentProperty.imageUrls[index];
              return GestureDetector(
                onTap: () => setState(() => _selectedImageUrl = url),
                child: Container(
                  width: 70, margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: _selectedImageUrl == url ? primaryRed : Colors.transparent, width: 2)),
                  child: ClipRRect(borderRadius: BorderRadius.circular(8), child: CustomPropertyImage(url: url)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(bool esPropietario, String ownerId) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))]),
      child: SizedBox(
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: primaryRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
          onPressed: () async {
            if (!esPropietario) {
              final vm = Provider.of<ChatViewModel>(context, listen: false);
              final String chatId = await vm.createChatWith(ownerId);
              if (context.mounted && chatId.isNotEmpty) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatPlantillaScreen(chatId: chatId, otherUserId: ownerId)));
              }
            }
          },
          child: Text(esPropietario ? "GESTIONAR ALOJAMIENTO" : "CONTACTAR AHORA", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}

class FullScreenGallery extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;
  const FullScreenGallery({Key? key, required this.imageUrls, required this.initialIndex}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            itemCount: imageUrls.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) => Center(child: InteractiveViewer(child: Image.network(imageUrls[index], fit: BoxFit.contain))),
          ),
          Positioned(top: 40, right: 20, child: SafeArea(child: GestureDetector(onTap: () => Navigator.pop(context), child: Container(decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle), padding: const EdgeInsets.all(8), child: const Icon(Icons.close, color: Colors.white, size: 24))))),
        ],
      ),
    );
  }
}