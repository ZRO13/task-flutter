import 'package:equatable/equatable.dart';

import '../enums/task_status.dart';

/// Entidad de Tarea en la capa de Dominio.
///
/// Representa una tarea del Sistema de Voltaje. Es agnóstica a Supabase:
/// la capa de Datos mapea entre las filas de la tabla `tasks` y esta
/// entidad. El campo [volts] es el diferenciador de VOLT: la energía
/// que la tarea consume del presupuesto diario.
class TaskEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime dueDate;
  final int volts;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.volts,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crea una copia con campos opcionales modificados (inmutabilidad).
  TaskEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? volts,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      volts: volts ?? this.volts,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        dueDate,
        volts,
        status,
        createdAt,
        updatedAt,
      ];
}
