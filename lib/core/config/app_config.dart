/// Configuración global de la aplicación.
///
/// Carga las variables de entorno inyectadas durante la compilación
/// mediante --dart-define.
/// Centraliza el acceso a las credenciales de Supabase para que ninguna capa
/// superior tenga que leer el entorno directamente (Single Source of Truth).
class AppConfig {
  AppConfig._();

  // Se extraen las variables directamente en tiempo de compilación.
  static const String supabaseUrl = String.fromEnvironment(
    'VITE_SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'VITE_SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );
}
