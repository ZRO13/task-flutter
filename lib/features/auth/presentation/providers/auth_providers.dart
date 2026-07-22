import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';
import '../controllers/auth_state.dart';

/// Provider del repositorio de autenticación (implementación concreta).
///
/// La inversión de dependencias se materializa aquí: la UI y los
/// controladores dependen de la interfaz [AuthRepository], y Riverpod
/// inyecta la implementación [AuthRepositoryImpl].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Provider del controlador de estado de autenticación.
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

/// Alias legible para el router: estado de auth actual.
final authStateProvider = Provider<AuthState>((ref) {
  return ref.watch(authControllerProvider);
});
