enum UserRole { estudiante, propietario, none }

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? username; // <-- AÑADIDO: El @nombre_de_usuario
  final String? description;
  final String? location;
  final String? studies;
  final String? institution;
  final String? avatarUrl;
  final UserRole role;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.username,
    this.description,
    this.location,
    this.studies,
    this.institution,
    this.avatarUrl,
    this.role = UserRole.none,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      username: json['username'], // <-- AÑADIDO (Asegúrate de tener esta columna en Supabase)
      description: json['description'],
      location: json['location'],
      studies: json['studies'],
      institution: json['institution'],
      avatarUrl: json['avatar_url'],
      role: _parseRole(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username, // <-- AÑADIDO
      'description': description,
      'location': location,
      'studies': studies,
      'institution': institution,
      'avatar_url': avatarUrl,
      'role': role.name,
    };
  }

  static UserRole _parseRole(String? roleString) {
    if (roleString == 'estudiante') return UserRole.estudiante;
    if (roleString == 'propietario') return UserRole.propietario;
    return UserRole.none;
  }
}