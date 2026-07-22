import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'core/config/app_config.dart';
import 'core/config/supabase_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Punto de entrada de VOLT.
///
/// Inicializa (en orden):
/// 1. Las variables de entorno (`AppConfig.load`).
/// 2. El cliente de Supabase (`initSupabase`).
/// 3. Datos de localización (intl).
/// 4. La app con ProviderScope (Riverpod) + tema oscuro + GoRouter.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Carga .env y 2) inicializa Supabase (con persistencia de sesión).
  await AppConfig.load();
  await initSupabase();

  // 3) Inicializa localización para fechas en español.
  await initializeDateFormatting('es', null);

  runApp(const ProviderScope(child: VoltApp()));
}

/// Widget raíz de la aplicación.
class VoltApp extends ConsumerWidget {
  const VoltApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'VOLT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      routerConfig: router,
    );
  }
}
