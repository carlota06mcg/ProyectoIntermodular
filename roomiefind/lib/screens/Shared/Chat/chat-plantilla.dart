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
  String otherUserName = "Usuario"; 

  @override
  void initState() {
    super.initState();
    // Usamos addPostFrameCallback para no bloquear el renderizado inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<ChatViewModel>(context, listen: false);
      
      // 1. Limpiamos mensajes anteriores para que no se vean mensajes del chat anterior
      vm.messages.clear(); 
      
      // 2. Cargamos mensajes de la BD
      vm.loadMessages(widget.chatId);
      
      // 3. Activamos el escucha en tiempo real
      vm.listenToChat(widget.chatId);
      
      // 4. Marcamos como leído
      vm.markChatAsRead(widget.chatId);
      
      _fetchOtherUserName();
    });
  }

  // Liberar recursos al salir
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    // IMPORTANTE: Cancelamos la suscripción al salir para que no gaste datos
    // Esto lo hace el dispose del ViewModel si está bien configurado, 
    // pero asegúrate de que el ViewModel deje de escuchar este chat específico.
    super.dispose();
  }

  Future<void> _fetchOtherUserName() async {
    final vm = Provider.of<ChatViewModel>(context, listen: false);
    try {
      final res = await vm.supabase
          .from('profiles')
          .select('full_name')
          .eq('id', widget.otherUserId)
          .single();
      if (mounted) {
        setState(() {
          otherUserName = res['full_name'] ?? "Usuario";
        });
      }
    } catch (e) {
      if (mounted) setState(() => otherUserName = "Chat");
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para que SOLO se reconstruya lo necesario
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
            child: Consumer<ChatViewModel>(
              builder: (context, vm, child) {
                // Programamos el scroll para el siguiente frame tras el rebuild
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                if (vm.isLoading && vm.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (vm.messages.isEmpty) {
                  return const Center(child: Text("No hay mensajes aún. ¡Saluda!"));
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
                        onSubmitted: (val) => _handleSend(), // Enviar con el 'Enter' del teclado
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
                      onPressed: _handleSend,
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
    
    _controller.clear(); // Limpiamos rápido para mejor sensación
    await vm.sendMessage(widget.chatId, text);
  }
}