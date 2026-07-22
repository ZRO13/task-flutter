import '../../domain/entities/app_user.dart';

/// Contrato del repositorio de autenticación (capa Dominio).
///
/// Define QUÉ operaciones de auth existen, sin acoplarse a CÓMO se
/// implementan (Supabase, Firebase, etc.). La capa de Datos provee
/// la implementación concreta. Esto es la base de la inversión de
/// dependencias en Clean Architecture.
abstract class AuthRepository {
  /// Usuario actual, o null si no hay sesión.
  AppUser? get currentUser;

  /// Stream que emite cambios de sesión.
  Stream<AppUser?> authChanges();

  /// Registro con correo y contraseña.
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
  });

  /// Login con correo y contraseña.
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  /// Login con Google Sign-In (vía Supabase OAuth).
  Future<AppUser> signInWithGoogle();

  /// Cierre de sesión.
  Future<void> signOut();
}
