class PropertyModel {
  final String? id;
  final String ownerId;
  final String title;
  final String type; // Estudio, Piso Compartido, Residencia
  
  // Ubicación desglosada
  final String streetNameNumber;
  final String city;
  final String locality;
  final String zipCode;
  
  final double price;
  final String description;
  final List<String> imageUrls;
  
  // Mapas para los JSONB de Supabase
  final Map<String, dynamic> services; 
  final Map<String, dynamic> additionalInfo;
  final String? transport; 
  final DateTime? createdAt;

  PropertyModel({
    this.id,
    required this.ownerId,
    required this.title,
    required this.type,
    required this.streetNameNumber,
    required this.city,
    required this.locality,
    required this.zipCode,
    required this.price,
    required this.description,
    required this.imageUrls,
    required this.services,
    required this.additionalInfo,
    this.transport,
    this.createdAt,
  });

  // Convierte un mapa de Supabase (JSON) a nuestro objeto de Dart
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'],
      ownerId: json['owner_id'],
      title: json['title'] ?? '',
      type: json['type'] ?? 'Piso Compartido',
      streetNameNumber: json['street_name_number'] ?? '',
      city: json['city'] ?? '',
      locality: json['locality'] ?? '',
      zipCode: json['zip_code'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      // Al ser JSONB en Supabase, los extraemos como Mapas
      services: Map<String, dynamic>.from(json['services'] ?? {}),
      additionalInfo: Map<String, dynamic>.from(json['additional_info'] ?? {}),
      transport: json['transport']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  // Convierte nuestro objeto de Dart a un mapa para enviar a Supabase
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'owner_id': ownerId,
      'title': title,
      'type': type,
      'street_name_number': streetNameNumber,
      'city': city,
      'locality': locality,
      'zip_code': zipCode,
      'price': price,
      'description': description,
      'imageUrls': imageUrls,
      'services': services,
      'additional_info': additionalInfo,
      'transport': transport,
    };
  }
}