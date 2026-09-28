import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_screen.dart'; // Importa la pantalla con los 2 botones abajo

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'admin@storepro.com');
  final _passCtrl = TextEditingController(text: '123456');
  bool _isLoading = false;

  void _ejecutarLogin() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool exito = await authProvider.login(_emailCtrl.text, _passCtrl.text);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (exito) {
        // AQUÍ VA LA LÍNEA: Si el login es exitoso, abre MainScreen con la barra de navegación inferior
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales o servidor incorrectos')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de autenticación: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StorePro - Acceso')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person, size: 70, color: Colors.indigo),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Correo electrónico'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text('Ingresar a la App'),
                    onPressed: _ejecutarLogin,
                  ),
          ],
        ),
      ),
    );
  }
}