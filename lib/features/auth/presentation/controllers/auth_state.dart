import 'package:equatable/equatable.dart';

import '../../domain/entities/app_user.dart';

/// Estado de autenticación para la app.
///
/// Modelado como *sealed class* con subtipos inmutables (Equatable) para
/// pattern-matching seguro en la UI. Cubre el ciclo completo:
/// - [AuthState.initial]        → estado mientras se desconoce la sesión.
/// - [AuthState.loading]        → durante una operación de auth.
/// - [AuthState.authenticated]  → sesión activa.
/// - [AuthState.unauthenticated]→ sin sesión.
/// - [AuthState.error]          → fallo con mensaje.
sealed class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  List<Object?> get props => const [];
}

class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  List<Object?> get props => const [];
}

class Authenticated extends AuthState {
  final AppUser user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
  @override
  List<Object?> get props => const [];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

/// Extensión de conveniencia para hacer pattern-matching con `maybeWhen`.
extension AuthStateX on AuthState {
  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(AppUser user)? authenticated,
    T Function()? unauthenticated,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    final s = this;
    if (s is AuthInitial && initial != null) return initial();
    if (s is AuthLoading && loading != null) return loading();
    if (s is Authenticated && authenticated != null) return authenticated(s.user);
    if (s is Unauthenticated && unauthenticated != null) return unauthenticated();
    if (s is AuthError && error != null) return error(s.message);
    return orElse();
  }

  bool get isAuthenticated => this is Authenticated;
  AppUser? get user => this is Authenticated ? (this as Authenticated).user : null;
}
