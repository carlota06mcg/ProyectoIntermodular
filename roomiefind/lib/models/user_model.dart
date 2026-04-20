enum UserRole {
  estudiante,
  propietario,
  none
}

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String username;
  final UserRole role;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.username,
    this.role = UserRole.none,
  });

  // Convertir de JSON (Supabase) a nuestro objeto Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      username: json['username'] ?? '',
      role: _parseRole(json['role']),
    );
  }

  // Función auxiliar para entender qué rol viene de la DB
  static UserRole _parseRole(String? roleString) {
    switch (roleString) {
      case 'estudiante':
        return UserRole.estudiante;
      case 'propietario':
        return UserRole.propietario;
      default:
        return UserRole.none;
    }
  }

  // Convertir nuestro objeto a JSON para enviar a Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'role': role.name, // .name convierte el enum a String ('estudiante' o 'propietario')
    };
  }
}