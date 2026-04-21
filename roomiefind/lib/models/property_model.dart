class PropertyModel {
  final String id;
  final String ownerId;
  final String title;
  final String type;
  final String location;
  final double price;
  final String description;
  final List<String> imageUrls;
  final Map<String, dynamic> transport;
  final Map<String, dynamic> services;
  final Map<String, dynamic> additionalInfo;
  final DateTime? availableDate;

  PropertyModel({
    required this.id,
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
      transport: Map<String, dynamic>.from(json['transport'] ?? {}),
      services: Map<String, dynamic>.from(json['services'] ?? {}),
      additionalInfo: Map<String, dynamic>.from(json['additional_info'] ?? {}),
      availableDate: json['available_date'] != null
          ? DateTime.parse(json['available_date'])
          : null,
    );
  }

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
