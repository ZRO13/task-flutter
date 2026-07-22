import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'core/config/supabase_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Punto de entrada de VOLT.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Inicializa Supabase (las credenciales ahora se leen estáticamente).
  await initSupabase();

  // 2) Inicializa localización para fechas en español.
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
