import 'package:equatable/equatable.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_status.dart';

/// Estado de la lista de tareas del día.
///
/// Inmutable (Equatable). Combina los datos (lista de tareas) con
/// metainformación para la UI (loading, error). El controlador emite
/// nuevas instancias en cada transición.
class TaskListState extends Equatable {
  final List<TaskEntity> tasks;
  final bool isLoading;
  final String? error;

  const TaskListState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
  });

  TaskListState copyWith({
    List<TaskEntity>? tasks,
    bool? isLoading,
    String? error,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Filtra tareas por estado (para las columnas del Dashboard).
  List<TaskEntity> byStatus(TaskStatus status) =>
      tasks.where((t) => t.status == status).toList();

  /// Voltios totales consumidos hoy.
  int get consumedVolts =>
      tasks.fold(0, (sum, t) => sum + t.volts);

  @override
  List<Object?> get props => [tasks, isLoading, error];
}
