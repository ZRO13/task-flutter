import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// Importación necesaria para leer la sesión en el redirect
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/tasks/presentation/screens/home_screen.dart';
import '../../features/tasks/presentation/screens/task_form_screen.dart';

/// Nombre de las rutas centralizado.
class AppRoutes {
  AppRoutes._();
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/';
  static const taskForm = '/task-form';
  static const taskEdit = '/task-edit';
}

/// Router global de la app, construido con Riverpod para reaccionar
/// al estado de autenticación (redirect inteligente).
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      // 1. Verificamos la sesión de Supabase de forma síncrona para detectar el retorno de Google
      final session = Supabase.instance.client.auth.currentSession;
      
      // 2. Evaluamos si está logueado
      final isLoggedIn = session != null || authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      
      // 3. Usamos state.uri.path en vez de matchedLocation para limpiar los parámetros (?code=...)
      final path = state.uri.path;
      final isOnSplash = path == AppRoutes.splash;
      final isOnAuth = path == AppRoutes.login || path == AppRoutes.register;

      // Mientras se desconoce el estado, no redirigimos fuera del splash.
      final isUnknown = authState.maybeWhen(
        initial: () => true,
        orElse: () => false,
      );

      if (isUnknown && !isOnSplash) return AppRoutes.splash;

      // Redirecciones
      if (isLoggedIn && (isOnAuth || isOnSplash)) return AppRoutes.home;
      if (!isLoggedIn && !isOnAuth && !isOnSplash) return AppRoutes.login;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.taskForm,
        builder: (context, state) => const TaskFormScreen(task: null),
      ),
      GoRoute(
        path: AppRoutes.taskEdit,
        builder: (context, state) {
          final task = state.extra as TaskFormArg?;
          return TaskFormScreen(task: task);
        },
      ),
    ],
  );
});

/// Bridges Riverpod auth state → GoRouter's ChangeNotifier refresh.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen<AuthState>(authStateProvider, (_, __) => notifyListeners());
  }
  @override
  void dispose() {
    super.dispose();
  }
}

/// Argumento tipado para la ruta de edición de tarea.
class TaskFormArg {
  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final int volts;
  final String status;

  const TaskFormArg({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.volts,
    required this.status,
  });
}
