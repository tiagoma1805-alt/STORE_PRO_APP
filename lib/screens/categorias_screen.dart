import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/categoria.dart';
import '../services/categoria_service.dart';
import '../widgets/role_guard_widget.dart';
import '../widgets/offline_banner.dart';
import 'perfil_screen.dart';
import 'productos_screen.dart';
import 'nueva_categoria_screen.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final CategoriaService _service = CategoriaService();

  List<Categoria> _todasLasCategorias = [];
  List<Categoria> _categoriasFiltradas = [];

  bool _isLoading = true;
  String _errorMsg = '';

  String _searchQuery = '';
  String _filtroEstado = 'TODOS'; // TODOS, ACTIVOS, INACTIVOS

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    setState(() {
      _isLoading = true;
      _errorMsg = '';
    });

    try {
      final lista = await _service.getCategorias();
      setState(() {
        _todasLasCategorias = lista;
        _aplicarFiltros();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Error al conectar con la API: $e';
        _isLoading = false;
      });
    }
  }

  void _aplicarFiltros() {
    setState(() {
      _categoriasFiltradas = _todasLasCategorias.where((cat) {
        final cumpleNombre = cat.nombre.toLowerCase().contains(_searchQuery.toLowerCase());

        bool cumpleEstado = true;
        if (_filtroEstado == 'ACTIVOS') cumpleEstado = cat.estado == true;
        if (_filtroEstado == 'INACTIVOS') cumpleEstado = cat.estado == false;

        return cumpleNombre && cumpleEstado;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return OfflineBannerWidget(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categorías'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _cargarCategorias,
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PerfilScreen())),
            ),
            IconButton(
              icon: const Icon(Icons.inventory_2),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductosScreen())),
            ),
          ],
        ),

        // Solo el Admin ve este botón para crear categorías
        floatingActionButton: RoleGuardWidget(
          allowedRoles: const ['admin'],
          child: FloatingActionButton.extended(
            onPressed: () async {
              final creado = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const NuevaCategoriaScreen()),
              );
              if (creado == true) _cargarCategorias(); // refresca la lista
            },
            icon: const Icon(Icons.add),
            label: const Text('Nueva Categoría'),
          ),
        ),

        body: Column(
          children: [
            // Barra de búsqueda reactiva
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (val) {
                  _searchQuery = val;
                  _aplicarFiltros();
                },
              ),
            ),

            // Chips de filtrado por estado
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _filtroEstado == 'TODOS',
                    onSelected: (_) {
                      _filtroEstado = 'TODOS';
                      _aplicarFiltros();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Solo Activos'),
                    selected: _filtroEstado == 'ACTIVOS',
                    onSelected: (_) {
                      _filtroEstado = 'ACTIVOS';
                      _aplicarFiltros();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Solo Inactivos'),
                    selected: _filtroEstado == 'INACTIVOS',
                    onSelected: (_) {
                      _filtroEstado = 'INACTIVOS';
                      _aplicarFiltros();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Contenido principal con pull-to-refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: _cargarCategorias,
                child: _buildBodyContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    // Estado 1: CARGANDO -> Shimmer skeleton
    if (_isLoading) {
      return ListView.builder(
        itemCount: 6,
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, _) => Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 70,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    // Estado 2: ERROR -> mensaje con botón de reintentar
    if (_errorMsg.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 12),
              Text(_errorMsg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar Conexión'),
                onPressed: _cargarCategorias,
              )
            ],
          ),
        ),
      );
    }

    // Estado 3: VACÍO -> no hay resultados después de filtrar
    if (_categoriasFiltradas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('No se encontraron categorías', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    // Estado 4: ÉXITO -> lista de categorías con RBAC en la acción
    return ListView.builder(
      itemCount: _categoriasFiltradas.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (ctx, i) {
        final cat = _categoriasFiltradas[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: cat.estado ? Colors.green.shade100 : Colors.red.shade100,
              child: Icon(
                cat.estado ? Icons.check : Icons.block,
                color: cat.estado ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              cat.nombre,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: cat.estado ? TextDecoration.none : TextDecoration.lineThrough,
              ),
            ),
            subtitle: Text(cat.descripcion),

            // Admin ve un Switch editable; vendedor ve solo un Chip informativo
            trailing: RoleGuardWidget(
              allowedRoles: const ['admin'],
              fallback: Chip(
                label: Text(cat.estado ? 'Activo' : 'Inactivo'),
                backgroundColor: cat.estado ? Colors.green.shade50 : Colors.grey.shade200,
              ),
              child: Switch(
                value: cat.estado,
                onChanged: (val) async {
                  await _service.cambiarEstado(cat.id);
                  _cargarCategorias();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}