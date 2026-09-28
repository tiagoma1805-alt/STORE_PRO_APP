import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiUrl {
    String url = dotenv.env['API_URL'] ?? 'http://192.168.20.67:3000/api';
    // Si por alguna razón la URL aún dice localhost, la cambia automáticamente a tu IP
    if (url.contains('localhost') || url.contains('127.0.0.1')) {
      return 'http://192.168.20.67:3000/api';
    }
    return url;
  }
}