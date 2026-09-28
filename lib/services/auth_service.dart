import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/environment.dart';
import '../models/usuario.dart';

class AuthService {
  // OBLIGA a consultar la IP real del PC en cada petición
  String get baseUrl {
    String url = Environment.apiUrl;
    if (!url.endsWith('/api')) {
      url = '$url/api';
    }
    return url;
  }

  final _storage = const FlutterSecureStorage();

  // POST: Autenticar e ingresar
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'jwt_token', value: data['token']);
      return true;
    }
    return false;
  }

  // GET: Obtener Perfil del Usuario Logueado
  Future<Usuario?> getPerfil() async {
    final token = await getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/auth/perfil'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<String?> getToken() async => await _storage.read(key: 'jwt_token');
  Future<void> logout() async => await _storage.delete(key: 'jwt_token');
}