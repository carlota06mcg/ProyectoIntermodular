import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/viewmodels/chat_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat-plantilla.dart';

class MenuChatsScreen extends StatefulWidget {
  const MenuChatsScreen({super.key});

  @override
  State<MenuChatsScreen> createState() => _MenuChatsScreenState();
}

class _MenuChatsScreenState extends State<MenuChatsScreen> {
  // En tu pantalla de lista de chats (el menú)
@override
void initState() {
  super.initState();
  // Usamos microtask para asegurarnos de que el context esté listo
  Future.microtask(() {
    final vm = Provider.of<ChatViewModel>(context, listen: false);
    vm.loadChats();           // Carga inicial rápida
    vm.listenToAllChats();    // Se queda escuchando cambios en vivo
  });
}

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ChatViewModel>(context);
    final supabase = Supabase.instance.client;
    final myId = supabase.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: vm.selectionMode
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => vm.toggleSelectionMode(),
              )
            : null,
        title: vm.selectionMode
            ? Text("${vm.selectedChats.length} seleccionados",
                style: const TextStyle(color: Colors.black))
            : const Text(
                "Mis Chats",
                style: TextStyle(
                  color: Color(0xFFB82D41),
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          if (vm.selectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.black),
              onPressed: vm.selectedChats.isEmpty
                  ? null
                  : () async => await vm.deleteSelectedChats(),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            if (!vm.selectionMode)
              Container(width: 30, height: 2, color: const Color(0xFFB82D41)),

            const SizedBox(height: 20),

            // Barra de búsqueda
            if (!vm.selectionMode)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar',
                      hintStyle: const TextStyle(color: Colors.black26, fontSize: 15),
                      prefixIcon: const Icon(Icons.search, color: Colors.black26),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFB82D41)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFB82D41), width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.chats.isEmpty
                      ? const Center(child: Text("No tienes chats todavía", style: TextStyle(color: Colors.black45)))
                      : ListView.builder(
                          itemCount: vm.chats.length,
                          itemBuilder: (context, index) {
                            final chat = vm.chats[index];
                            final isUser1 = chat.user1Id == myId;
                            final otherName = isUser1 ? chat.user2Name : chat.user1Name;
                            final otherAvatar = isUser1 ? chat.user2Avatar : chat.user1Avatar;
                            final otherUserId = isUser1 ? chat.user2Id : chat.user1Id;

                            // --- LÓGICA DE MENSAJE NO LEÍDO ---
                            // Es unread si: NO está leído Y el último mensaje NO lo envié yo.
                            final bool isUnread = !chat.lastMessageRead && chat.lastMessageSenderId != myId;

                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                  leading: vm.selectionMode
                                      ? Checkbox(
                                          value: vm.selectedChats.contains(chat.id),
                                          onChanged: (_) => vm.toggleChatSelection(chat.id),
                                        )
                                      : CircleAvatar(
                                          radius: 26,
                                          backgroundImage: (otherAvatar != null && otherAvatar.isNotEmpty)
                                              ? NetworkImage(otherAvatar)
                                              : null,
                                          child: (otherAvatar == null || otherAvatar.isEmpty)
                                              ? Text(otherName?[0].toUpperCase() ?? "?")
                                              : null,
                                        ),
                                  title: Text(
                                    otherName ?? "Usuario",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    chat.lastMessage ?? "Sin mensajes aún",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      // Cambio de estilo si no está leído
                                      color: isUnread ? Colors.black : Colors.black45,
                                      fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                  trailing: !vm.selectionMode
                                      ? (isUnread 
                                          ? Container(
                                              width: 12,
                                              height: 12,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFB82D41), // Tu color rojo
                                                shape: BoxShape.circle,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.chat_bubble_outline,
                                              color: Colors.black12,
                                              size: 20,
                                            ))
                                      : null,
                                  onTap: vm.selectionMode
                                      ? () => vm.toggleChatSelection(chat.id)
                                      : () {
                                          // 1. Al entrar al chat, marcamos como leído localmente y en BD
                                          vm.markChatAsRead(chat.id);

                                          // 2. Navegamos a la pantalla de mensajes
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChatPlantillaScreen(
                                                chatId: chat.id,
                                                otherUserId: otherUserId!,
                                              ),
                                            ),
                                          );
                                        },
                                  onLongPress: () {
                                    if (!vm.selectionMode) {
                                      vm.toggleSelectionMode();
                                      vm.toggleChatSelection(chat.id);
                                    }
                                  },
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Divider(color: Colors.black12, height: 1),
                                ),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}