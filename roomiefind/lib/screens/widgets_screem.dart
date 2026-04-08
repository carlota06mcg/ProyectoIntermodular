import 'package:flutter/material.dart';

void main() => runApp(const MiApp());

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: const PantallaPrincipal(),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _indiceActual = 4; // Empezamos en Favoritos (índice 4)

  // Aquí defines qué "página" se carga según el botón
  final List<Widget> _paginas = [
    const Center(child: Text("Página Home")),
    const Center(child: Text("Página Chat")),
    const Center(child: Text("Página Búsqueda")),
    const Center(child: Text("Página Recientes")),
    const FavoritosPage(), // La página de tu captura
    const Center(child: Text("Página Perfil")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El body cambia dinámicamente según el botón pulsado
      body: _paginas[_indiceActual],

      // La barra de navegación persistente
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF3E5D8), // El color crema de tu imagen
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent, // Usamos el color del contenedor
          elevation: 0,
          currentIndex: _indiceActual,
          selectedItemColor: Colors.redAccent,
          unselectedItemColor: Colors.black45,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: (index) {
            setState(() {
              _indiceActual = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.send_outlined), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}

// Ejemplo de la página de Favoritos
class FavoritosPage extends StatelessWidget {
  const FavoritosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Favoritos",
          style: TextStyle(
            color: Color(0xFFB71C1C),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: const Center(child: Text("Contenido de Favoritos")),
    );
  }
}
