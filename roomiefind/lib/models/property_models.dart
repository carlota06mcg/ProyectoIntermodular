class PropertyModel {
  final String? id;
  final String ownerId;
  final String title;
  final String type;
  final String location;
  final double price;
  final String description;
  final List<String> imageUrls;
  final Map<String, bool> transport;
  final Map<String, bool> services;
  final Map<String, bool> additionalInfo;
  final DateTime? availableDate;

  PropertyModel({
    this.id,
    required this.ownerId,
    required this.title,
    required this.type,
    required this.location,
    required this.price,
    required this.description,
    this.imageUrls = const [],
    required this.transport,
    required this.services,
    required this.additionalInfo,
    this.availableDate,
  });

  // De JSON (Supabase) a Objeto Dart
  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      id: json['id'],
      ownerId: json['owner_id'],
      title: json['title'],
      type: json['type'],
      location: json['location'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      imageUrls: List<String>.from(json['images'] ?? []),
      transport: Map<String, bool>.from(json['transport'] ?? {}),
      services: Map<String, bool>.from(json['services'] ?? {}),
      additionalInfo: Map<String, bool>.from(json['additional_info'] ?? {}),
      availableDate: json['available_date'] != null 
          ? DateTime.parse(json['available_date']) 
          : null,
    );
  }

  // De Objeto Dart a JSON (para guardar en Supabase)
  Map<String, dynamic> toJson() {
    return {
      'owner_id': ownerId,
      'title': title,
      'type': type,
      'location': location,
      'price': price,
      'description': description,
      'images': imageUrls,
      'transport': transport,
      'services': services,
      'additional_info': additionalInfo,
      'available_date': availableDate?.toIso8601String(),
    };
  }

  
}