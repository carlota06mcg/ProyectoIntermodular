import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roomiefind/models/chat_model.dart';
import 'package:roomiefind/models/message_model.dart';
import 'dart:async';

class ChatService {
  final supabase = Supabase.instance.client;

  // -------------------------------------------------------------
  // 1. Crear chat si no existe (entre user1 y user2)
  // -------------------------------------------------------------
  Future<String> createChatIfNotExists(String user1Id, String user2Id) async {
    final existing = await supabase
        .from('chats')
        .select()
        .or('user1_id.eq.$user1Id,user2_id.eq.$user2Id')
        .or('user1_id.eq.$user2Id,user2_id.eq.$user1Id')
        .maybeSingle();

    if (existing != null) {
      return existing['id'];
    }

    final newChat = await supabase.from('chats').insert({
      'user1_id': user1Id,
      'user2_id': user2Id,
    }).select().single();

    return newChat['id'];
  }

  // -------------------------------------------------------------
  // 2. Obtener todos los chats del usuario
  // -------------------------------------------------------------
  Future<List<ChatModel>> getChatsForUser(String userId) async {
    final data = await supabase
        .from('chats')
        .select()
        .or('user1_id.eq.$userId,user2_id.eq.$userId')
        .order('updated_at', ascending: false);

    return data.map((e) => ChatModel.fromJson(e)).toList();
  }

  // -------------------------------------------------------------
  // 3. Obtener mensajes de un chat
  // -------------------------------------------------------------
  Future<List<MessageModel>> getMessages(String chatId) async {
    final data = await supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);

    return data.map((e) => MessageModel.fromJson(e)).toList();
  }

  // -------------------------------------------------------------
  // 4. Enviar mensaje
  // -------------------------------------------------------------
  Future<void> sendMessage(String chatId, String senderId, String content) async {
    await supabase.from('messages').insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
    });

    // Actualizar last_message en chats
    await supabase.from('chats').update({
      'last_message': content,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', chatId);
  }

  // -------------------------------------------------------------
  // 5. Escuchar mensajes en tiempo real
  // -------------------------------------------------------------
Stream<MessageModel> listenToMessages(String chatId) {
  final channel = supabase.channel('messages_channel_$chatId');

  final streamController = StreamController<MessageModel>();

  channel.onPostgresChanges(
    event: PostgresChangeEvent.insert,
    schema: 'public',
    table: 'messages',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'chat_id',
      value: chatId,
    ),
    callback: (payload) {
      final newMessage = MessageModel.fromJson(payload.newRecord!);
      streamController.add(newMessage);
    },
  ).subscribe();

  return streamController.stream;
}

}
