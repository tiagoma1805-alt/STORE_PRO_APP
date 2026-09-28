import 'package:flutter/material.dart';
import 'categorias_screen.dart';
import 'productos_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _indiceSeleccionado = 0;

  // Las dos páginas principales
  final List<Widget> _pantallas = const [
    CategoriasScreen(),
    ProductosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_indiceSeleccionado],
      // Barra de botones en la parte inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceSeleccionado,
        onTap: (index) {
          setState(() {
            _indiceSeleccionado = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorías',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),
        ],
      ),
    );
  }
}