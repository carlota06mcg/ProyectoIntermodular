import 'package:flutter/material.dart';
import 'chat-plantilla.dart';

class MenuChatsScreen extends StatelessWidget {
  const MenuChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            
            // Search Bar
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
            
            // Chat List
            Expanded(
              child: ListView.builder(
                itemCount: 1, // Placeholder para un chat
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, 
                          vertical: 4,
                        ),
                        leading: const CircleAvatar(
                          radius: 26,
                          // Imagen de placeholder parecida a la de la foto
                          backgroundImage: NetworkImage(
                              'https://images.unsplash.com/photo-1555066931-4365d14bab8c?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80'),
                        ),
                        title: const Text(
                          'Student Experience',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: const Text(
                          'Activo hace 11 minutos',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 13,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.phone_outlined,
                          color: Colors.black87,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatPlantillaScreen(),
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
