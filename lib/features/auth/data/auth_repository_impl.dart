import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_client.dart';
import '../domain/entities/app_user.dart';
import '../domain/repositories/auth_repository.dart';
import 'package:volt/core/config/app_config.dart';
/// Implementación concreta de [AuthRepository] usando Supabase.
///
/// Pertenece a la capa de Datos: traduce las entidades y respuestas de
/// `supabase_flutter` a las entidades de dominio (`AppUser`). La UI y
/// los controladores nunca interactúan directamente con Supabase.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl();

  SupabaseClient get _client => supabase;

  /// Mapea el `User` de Supabase a la entidad de dominio.
  /// El `dailyVoltLimit` se obtiene del perfil en la tabla `profiles`
  /// (creado automáticamente por el trigger `handle_new_user`).
  AppUser? _map(User? u) {
    if (u == null) return null;
    final rawLimit = u.userMetadata?['daily_volt_limit'];
    return AppUser(
      id: u.id,
      email: u.email ?? '',
      dailyVoltLimit: rawLimit is int ? rawLimit : null,
    );
  }

  @override
  AppUser? get currentUser => _map(_client.auth.currentUser);

  @override
  Stream<AppUser?> authChanges() {
    return _client.auth.onAuthStateChange.map((event) => _map(event.session?.user));
  }

  @override
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signUp(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user == null) {
      throw const AuthException('No se pudo crear la cuenta.');
    }
    // El trigger DB crea el perfil automáticamente.
    return _map(user)!;
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user == null) {
      throw const AuthException('Credenciales inválidas.');
    }
    return _map(user)!;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    // Flujo nativo de Google Sign-In + Supabase OAuth.
    // En web se usa `signInWithOAuth`; en Android/iOS se intercambia el
    // ID token de Google por una sesión de Supabase.
    if (kIsWeb) {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: '${Uri.base.origin}/login',
      );
      // En web, el redirect maneja la sesión; el stream la propagará.
      return _map(_client.auth.currentUser) ??
          const AppUser(id: '', email: '');
    }

    final googleSignIn = GoogleSignIn(
      serverClientId: _googleServerClientId,
    );
    final account = await googleSignIn.signIn();
    if (account == null) {
      throw const AuthException('Inicio de sesión con Google cancelado.');
    }
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw const AuthException('No se obtuvo el token de Google.');
    }

    final res = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
    final user = res.user;
    if (user == null) {
      throw const AuthException('Google Sign-In falló.');
    }
    return _map(user)!;
  }

  /// Client ID de Google para el flujo nativo.
  /// En producción se obtiene de Google Cloud Console y se inyecta vía
  /// variables de entorno. Para el alcance académico se deja configurable.
  String get _googleServerClientId {
    return AppConfig.googleClientId;
  }

  @override
  Future<void> signOut() async {
    // Cierra sesión de Google si estaba activa (solo en plataformas nativas).
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await GoogleSignIn().signOut();
      }
    } catch (_) {
      // Ignoramos errores de Google al cerrar sesión.
    }
    await _client.auth.signOut();
  }
}
