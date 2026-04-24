import 'dart:async';
import 'package:flutter/material.dart';
import 'package:roomiefind/models/chat_model.dart';
import 'package:roomiefind/models/message_model.dart';
import 'package:roomiefind/services/chat_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final supabase = Supabase.instance.client;

  // Estado
  List<ChatModel> chats = [];
  List<MessageModel> messages = [];
  bool isLoading = false;

  StreamSubscription<MessageModel>? _messageSubscription;

  // -------------------------------------------------------------
  // Cargar todos los chats del usuario
  // -------------------------------------------------------------
  Future<void> loadChats() async {
    isLoading = true;
    notifyListeners();

    final userId = supabase.auth.currentUser!.id;

    chats = await _chatService.getChatsForUser(userId);

    isLoading = false;
    notifyListeners();
  }

  // -------------------------------------------------------------
  // Cargar mensajes de un chat
  // -------------------------------------------------------------
  Future<void> loadMessages(String chatId) async {
    isLoading = true;
    notifyListeners();

    messages = await _chatService.getMessages(chatId);

    isLoading = false;
    notifyListeners();
  }

  // -------------------------------------------------------------
  // Escuchar mensajes en tiempo real
  // -------------------------------------------------------------
  void listenToChat(String chatId) {
    // Cancelar suscripción previa si existe
    _messageSubscription?.cancel();

    _messageSubscription =
        _chatService.listenToMessages(chatId).listen((newMessage) {
      messages.add(newMessage);
      notifyListeners();
    });
  }

  // -------------------------------------------------------------
  // Enviar mensaje
  // -------------------------------------------------------------
  Future<void> sendMessage(String chatId, String content) async {
    final senderId = supabase.auth.currentUser!.id;

    if (content.trim().isEmpty) return;

    await _chatService.sendMessage(chatId, senderId, content);
  }

  // -------------------------------------------------------------
  // Crear chat si no existe y devolver su ID
  // -------------------------------------------------------------
  Future<String> createChatWith(String otherUserId) async {
    final myId = supabase.auth.currentUser!.id;
    return await _chatService.createChatIfNotExists(myId, otherUserId);
  }

  // -------------------------------------------------------------
  // Limpiar suscripción al cerrar pantalla
  // -------------------------------------------------------------
  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
