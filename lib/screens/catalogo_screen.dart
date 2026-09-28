import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../services/fake_api_service.dart';
import 'nuevo_producto_screen.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final FakeApiService _apiService = FakeApiService();
  late Future<List<Producto>> _futureProductos;

  @override
  void initState() {
    super.initState();
    _futureProductos = _apiService.obtenerProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StorePro Fake API'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Producto>>(
        future: _futureProductos,
        builder: (context, snapshot) {
          // ESTADO 1: CARGANDO
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ESTADO 2: ERROR DE RED
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar productos: ${snapshot.error}'),
            );
          }

          // ESTADO 3: ÉXITO CON DATOS
          if (snapshot.hasData) {
            final productos = snapshot.data!;
            return ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final prod = productos[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.shopping_bag)),
                  title: Text(prod.nombre),
                  // Se extrae la propiedad del objeto o se convierte a String seguro
                  subtitle: Text(
                    prod.categoria?.nombre ?? prod.categoria?.toString() ?? 'Sin categoría',
                  ),
                  trailing: Text('\$${prod.precio.toStringAsFixed(2)}'),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NuevoProductoScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('AGREGAR NUEVO PRODUCTO'),
        tooltip: 'Agregar nuevo producto',
      ),
    );
  }
}