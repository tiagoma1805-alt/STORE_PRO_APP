import 'package:flutter/material.dart';
import '../models/categoria.dart';
import '../services/categoria_service.dart';
import '../services/producto_service.dart';

class NuevoProductoScreen extends StatefulWidget {
  const NuevoProductoScreen({super.key});

  @override
  State<NuevoProductoScreen> createState() => _NuevoProductoScreenState();
}

class _NuevoProductoScreenState extends State<NuevoProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductoService _productoService = ProductoService();
  final CategoriaService _categoriaService = CategoriaService();

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _precioCtrl = TextEditingController();
  final TextEditingController _stockCtrl = TextEditingController();

  late Future<List<Categoria>> _futureCategorias;
  int? _categoriaSeleccionada;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _futureCategorias = _categoriaService.getCategorias();
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    if (_categoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría')),
      );
      return;
    }

    setState(() => _guardando = true);

    final exito = await _productoService.crearProducto(
      _nombreCtrl.text.trim(),
      double.tryParse(_precioCtrl.text.trim()) ?? 0.0,
      int.tryParse(_stockCtrl.text.trim()) ?? 0,
      _categoriaSeleccionada!,
    );

    if (!mounted) return;
    setState(() => _guardando = false);

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto creado correctamente ✅')),
      );
      Navigator.pop(context, true); // avisa a la pantalla anterior que refresque
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo crear el producto')),
      );
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Producto')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre del producto',
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _precioCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Precio',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) return 'El precio es obligatorio';
                if (double.tryParse(valor.trim()) == null) return 'Precio inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Stock (unidades)',
                prefixIcon: Icon(Icons.inventory_2),
                border: OutlineInputBorder(),
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) return 'El stock es obligatorio';
                if (int.tryParse(valor.trim()) == null) return 'Stock inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Selector de categoría, cargado de forma asíncrona desde el backend
            FutureBuilder<List<Categoria>>(
              future: _futureCategorias,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No hay categorías disponibles. Crea una primero.');
                }

                // Solo mostramos categorías activas: no tiene sentido asignar
                // un producto nuevo a una categoría que está desactivada
                final categorias = snapshot.data!.where((cat) => cat.estado == true).toList();

                if (categorias.isEmpty) {
                  return const Text('No hay categorías activas disponibles. Activa alguna primero.');
                }

                return DropdownButtonFormField<int>(
                  initialValue: _categoriaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: categorias.map((cat) {
                    return DropdownMenuItem(value: cat.id, child: Text(cat.nombre));
                  }).toList(),
                  onChanged: (valor) => setState(() => _categoriaSeleccionada = valor),
                );
              },
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _guardando ? null : _guardarProducto,
              icon: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
              label: Text(_guardando ? 'Guardando...' : 'GUARDAR PRODUCTO'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}