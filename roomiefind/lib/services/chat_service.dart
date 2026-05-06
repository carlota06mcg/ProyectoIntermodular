import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roomiefind/models/chat_model.dart';
import 'package:roomiefind/models/message_model.dart';
import 'dart:async';

class ChatService {
  final supabase = Supabase.instance.client;

  // -------------------------------------------------------------
  // 1. Crear chat si no existe
  // -------------------------------------------------------------
  Future<String> createChatIfNotExists(String myId, String otherUserId) async {
    final existing = await supabase
        .from('chats')
        .select()
        .or('and(user1_id.eq.$myId,user2_id.eq.$otherUserId),and(user1_id.eq.$otherUserId,user2_id.eq.$myId)')
        .maybeSingle();

    if (existing != null) {
      return existing['id'];
    }

    final profile = await supabase
        .from('profiles')
        .select('role')
        .eq('id', myId)
        .single();

    final myRole = profile['role'];
    String user1 = (myRole == 'estudiante') ? myId : otherUserId;
    String user2 = (myRole == 'estudiante') ? otherUserId : myId;

    final newChat = await supabase.from('chats').insert({
      'user1_id': user1,
      'user2_id': user2,
      'last_message': 'Chat iniciado',
      'last_message_read': true, // Al inicio está "leído" porque no hay mensajes
    }).select().single();

    return newChat['id'];
  }

  // -------------------------------------------------------------
  // 2. Obtener todos los chats (CON NUEVOS CAMPOS)
  // -------------------------------------------------------------
  Future<List<ChatModel>> getChatsForUser(String userId) async {
    final data = await supabase
        .from('chats')
        .select('''
          id,
          user1_id,
          user2_id,
          last_message,
          last_message_sender_id,
          last_message_read,
          created_at,
          updated_at,
          user1:profiles!chats_user1_id_fkey(full_name, avatar_url),
          user2:profiles!chats_user2_id_fkey(full_name, avatar_url)
        ''')
        .or('user1_id.eq.$userId,user2_id.eq.$userId')
        .order('updated_at', ascending: false);

    return data.map((e) => ChatModel.fromJson(e)).toList();
  }

  // -------------------------------------------------------------
  // 3. Marcar como leído (NUEVO)
  // -------------------------------------------------------------
  Future<void> markAsRead(String chatId, String myId) async {
    // Marcamos que el último mensaje ha sido leído 
    // SOLO si el último que escribió NO fui yo.
    await supabase.from('chats').update({
      'last_message_read': true,
    }).match({
      'id': chatId,
    }).neq('last_message_sender_id', myId);

    // También actualizamos los mensajes individuales
    await supabase.from('messages').update({
      'is_read': true,
    }).match({
      'chat_id': chatId,
    }).neq('sender_id', myId);
  }

  // -------------------------------------------------------------
  // 4. Obtener mensajes de un chat
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
  // 5. Enviar mensaje (ACTUALIZADO)
  // -------------------------------------------------------------
  Future<void> sendMessage(String chatId, String senderId, String content) async {
    // Insertar el mensaje
    await supabase.from('messages').insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'is_read': false,
    });

    // Actualizar el resumen del chat para la lista de chats
    await supabase.from('chats').update({
      'last_message': content,
      'last_message_sender_id': senderId,
      'last_message_read': false, // Al enviar, marcamos como "No leído" para el otro
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', chatId);
  }

// -------------------------------------------------------------
  // 6. Escuchar mensajes en tiempo real corregido y robusto)
  // -------------------------------------------------------------
  Stream<MessageModel> listenToMessages(String chatId) {
    // Usamos un StreamController.broadcast para que varios widgets 
    // puedan escuchar si fuera necesario.
    final streamController = StreamController<MessageModel>.broadcast();

    final channel = supabase
        .channel('chat_$chatId') // Un nombre único para el canal
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: chatId,
          ),
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              final newMessage = MessageModel.fromJson(payload.newRecord);
              streamController.add(newMessage);
            }
          },
        )
        .subscribe();

    // Cuando el stream se cierra (cuando dejas de escuchar), cerramos el canal de Supabase
    streamController.onCancel = () {
      supabase.removeChannel(channel);
      streamController.close();
    };

    return streamController.stream;
  }
}