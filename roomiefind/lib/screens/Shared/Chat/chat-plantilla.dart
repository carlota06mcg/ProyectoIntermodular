import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/viewmodels/chat_viewmodel.dart';

class ChatPlantillaScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;

  const ChatPlantillaScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
  });

  @override
  State<ChatPlantillaScreen> createState() => _ChatPlantillaScreenState();
}

class _ChatPlantillaScreenState extends State<ChatPlantillaScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Variables para los datos del otro usuario
  String otherUserName = "Usuario";
  String? otherUserAvatarUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<ChatViewModel>(context, listen: false);
      
      // 1. Limpiar mensajes anteriores
      vm.messages.clear(); 
      
      // 2. Cargar mensajes de la BD
      vm.loadMessages(widget.chatId);
      
      // 3. Activar tiempo real
      vm.listenToChat(widget.chatId);
      
      // 4. Marcar como leído
      vm.markChatAsRead(widget.chatId);
      
      // 5. Cargar nombre y foto del otro usuario
      _fetchOtherUserData();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchOtherUserData() async {
    final vm = Provider.of<ChatViewModel>(context, listen: false);
    try {
      final res = await vm.supabase
          .from('profiles')
          .select('full_name, avatar_url')
          .eq('id', widget.otherUserId)
          .single();
          
      if (mounted) {
        setState(() {
          otherUserName = res['full_name'] ?? "Usuario";
          otherUserAvatarUrl = res['avatar_url'];
        });
      }
    } catch (e) {
      if (mounted) setState(() => otherUserName = "Chat");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: (otherUserAvatarUrl != null && otherUserAvatarUrl!.isNotEmpty)
                  ? NetworkImage(otherUserAvatarUrl!)
                  : null,
              child: (otherUserAvatarUrl == null || otherUserAvatarUrl!.isEmpty)
                  ? const Icon(Icons.person, color: Colors.grey, size: 20)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              otherUserName,
              style: const TextStyle(
                color: Colors.black87, 
                fontSize: 16, 
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatViewModel>(
              builder: (context, vm, child) {
                // Scroll automático al recibir mensajes
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                if (vm.isLoading && vm.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (vm.messages.isEmpty) {
                  return const Center(
                    child: Text("No hay mensajes aún. ¡Saluda!", 
                    style: TextStyle(color: Colors.grey))
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: vm.messages.length,
                  itemBuilder: (context, index) {
                    final msg = vm.messages[index];
                    final isMine = msg.senderId == vm.supabase.auth.currentUser!.id;

                    return Align(
                      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75
                        ),
                        decoration: BoxDecoration(
                          color: isMine ? const Color(0xFFB82D41) : Colors.grey.shade200,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            topRight: const Radius.circular(15),
                            bottomLeft: Radius.circular(isMine ? 15 : 0),
                            bottomRight: Radius.circular(isMine ? 0 : 15),
                          ),
                        ),
                        child: Text(
                          msg.content,
                          style: TextStyle(
                            color: isMine ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // BARRA DE ENTRADA DE TEXTO
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), 
                  blurRadius: 10, 
                  offset: const Offset(0, -2)
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _controller,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (val) => _handleSend(),
                        decoration: const InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _handleSend,
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFFB82D41),
                      radius: 22,
                      child: Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend() async {
    final vm = Provider.of<ChatViewModel>(context, listen: false);
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    _controller.clear(); 
    await vm.sendMessage(widget.chatId, text);
  }
}