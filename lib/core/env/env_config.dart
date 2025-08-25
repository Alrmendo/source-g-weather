import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get weatherApiKey =>
      dotenv.env['WEATHER_API_KEY'] ?? '7f63c012aa2b44aa96c72837252308';

  static String get emailBackendUrl =>
      dotenv.env['EMAIL_BACKEND_URL'] ?? 'http://localhost:3000';

  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }
}
