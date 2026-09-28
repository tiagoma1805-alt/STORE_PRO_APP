import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Carga las variables de entorno
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Asegura la inicialización previa de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Carga el archivo .env con las variables de entorno
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}