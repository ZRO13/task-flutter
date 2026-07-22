import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

/// Inicializa y expone el cliente singleton de Supabase.
///
/// Se invoca una sola vez en `main.dart`. La instancia global
/// `Supabase.instance.client` se reutiliza en toda la app.
Future<void> initSupabase() async {
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    // Persistencia de sesión activada por defecto en supabase_flutter.
    debug: false,
  );
}

/// Acceso conveniente al cliente Supabase ya inicializado.
SupabaseClient get supabase => Supabase.instance.client;
