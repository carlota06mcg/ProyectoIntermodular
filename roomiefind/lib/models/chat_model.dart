class ChatModel {
  final String id;
  final String user1Id;
  final String user2Id;
  String? lastMessage;
  
  // Nuevas propiedades para la lógica mensaje recibido/no leído
  String? lastMessageSenderId; 
  bool lastMessageRead;        

  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Estas se quedan igual porque lo usamos otras pantallas
  final String? user1Name;
  final String? user1Avatar;
  final String? user2Name;
  final String? user2Avatar;

  ChatModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.lastMessage,
    this.lastMessageSenderId,         
    this.lastMessageRead = true,      
    required this.createdAt,
    required this.updatedAt,
    this.user1Name,
    this.user1Avatar,
    this.user2Name,
    this.user2Avatar,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    // lógica de mapeo de perfiles
    final user1 = json['user1'] as Map<String, dynamic>?;
    final user2 = json['user2'] as Map<String, dynamic>?;

    return ChatModel(
      id: json['id'],
      user1Id: json['user1_id'],
      user2Id: json['user2_id'],
      lastMessage: json['last_message'],
      
      // Leemos los nuevos campos de Supabase
      lastMessageSenderId: json['last_message_sender_id'],
      lastMessageRead: json['last_message_read'] ?? true,

      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      
      // Mantenemos los datos de perfiles que usan tus otras páginas
      user1Name: user1?['full_name'],
      user1Avatar: user1?['avatar_url'],
      user2Name: user2?['full_name'],
      user2Avatar: user2?['avatar_url'],
    );
  }
}