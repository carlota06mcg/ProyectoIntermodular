class Property {
  final String title;
  final String type;
  final String price;
  final String imageUrl;
  bool isFavorite;
 // Se me ha pasdao el valor para que haga la busqueda por google hay que hacer que los nombres esten bien

  Property({
    required this.title,
    required this.type,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });
  // Lista de ejemplo para probar la UI
}
final List<Property> propiedadesPrueba = [
  Property(
    
    title: 'Alquiler de estudio en Calle Almona de San Juan de Dios',
    type: 'Piso de Estudiantes',
    price: '470',
    imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=1000&auto=format&fit=crop',
    isFavorite: true,
  ),
  Property(
    
    title: 'Habitación luminosa cerca de la Facultad de Ciencias',
    type: 'Habitación',
    price: '320',
    imageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?q=80&w=1000&auto=format&fit=crop',
    isFavorite: false,
  ),
  Property(
    
    title: 'Apartamento moderno en el centro histórico',
    type: 'Apartamento Entero',
    price: '850',
    imageUrl: 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?q=80&w=1000&auto=format&fit=crop',
    isFavorite: true,
  ),
];