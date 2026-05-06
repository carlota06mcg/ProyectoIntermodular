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

  // Suscripciones para tiempo real
  StreamSubscription<MessageModel>? _messageSubscription;
  StreamSubscription? _chatsSubscription;

  // -------------------------------------------------------------
  // ESCUCHAR TODOS LOS CHATS (Para que el menú suba y baje solo)
  // -------------------------------------------------------------
void listenToAllChats() {
  final myId = supabase.auth.currentUser?.id;
  if (myId == null) return;

  _chatsSubscription?.cancel();

  // Escuchamos la tabla 'chats' en tiempo real
  _chatsSubscription = supabase
      .from('chats')
      .stream(primaryKey: ['id'])
      .listen((List<Map<String, dynamic>> data) async {
        // En lugar de usar 'data' directamente (que no tiene los nombres/fotos),
        // refrescamos la lista completa con el Service cada vez que algo cambie.
        final updatedChats = await _chatService.getChatsForUser(myId);
        chats = updatedChats;
        notifyListeners(); 
      });
}

  // -------------------------------------------------------------
  // CREAR O BUSCAR CHAT (Para el botón Contactar Ahora)
  // -------------------------------------------------------------
  Future<String> createChatWith(String otherUserId) async {
    try {
      final myId = supabase.auth.currentUser?.id;
      if (myId == null) throw Exception("Sesión no iniciada");

      // Llamamos al servicio que ya tiene la lógica de:
      // "Si existe, devuélvelo; si no, créalo".
      final String chatId = await _chatService.createChatIfNotExists(myId, otherUserId);
      
      // Cargamos los chats de nuevo para que el nuevo aparezca en la lista
      await loadChats(); 
      
      return chatId;
    } catch (e) {
      debugPrint("Error en createChatWith: $e");
      rethrow;
    }
  }

  // -------------------------------------------------------------
  // CARGAR CHATS (Carga inicial)
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
  // MARCAR COMO LEÍDO
  // -------------------------------------------------------------
  Future<void> markChatAsRead(String chatId) async {
    final myId = supabase.auth.currentUser?.id;
    if (myId == null) return;

    try {
      final index = chats.indexWhere((c) => c.id == chatId);
      if (index != -1) {
        // Solo marcamos como leído si el último mensaje no lo enviamos nosotros
        // y si actualmente figura como no leído.
        if (chats[index].lastMessageSenderId != myId && chats[index].lastMessageRead == false) {
          // Cambio local instantáneo (Optimistic)
          chats[index].lastMessageRead = true;
          notifyListeners();

          // Cambio en base de datos
          await _chatService.markAsRead(chatId, myId);
        }
      }
    } catch (e) {
      debugPrint("Error al marcar como leído: $e");
    }
  }

  // -------------------------------------------------------------
  // ENVIAR MENSAJE
  // -------------------------------------------------------------
  Future<void> sendMessage(String chatId, String content) async {
    final senderId = supabase.auth.currentUser?.id;
    if (senderId == null || content.trim().isEmpty) return;

    final temporaryMessage = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}', 
      chatId: chatId, // Ajustado a tu MessageModel si usa snake_case
      senderId: senderId,
      content: content,
      isRead: false, 
      createdAt: DateTime.now(),
    );

    // Optimismo: añadimos el mensaje a la lista y subimos el chat al principio
    messages.add(temporaryMessage);
    
    final chatIndex = chats.indexWhere((c) => c.id == chatId);
    if (chatIndex != -1) {
      chats[chatIndex].lastMessage = content;
      chats[chatIndex].lastMessageSenderId = senderId;
      chats[chatIndex].lastMessageRead = false;
      
      final updatedChat = chats.removeAt(chatIndex);
      chats.insert(0, updatedChat);
    }
    
    notifyListeners();

    try {
      await _chatService.sendMessage(chatId, senderId, content);
    } catch (e) {
      messages.removeWhere((m) => m.id == temporaryMessage.id);
      notifyListeners();
      debugPrint("Error al enviar mensaje: $e");
    }
  }

  // -------------------------------------------------------------
  // CARGAR MENSAJES E INDIVIDUALES
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

  void listenToChat(String chatId) {
    _messageSubscription?.cancel();
    _messageSubscription = _chatService.listenToMessages(chatId).listen((newMessage) {
      int tempIndex = messages.indexWhere((m) => 
          m.id.startsWith('temp_') && 
          m.content == newMessage.content && 
          m.senderId == newMessage.senderId);

      if (tempIndex != -1) {
        messages[tempIndex] = newMessage;
        notifyListeners();
      } else if (!messages.any((m) => m.id == newMessage.id)) {
        messages.add(newMessage);
        notifyListeners();
      }
    });
  }

  // -------------------------------------------------------------
  // SELECCIÓN Y BORRADO
  // -------------------------------------------------------------
  void toggleSelectionMode() {
    selectionMode = !selectionMode;
    if (!selectionMode) selectedChats.clear();
    notifyListeners();
  }

  void toggleChatSelection(String chatId) {
    selectedChats.contains(chatId) ? selectedChats.remove(chatId) : selectedChats.add(chatId);
    notifyListeners();
  }

  Future<void> deleteSelectedChats() async {
    isLoading = true;
    notifyListeners();
    try {
      for (final chatId in selectedChats) {
        await supabase.from('messages').delete().eq('chat_id', chatId);
        await supabase.from('chats').delete().eq('id', chatId);
      }
      selectedChats.clear();
      selectionMode = false;
      await loadChats();
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
    _chatsSubscription?.cancel();
    super.dispose();
  }
}