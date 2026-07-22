import 'package:equatable/equatable.dart';

/// Enumeración de estados de una tarea.
///
/// Se mantiene en el dominio para que la UI y los repositorios compartan
/// un vocabulario único. El valor [value] se usa para persistir en la
/// columna `status` de la base de datos.
enum TaskStatus {
  todo('todo'),
  inProgress('in_progress'),
  done('done');

  final String value;
  const TaskStatus(this.value);

  /// Construye un [TaskStatus] desde el string guardado en la DB.
  static TaskStatus fromString(String? raw) {
    return switch (raw) {
      'in_progress' => TaskStatus.inProgress,
      'done' => TaskStatus.done,
      _ => TaskStatus.todo,
    };
  }

  /// Etiqueta legible para la UI.
  String get label => switch (this) {
        TaskStatus.todo => 'Por hacer',
        TaskStatus.inProgress => 'En progreso',
        TaskStatus.done => 'Completada',
      };
}
