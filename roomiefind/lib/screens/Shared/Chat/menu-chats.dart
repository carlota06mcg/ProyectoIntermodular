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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ChatViewModel>(context, listen: false).loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ChatViewModel>(context);
    final supabase = Supabase.instance.client;
    final myId = supabase.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: Colors.white,

      // -------------------------------
      // APPBAR DINÁMICO
      // -------------------------------
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
            ? Text(
                "${vm.selectedChats.length} seleccionados",
                style: const TextStyle(color: Colors.black),
              )
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
                  : () async {
                      await vm.deleteSelectedChats();
                    },
            ),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Línea decorativa
            if (!vm.selectionMode)
              Container(
                width: 30,
                height: 2,
                color: const Color(0xFFB82D41),
              ),

            const SizedBox(height: 20),

            // Barra de búsqueda (decorativa)
            if (!vm.selectionMode)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  height: 45,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar',
                      hintStyle: const TextStyle(
                        color: Colors.black26,
                        fontSize: 15,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black26,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFB82D41),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFFB82D41),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // -------------------------------
            // LISTA DE CHATS
            // -------------------------------
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vm.chats.isEmpty
                      ? const Center(
                          child: Text(
                            "No tienes chats todavía",
                            style: TextStyle(color: Colors.black45),
                          ),
                        )
                      : ListView.builder(
                          itemCount: vm.chats.length,
                          itemBuilder: (context, index) {
                            final chat = vm.chats[index];

                            // Determinar el otro usuario
                            final isUser1 = chat.user1Id == myId;
                            final otherName =
                                isUser1 ? chat.user2Name : chat.user1Name;
                            final otherAvatar =
                                isUser1 ? chat.user2Avatar : chat.user1Avatar;
                            final otherUserId =
                                isUser1 ? chat.user2Id : chat.user1Id;

                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 4,
                                  ),

                                  // -------------------------------
                                  // LEADING: Checkbox o Avatar
                                  // -------------------------------
                                  leading: vm.selectionMode
                                      ? Checkbox(
                                          value: vm.selectedChats
                                              .contains(chat.id),
                                          onChanged: (_) => vm
                                              .toggleChatSelection(chat.id),
                                        )
                                      : CircleAvatar(
                                          radius: 26,
                                          backgroundImage:
                                              (otherAvatar != null &&
                                                      otherAvatar.isNotEmpty)
                                                  ? NetworkImage(otherAvatar)
                                                  : null,
                                          child: (otherAvatar == null ||
                                                  otherAvatar.isEmpty)
                                              ? Text(
                                                  (otherName != null &&
                                                          otherName.isNotEmpty)
                                                      ? otherName[0]
                                                          .toUpperCase()
                                                      : "?",
                                                  style: const TextStyle(
                                                      fontSize: 18),
                                                )
                                              : null,
                                        ),

                                  // -------------------------------
                                  // NOMBRE DEL OTRO USUARIO
                                  // -------------------------------
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
                                    style: const TextStyle(
                                      color: Colors.black45,
                                      fontSize: 13,
                                    ),
                                  ),

                                  trailing: !vm.selectionMode
                                      ? const Icon(
                                          Icons.chat_bubble_outline,
                                          color: Colors.black87,
                                        )
                                      : null,

                                  // -------------------------------
                                  // TAP NORMAL / TAP EN SELECCIÓN
                                  // -------------------------------
                                  onTap: vm.selectionMode
                                      ? () => vm
                                          .toggleChatSelection(chat.id)
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatPlantillaScreen(
                                                chatId: chat.id,
                                                otherUserId: otherUserId,
                                              ),
                                            ),
                                          );
                                        },

                                  // -------------------------------
                                  // LONG PRESS → ACTIVAR SELECCIÓN
                                  // -------------------------------
                                  onLongPress: () {
                                    if (!vm.selectionMode) {
                                      vm.toggleSelectionMode();
                                      vm.toggleChatSelection(chat.id);
                                    }
                                  },
                                ),

                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Divider(
                                    color: Colors.black12,
                                    height: 1,
                                  ),
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
