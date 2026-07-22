import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:volt/core/router/app_router.dart';
import 'package:volt/core/theme/app_colors.dart';
import 'package:volt/core/widgets/volt_chip.dart';
import 'package:volt/features/tasks/domain/entities/task_entity.dart';
import 'package:volt/features/tasks/domain/enums/task_status.dart';
import 'package:volt/features/tasks/presentation/providers/task_providers.dart';
/// Tarjeta visual de una tarea.
///
/// Muestra título, descripción, chip de Voltios y acciones rápidas:
/// cambiar de estado y eliminar. Al tocar la card se abre el formulario
/// de edición.
class TaskCard extends ConsumerWidget {
  final TaskEntity task;

  const TaskCard({super.key, required this.task});

  Color get _statusColor => switch (task.status) {
        TaskStatus.todo => AppColors.textSecondary,
        TaskStatus.inProgress => AppColors.warning,
        TaskStatus.done => AppColors.success,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = task.status == TaskStatus.done;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(
          AppRoutes.taskEdit,
          extra: TaskFormArg(
            id: task.id,
            title: task.title,
            description: task.description,
            dueDate: task.dueDate,
            volts: task.volts,
            status: task.status.value,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: chip de voltaje + estado
              Row(
                children: [
                  VoltChip(volts: task.volts),
                  const Spacer(),
                  _StatusPill(status: task.status, color: _statusColor),
                ],
              ),
              const SizedBox(height: 10),

              // Título
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  task.description!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),

              // Acciones rápidas
              Row(
                children: [
                  // Avanzar estado
                  _StatusButton(
                    task: task,
                    onTap: () => _advanceStatus(ref),
                  ),
                  const Spacer(),
                  // Eliminar
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppColors.textMuted,
                    onPressed: () => _confirmDelete(context, ref),
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Avanza el estado: todo → in_progress → done → todo.
  Future<void> _advanceStatus(WidgetRef ref) async {
    final next = switch (task.status) {
      TaskStatus.todo => TaskStatus.inProgress,
      TaskStatus.inProgress => TaskStatus.done,
      TaskStatus.done => TaskStatus.todo,
    };
    await ref.read(taskControllerProvider.notifier).updateStatus(task.id, next);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Eliminar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(taskControllerProvider.notifier).deleteTask(task.id);
    }
  }
}

/// Píldora de estado con color semántico.
class _StatusPill extends StatelessWidget {
  final TaskStatus status;
  final Color color;

  const _StatusPill({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Botón para avanzar el estado de la tarea.
class _StatusButton extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;

  const _StatusButton({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (label, icon, color) = switch (task.status) {
      TaskStatus.todo => ('Iniciar', Icons.play_arrow, AppColors.warning),
      TaskStatus.inProgress =>
        ('Completar', Icons.check, AppColors.success),
      TaskStatus.done => ('Reabrir', Icons.refresh, AppColors.textSecondary),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
