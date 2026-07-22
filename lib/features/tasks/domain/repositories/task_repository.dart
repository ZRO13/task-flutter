
import 'package:volt/features/tasks/domain/entities/task_entity.dart';
import 'package:volt/features/tasks/domain/enums/task_status.dart';
import 'package:volt/features/tasks/domain/repositories/task_repository.dart';

/// Contrato del repositorio de tareas (capa Dominio).
///
/// Define las operaciones CRUD sin acoplarse a la implementación de
/// Supabase. La capa de Datos provee [TaskRepositoryImpl]. Esto
/// permite cambiar el backend sin tocar el dominio ni la UI.
abstract class TaskRepository {
  /// Obtiene las tareas del usuario para una fecha específica.
  Future<List<TaskEntity>> getTasksByDate(DateTime date);

  /// Crea una nueva tarea.
  Future<TaskEntity> createTask({
    required String title,
    String? description,
    required DateTime dueDate,
    required int volts,
  });

  /// Actualiza una tarea existente.
  Future<TaskEntity> updateTask(TaskEntity task);

  /// Cambia el estado de una tarea (transición de Kanban).
  Future<TaskEntity> updateStatus(String id, TaskStatus status);

  /// Elimina una tarea.
  Future<void> deleteTask(String id);
}
