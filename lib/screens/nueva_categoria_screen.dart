import 'package:flutter/material.dart';
import '../services/categoria_service.dart';

class NuevaCategoriaScreen extends StatefulWidget {
  const NuevaCategoriaScreen({super.key});

  @override
  State<NuevaCategoriaScreen> createState() => _NuevaCategoriaScreenState();
}

class _NuevaCategoriaScreenState extends State<NuevaCategoriaScreen> {
  final _formKey = GlobalKey<FormState>();
  final CategoriaService _service = CategoriaService();

  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _descripcionCtrl = TextEditingController();

  bool _guardando = false;

  Future<void> _guardarCategoria() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final exito = await _service.crearCategoria(
      _nombreCtrl.text.trim(),
      _descripcionCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _guardando = false);

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoría creada correctamente ✅')),
      );
      Navigator.pop(context, true); // avisa a la pantalla anterior que refresque
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo crear la categoría')),
      );
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Categoría')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre',
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
              controller: _descripcionCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'La descripción es obligatoria';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _guardando ? null : _guardarCategoria,
              icon: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
              label: Text(_guardando ? 'Guardando...' : 'GUARDAR CATEGORÍA'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}