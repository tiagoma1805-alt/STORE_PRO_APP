import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/environment.dart';
import '../models/producto.dart';

class ProductoService {
  String get baseUrl {
    String url = Environment.apiUrl;
    if (!url.endsWith('/api')) {
      url = '$url/api';
    }
    return url;
  }

  final _storage = const FlutterSecureStorage();

  Future<List<Producto>> getProductos() async {
    final response = await http.get(Uri.parse('$baseUrl/productos'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Producto.fromJson(json)).toList();
    }
    return [];
  }

  Future<bool> crearProducto(String nombre, double precio, int stock, int categoriaId) async {
    final token = await _storage.read(key: 'jwt_token');
    final response = await http.post(
      Uri.parse('$baseUrl/productos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nombre': nombre,
        'precio': precio,
        'stock': stock,
        'categoriaId': categoriaId,
      }),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> cambiarEstado(int id) async {
    final token = await _storage.read(key: 'jwt_token');
    final response = await http.patch(
      Uri.parse('$baseUrl/productos/$id/estado'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }
}