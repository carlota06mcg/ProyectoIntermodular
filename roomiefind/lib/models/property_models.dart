class Property {
  final String title;
  final String type;
  final String price;
  final String imageUrl;
  bool isFavorite; // El booleano que pediste

  Property({
    required this.title,
    required this.type,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });
}