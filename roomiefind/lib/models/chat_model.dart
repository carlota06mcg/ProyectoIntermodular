class ChatModel {
  final String id;
  final String user1Id;
  final String user2Id;
  final String? lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  // NUEVOS CAMPOS PARA MOSTRAR NOMBRE Y AVATAR
  final String? user1Name;
  final String? user2Name;
  final String? user1Avatar;
  final String? user2Avatar;

  ChatModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
    this.user1Name,
    this.user2Name,
    this.user1Avatar,
    this.user2Avatar,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      user1Id: json['user1_id'],
      user2Id: json['user2_id'],
      lastMessage: json['last_message'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),

      // CAMPOS DEL JOIN CON PROFILES
      user1Name: json['user1']?['full_name'],
      user2Name: json['user2']?['full_name'],
      user1Avatar: json['user1']?['avatar_url'],
      user2Avatar: json['user2']?['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'last_message': lastMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
