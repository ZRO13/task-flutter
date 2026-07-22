import 'package:flutter/services.dart';

/// Configuración global de la aplicación.
///
/// Carga las variables de entorno desde el archivo `.env` incluido como asset.
/// Centraliza el acceso a las credenciales de Supabase para que ninguna capa
/// superior tenga que leer el entorno directamente (Single Source of Truth).
class AppConfig {
  AppConfig._();

  static String? _supabaseUrl;
  static String? _supabaseAnonKey;
  static String? _googleClientId;

  /// Carga el `.env` (asset) una sola vez, al arrancar la app.
  static Future<void> load() async {
    final env = await rootBundle.loadString('.env');
    final map = <String, String>{};
    for (final line in env.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final idx = trimmed.indexOf('=');
      if (idx == -1) continue;
      final key = trimmed.substring(0, idx).trim();
      final value = trimmed.substring(idx + 1).trim();
      map[key] = value;
    }
    _supabaseUrl = map['VITE_SUPABASE_URL'];
    _supabaseAnonKey = map['VITE_SUPABASE_ANON_KEY'];
    _googleClientId = map['GOOGLE_CLIENT_ID'];
  }

  static String get supabaseUrl {
    final v = _supabaseUrl;
    if (v == null || v.isEmpty) {
      throw StateError('AppConfig.load() debe llamarse antes de usar supabaseUrl');
    }
    return v;
  }

  static String get supabaseAnonKey {
    final v = _supabaseAnonKey;
    if (v == null || v.isEmpty) {
      throw StateError('AppConfig.load() debe llamarse antes de usar supabaseAnonKey');
    }
    return v;
  }

  static String get googleClientId {
    return _googleClientId ?? '';
  }
}
