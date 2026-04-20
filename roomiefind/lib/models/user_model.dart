// 1. EL ENUM DEBE IR FUERA DE LA CLASE O AL PRINCIPIO
enum UserRole {
  estudiante,
  propietario,
  none
}

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? description;
  final String? location;
  final String? studies;     // Campos específicos para Carlota (Estudiante)
  final String? institution;
  final String? avatarUrl;
  final UserRole role;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.description,
    this.location,
    this.studies,
    this.institution,
    this.avatarUrl,
    this.role = UserRole.none,
  });

  // 2. CONVERTIR DE JSON (Supabase) A DART
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      description: json['description'],
      location: json['location'],
      studies: json['studies'],
      institution: json['institution'],
      avatarUrl: json['avatar_url'],
      role: _parseRole(json['role']),
    );
  }

  // 3. CONVERTIR DE DART A JSON (Para enviar a Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'description': description,
      'location': location,
      'studies': studies,
      'institution': institution,
      'avatar_url': avatarUrl,
      'role': role.name, // .name guarda 'estudiante' o 'propietario' como texto
    };
  }

  // Función auxiliar para leer el rol desde la base de datos
  static UserRole _parseRole(String? roleString) {
    if (roleString == 'estudiante') return UserRole.estudiante;
    if (roleString == 'propietario') return UserRole.propietario;
    return UserRole.none;
  }
}