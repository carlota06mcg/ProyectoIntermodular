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

  // Modo selección
  bool selectionMode = false;
  Set<String> selectedChats = {};

  StreamSubscription<MessageModel>? _messageSubscription;

  // -------------------------------------------------------------
  // Cargar todos los chats del usuario
  // -------------------------------------------------------------
  Future<void> loadChats() async {
    isLoading = true;
    notifyListeners();

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        chats = await _chatService.getChatsForUser(userId);
      }
    } catch (e) {
      debugPrint("Error al cargar chats: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------------
  // Cargar mensajes de un chat
  // -------------------------------------------------------------
  Future<void> loadMessages(String chatId) async {
    isLoading = true;
    notifyListeners();

    try {
      messages = await _chatService.getMessages(chatId);
    } catch (e) {
      debugPrint("Error al cargar mensajes: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------------
  // Escuchar mensajes en tiempo real
  // -------------------------------------------------------------
  void listenToChat(String chatId) {
    _messageSubscription?.cancel();

    _messageSubscription =
        _chatService.listenToMessages(chatId).listen((newMessage) {
      // Evitar duplicados si el mensaje ya está en la lista (por el insert manual)
      if (!messages.any((m) => m.id == newMessage.id)) {
        messages.add(newMessage);
        notifyListeners();
      }
    });
  }

  // -------------------------------------------------------------
  // Enviar mensaje
  // -------------------------------------------------------------
  Future<void> sendMessage(String chatId, String content) async {
    final senderId = supabase.auth.currentUser?.id;
    if (senderId == null || content.trim().isEmpty) return;

    try {
      await _chatService.sendMessage(chatId, senderId, content);
      // No añadimos el mensaje manualmente aquí porque listenToChat lo hará por nosotros
    } catch (e) {
      debugPrint("Error al enviar mensaje: $e");
    }
  }

// -------------------------------------------------------------
  // Crear chat si no existe
  // -------------------------------------------------------------
  Future<String> createChatWith(String otherUserId) async {
    try {
      final myId = supabase.auth.currentUser?.id;
      if (myId == null) throw Exception("Sesión no iniciada");

      // 1. Llamada al servicio (busca el ID existente o crea uno nuevo)
      final String chatId = await _chatService.createChatIfNotExists(myId, otherUserId);
      
      // 2. Refrescamos la lista de chats para que el usuario lo vea en su bandeja de entrada
      await loadChats(); 
      
      // 3. Devolvemos el ID para que la pantalla de detalles sepa a qué chat navegar
      return chatId;

    } catch (e) {
      debugPrint("Error en createChatWith: $e");
      rethrow;
    }
  }

  // -------------------------------------------------------------
  // MODO SELECCIÓN
  // -------------------------------------------------------------
  void toggleSelectionMode() {
    selectionMode = !selectionMode;
    if (!selectionMode) {
      selectedChats.clear();
    }
    notifyListeners();
  }

  void toggleChatSelection(String chatId) {
    if (selectedChats.contains(chatId)) {
      selectedChats.remove(chatId);
    } else {
      selectedChats.add(chatId);
    }
    notifyListeners();
  }

  // -------------------------------------------------------------
  // BORRAR CHATS SELECCIONADOS
  // -------------------------------------------------------------
  Future<void> deleteSelectedChats() async {
    isLoading = true;
    notifyListeners();

    try {
      for (final chatId in selectedChats) {
        // Primero borrar mensajes (FK constraint) y luego el chat
        await supabase.from('messages').delete().eq('chat_id', chatId);
        await supabase.from('chats').delete().eq('id', chatId);
      }

      selectedChats.clear();
      selectionMode = false;

      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        chats = await _chatService.getChatsForUser(userId);
      }
    } catch (e) {
      debugPrint("Error al borrar chats: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}