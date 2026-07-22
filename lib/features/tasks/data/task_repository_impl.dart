import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/supabase_client.dart';
import '../domain/entities/task_entity.dart';
import '../domain/enums/task_status.dart';
import '../domain/repositories/task_repository.dart';

/// Implementación concreta de [TaskRepository] usando Supabase.
///
/// Pertenece a la capa de Datos: mapea las filas de la tabla `tasks`
/// a la entidad de dominio [TaskEntity]. La RLS garantiza que cada
/// usuario solo acceda a sus propias tareas.
class TaskRepositoryImpl implements TaskRepository {
  SupabaseClient get _client => supabase;

  static const _table = 'tasks';

  /// Mapea una fila de Supabase (Map) a [TaskEntity].
  TaskEntity _map(Map<String, dynamic> row) {
    return TaskEntity(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      title: row['title'] as String,
      description: row['description'] as String?,
      dueDate: DateTime.parse(row['due_date'] as String),
      volts: (row['volts'] as num).toInt(),
      status: TaskStatus.fromString(row['status'] as String?),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  /// Convierte una [DateTime] a string de fecha `YYYY-MM-DD` para la DB.
  String _dateKey(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Future<List<TaskEntity>> getTasksByDate(DateTime date) async {
    final res = await _client
        .from(_table)
        .select()
        .eq('due_date', _dateKey(date))
        .order('created_at', ascending: true);
    final list = res as List<dynamic>;
    return list.map((e) => _map(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<TaskEntity> createTask({
    required String title,
    String? description,
    required DateTime dueDate,
    required int volts,
  }) async {
    // user_id se omite: la DB lo rellena con DEFAULT auth.uid().
    final res = await _client.from(_table).insert({
      'title': title,
      'description': description,
      'due_date': _dateKey(dueDate),
      'volts': volts,
      // status usa el default 'todo'
    }).select().single();
    return _map(res);
  }

  @override
  Future<TaskEntity> updateTask(TaskEntity task) async {
    final res = await _client
        .from(_table)
        .update({
          'title': task.title,
          'description': task.description,
          'due_date': _dateKey(task.dueDate),
          'volts': task.volts,
          'status': task.status.value,
        })
        .eq('id', task.id)
        .select()
        .single();
    return _map(res);
  }

  @override
  Future<TaskEntity> updateStatus(String id, TaskStatus status) async {
    final res = await _client
        .from(_table)
        .update({'status': status.value})
        .eq('id', id)
        .select()
        .single();
    return _map(res);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
