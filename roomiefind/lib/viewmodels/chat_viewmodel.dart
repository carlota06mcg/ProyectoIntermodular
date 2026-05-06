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
// -------------------------------------------------------------
  // Escuchar mensajes en tiempo real (con filtro anti-duplicados)
  // -------------------------------------------------------------
  void listenToChat(String chatId) {
    _messageSubscription?.cancel();

    _messageSubscription =
        _chatService.listenToMessages(chatId).listen((newMessage) {
      
      // 1. Buscamos si este mensaje ya lo pintamos nosotros mismos como temporal
      int tempIndex = messages.indexWhere((m) => 
          m.id.startsWith('temp_') && 
          m.content == newMessage.content && 
          m.senderId == newMessage.senderId);

      if (tempIndex != -1) {
        // Si era nuestro mensaje temporal, lo sustituimos por el oficial (que trae el ID real de Supabase)
        messages[tempIndex] = newMessage;
        notifyListeners();
      } else if (!messages.any((m) => m.id == newMessage.id)) {
        // Si no es nuestro mensaje temporal y no existe en la lista (ej: nos escribe la otra persona), lo añadimos
        messages.add(newMessage);
        notifyListeners();
      }
    });
  }

  // -------------------------------------------------------------
  // Enviar mensaje
  // -------------------------------------------------------------
// -------------------------------------------------------------
  // Enviar mensaje (con Optimistic UI / Mensaje Instantáneo)
  // -------------------------------------------------------------
  Future<void> sendMessage(String chatId, String content) async {
    final senderId = supabase.auth.currentUser?.id;
    if (senderId == null || content.trim().isEmpty) return;

    // 1. Creamos el mensaje temporal para la interfaz
    final temporaryMessage = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // ID reconocible como temporal
      chatId: chatId,
      senderId: senderId,
      content: content,
      isRead: false, // <-- Resuelto el error del parámetro requerido
      createdAt: DateTime.now(),
    );

    // 2. Lo añadimos a la lista local y repintamos la pantalla AL INSTANTE
    messages.add(temporaryMessage);
    notifyListeners();

    try {
      // 3. Lo enviamos silenciosamente a Supabase en segundo plano
      await _chatService.sendMessage(chatId, senderId, content);
    } catch (e) {
      // Si falla internet o la base de datos, lo borramos de la pantalla
      messages.removeWhere((m) => m.id == temporaryMessage.id);
      notifyListeners();
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