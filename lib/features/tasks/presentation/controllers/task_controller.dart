import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_status.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_list_state.dart';

/// Controlador de estado de tareas (StateNotifier).
///
/// Carga las tareas del día, expone operaciones CRUD y recalcúa el
/// consumo de Voltios. La UI consume [TaskListState] vía Riverpod.
/// Cada acción refresca la lista desde Supabase para mantener la
/// coherencia con el backend.
class TaskController extends StateNotifier<TaskListState> {
  final TaskRepository _repository;

  TaskController(this._repository) : super(const TaskListState()) {
    loadToday();
  }

  /// Carga las tareas correspondientes a [date].
  Future<void> loadForDate(DateTime date) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tasks = await _repository.getTasksByDate(date);
      state = TaskListState(tasks: tasks, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Atajo para cargar las tareas de hoy.
  Future<void> loadToday() => loadForDate(DateTime.now());

  /// Crea una nueva tarea.
  Future<bool> createTask({
    required String title,
    String? description,
    required DateTime dueDate,
    required int volts,
  }) async {
    try {
      await _repository.createTask(
        title: title,
        description: description,
        dueDate: dueDate,
        volts: volts,
      );
      await loadForDate(dueDate);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Actualiza una tarea existente.
  Future<bool> updateTask(TaskEntity task) async {
    try {
      await _repository.updateTask(task);
      await loadForDate(task.dueDate);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Cambia el estado de una tarea (transición de Kanban).
  Future<void> updateStatus(String id, TaskStatus status) async {
    try {
      await _repository.updateStatus(id, status);
      await loadToday();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Elimina una tarea.
  Future<void> deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
      await loadToday();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Limpia el mensaje de error.
  void clearError() {
    state = state.copyWith(error: null);
  }
}
