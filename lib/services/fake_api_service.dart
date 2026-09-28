import 'dart:convert';
import '../models/producto.dart';

class FakeApiService {
  // SIMULACIÓN DE RESPUESTA JSON DESDE SERVIDOR
  final String _jsonResponse = '''
  [
    {"id": "1", "nombre": "Teclado Mecánico RGB", "precio": 89.99, "categoria": "Accesorios"},
    {"id": "2", "nombre": "Audífonos Noise Cancelling", "precio": 120.00, "categoria": "Audio"},
    {"id": "3", "nombre": "Smartphone Pro X", "precio": 899.00, "categoria": "Móviles"}
  ]
  ''';

  // MÉTODO ASÍNCRONO CON RETARDO DE RED
  Future<List<Producto>> obtenerProductos() async {
    // Simular latencia de red de 2 segundos
    await Future.delayed(const Duration(seconds: 2));

    // Decodificar String JSON a List<dynamic>
    final List<dynamic> listJson = jsonDecode(_jsonResponse);

    // Mapear cada elemento a un objeto Producto
    return listJson.map((item) => Producto.fromJson(item)).toList();
  }
}