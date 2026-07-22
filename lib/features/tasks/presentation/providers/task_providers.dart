import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../controllers/task_controller.dart';
import '../controllers/task_list_state.dart';

/// Provider del repositorio de tareas (implementación concreta).
///
/// Inyección de dependencias vía Riverpod: la UI y los controladores
/// dependen de la interfaz [TaskRepository], y aquí se inyecta la
/// implementación [TaskRepositoryImpl] con Supabase.
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl();
});

/// Provider del controlador de estado de tareas.
final taskControllerProvider =
    StateNotifierProvider<TaskController, TaskListState>((ref) {
  return TaskController(ref.watch(taskRepositoryProvider));
});
