import 'package:equatable/equatable.dart';

/// Entidad de usuario en la capa de Dominio.
///
/// Es agnóstica a Supabase y a Flutter: representa al usuario autenticado
/// de forma pura. La capa de Datos se encarga de mapear desde/hacia
/// Supabase (`User` de supabase_flutter) a esta entidad.
class AppUser extends Equatable {
  final String id;
  final String email;
  final int? dailyVoltLimit;

  const AppUser({
    required this.id,
    required this.email,
    this.dailyVoltLimit,
  });

  @override
  List<Object?> get props => [id, email, dailyVoltLimit];
}
