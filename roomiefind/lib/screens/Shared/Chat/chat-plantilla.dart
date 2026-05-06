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
  String otherUserName = "Cargando..."; // Para mostrar el nombre real

  @override
  void initState() {
    super.initState();
    // Usamos addPostFrameCallback para evitar errores de contexto al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<ChatViewModel>(context, listen: false);
      vm.loadMessages(widget.chatId);
      vm.listenToChat(widget.chatId);
      _fetchOtherUserName(); // Buscamos el nombre del otro usuario
    });
  }

  // Método opcional para que la cabecera se vea profesional
  Future<void> _fetchOtherUserName() async {
    final vm = Provider.of<ChatViewModel>(context, listen: false);
    try {
      final res = await vm.supabase
          .from('profiles')
          .select('full_name')
          .eq('id', widget.otherUserId)
          .single();
      setState(() {
        otherUserName = res['full_name'] ?? "Usuario";
      });
    } catch (e) {
      setState(() => otherUserName = "Chat");
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
    final vm = Provider.of<ChatViewModel>(context);

    // Scroll automático al recibir mensajes nuevos
    if (vm.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

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
            const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
            ),
            const SizedBox(width: 10),
            Text(
              otherUserName,
              style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: vm.isLoading && vm.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
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
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
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
                            style: TextStyle(color: isMine ? Colors.white : Colors.black87),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // INPUT BAR
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
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
                        decoration: const InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: const Color(0xFFB82D41),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 20),
                      onPressed: () async {
                        final text = _controller.text.trim();
                        if (text.isEmpty) return;
                        await vm.sendMessage(widget.chatId, text);
                        _controller.clear();
                        _scrollToBottom();
                      },
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
}