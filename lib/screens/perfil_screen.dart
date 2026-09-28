import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final AuthService _authService = AuthService();
  late Future<Usuario?> _futureUsuario;

  @override
  void initState() {
    super.initState();
    _futureUsuario = _authService.getPerfil();
  }

  void _cerrarSesion() async {
    // Solo le avisamos al AuthProvider global — NUNCA empujamos manualmente
    // una nueva pantalla de Login. El AuthWrapper en main.dart está
    // escuchando este cambio de estado y decide él solo qué mostrar.
    await context.read<AuthProvider>().logout();

    if (mounted) {
      // Regresa la pila de navegación hasta la ruta raíz (el AuthWrapper),
      // SIN eliminarlo de por medio, para que siga vivo y reaccionando.
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil de Usuario')),
      body: FutureBuilder<Usuario?>(
        future: _futureUsuario,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Error al cargar datos del usuario'));
          }

          final usuario = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.indigo.shade100,
                  child: Text(
                    usuario.nombre.isNotEmpty ? usuario.nombre[0] : 'U',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(usuario.nombre, style: Theme.of(context).textTheme.headlineSmall),
                Text(usuario.email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Chip(
                  label: Text('Rol: ${usuario.role.toUpperCase()}'),
                  backgroundColor: usuario.role == 'admin' ? Colors.amber.shade200 : Colors.blue.shade200,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
                  onPressed: _cerrarSesion,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}