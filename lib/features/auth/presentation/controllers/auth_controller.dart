import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Controlador de estado de autenticación (StateNotifier).
///
/// Escucha el stream de cambios de sesión de Supabase y emite el
/// [AuthState] correspondiente. Expone acciones de login, registro,
/// Google Sign-In y logout. La UI consume este notifier vía Riverpod.
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _sub;

  AuthController(this._repository) : super(const AuthInitial()) {
    // 1) Si ya hay sesión persistida, la emitimos.
    final current = _repository.currentUser;
    if (current != null) {
      state = Authenticated(current);
    }
    // 2) Suscripción a cambios de sesión en tiempo real.
    _sub = _repository.authChanges().listen((user) {
      if (user != null) {
        state = Authenticated(user);
      } else if (state is! AuthLoading) {
        // Solo marcamos unauthenticated si no estamos en medio de una acción.
        state = const Unauthenticated();
      }
    });
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      state = Authenticated(user);
    } catch (e) {
      state = AuthError(_friendly(e));
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();
    try {
      final user = await _repository.signUpWithEmail(
        email: email,
        password: password,
      );
      state = Authenticated(user);
    } catch (e) {
      state = AuthError(_friendly(e));
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthLoading();
    try {
      final user = await _repository.signInWithGoogle();
      if (user.id.isNotEmpty) {
        state = Authenticated(user);
      }
      // En web, el redirect propagará el estado vía el stream.
    } catch (e) {
      state = AuthError(_friendly(e));
    }
  }

  Future<void> signOut() async {
    state = const AuthLoading();
    try {
      await _repository.signOut();
      state = const Unauthenticated();
    } catch (e) {
      state = AuthError(_friendly(e));
    }
  }

  /// Traduce excepciones de Supabase a mensajes amigables en español.
  String _friendly(Object e) {
    final msg = e.toString();
    if (msg.contains('Invalid credentials') ||
        msg.contains('invalid_credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (msg.contains('already_registered') ||
        msg.contains('User already registered')) {
      return 'Ya existe una cuenta con este correo.';
    }
    if (msg.contains('Email not confirmed')) {
      return 'El correo no está confirmado.';
    }
    return 'Ocurrió un error. Intenta de nuevo.';
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
