import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roomiefind/viewmodels/chat_viewmodel.dart';
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
    // Cargar chats al abrir la pantalla
    Future.microtask(() {
      Provider.of<ChatViewModel>(context, listen: false).loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<ChatViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Title
            const Text(
              'Mis Chats',
              style: TextStyle(
                color: Color(0xFFB82D41),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Small underline
            Container(
              width: 30,
              height: 2,
              color: const Color(0xFFB82D41),
            ),
            const SizedBox(height: 20),

            // Search Bar (decorativo por ahora)
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
                            final myId = vm.supabase.auth.currentUser!.id;
                            final otherUserId = chat.user1Id == myId
                                ? chat.user2Id
                                : chat.user1Id;

                            return Column(
                              children: [
                                ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 4,
                                  ),
                                  leading: const CircleAvatar(
                                    radius: 26,
                                    backgroundImage: NetworkImage(
                                      'https://images.unsplash.com/photo-1555066931-4365d14bab8c?auto=format&fit=crop&w=200&q=80',
                                    ),
                                  ),
                                  title: Text(
                                    "Usuario: $otherUserId",
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
                                  trailing: const Icon(
                                    Icons.chat_bubble_outline,
                                    color: Colors.black87,
                                  ),
                                  onTap: () {
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
