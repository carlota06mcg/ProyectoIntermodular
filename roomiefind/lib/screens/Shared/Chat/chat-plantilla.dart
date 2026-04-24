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

  @override
  void initState() {
    super.initState();

    final vm = Provider.of<ChatViewModel>(context, listen: false);

    // Cargar mensajes iniciales
    vm.loadMessages(widget.chatId);

    // Activar realtime
    vm.listenToChat(widget.chatId);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ChatViewModel>(context);

    // Scroll automático cuando llegan mensajes
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // -------------------------------
            // TOP BAR
            // -------------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black87,
                      size: 22,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=200&q=80',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Usuario: ${widget.otherUserId}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.black12),

            // -------------------------------
            // MENSAJES
            // -------------------------------
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: vm.messages.length,
                      itemBuilder: (context, index) {
                        final msg = vm.messages[index];
                        final isMine = msg.senderId ==
                            vm.supabase.auth.currentUser!.id;

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          alignment: isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isMine
                                  ? const Color(0xFFB82D41)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg.content,
                              style: TextStyle(
                                color: isMine ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // -------------------------------
            // INPUT DE MENSAJE
            // -------------------------------
            Padding(
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: 20,
                top: 10,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black12, width: 1.5),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Mensaje...',
                          hintStyle: TextStyle(color: Colors.black38),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 15,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Color(0xFFB82D41),
                      ),
                      onPressed: () async {
                        final text = _controller.text.trim();
                        if (text.isEmpty) return;

                        await vm.sendMessage(widget.chatId, text);
                        _controller.clear();
                        _scrollToBottom();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
