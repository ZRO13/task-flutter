import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../core/utils/volt_utils.dart';
import '../../../../core/widgets/volt_chip.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_status.dart';
import '../controllers/task_controller.dart';
import '../providers/task_providers.dart';

/// Pantalla de formulario para crear o editar una tarea.
///
/// Cuando [task] es null, se crea una nueva tarea. Cuando no es null,
/// se edita la tarea existente. El formulario valida el título y los
/// Voltios, y muestra una advertencia si la tarea excedería el límite
/// diario del usuario.
class TaskFormScreen extends ConsumerStatefulWidget {
  final TaskFormArg? task;

  const TaskFormScreen({super.key, required this.task});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late DateTime _dueDate;
  late int _volts;
  bool _isSubmitting = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _dueDate = t?.dueDate ?? DateTime.now();
    _volts = t?.volts ?? VoltUtils.levels.first.volts;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.textOnPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final notifier = ref.read(taskControllerProvider.notifier);
    bool success;

    if (_isEditing) {
      final task = TaskEntity(
        id: widget.task!.id,
        userId: '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        dueDate: _dueDate,
        volts: _volts,
        status: TaskStatus.fromString(widget.task!.status),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      success = await notifier.updateTask(task);
    } else {
      success = await notifier.createTask(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        dueDate: _dueDate,
        volts: _volts,
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      context.go(AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar la tarea.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat.yMMMd('es').format(_dueDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(_isEditing ? 'Editar tarea' : 'Nueva tarea'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                TextFormField(
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Título de la tarea',
                    prefixIcon: Icon(Icons.task_outlined),
                  ),
                    validator: (v) => FormValidators.required(v, label: 'El título'),
                ),
                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Fecha de vencimiento
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de vencimiento',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      dateLabel,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Selector de Voltios ──────────────────────
                const Text(
                  'Nivel de energía (Voltios)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                VoltLevelSelector(
                  selectedVolts: _volts,
                  onSelected: (v) => setState(() => _volts = v),
                ),
                const SizedBox(height: 12),

                // Campo numérico personalizado de Voltios
                TextFormField(
                  initialValue: _volts.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Voltios personalizados',
                    prefixIcon: Icon(Icons.bolt),
                    suffixText: 'V',
                  ),
                  validator: (v) => FormValidators.volts(v),
                  onChanged: (v) {
                    final parsed = int.tryParse(v);
                    if (parsed != null && parsed >= 0) {
                      setState(() => _volts = parsed);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Preview del chip de voltaje
                Row(
                  children: [
                    const Text(
                      'Vista previa: ',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                    VoltChip(volts: _volts),
                  ],
                ),
                const SizedBox(height: 28),

                // Botón de guardar
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.textOnPrimary,
                          ),
                        )
                      : Text(_isEditing ? 'Guardar cambios' : 'Crear tarea'),
                ),
                const SizedBox(height: 16),

                // Advertencia de burnout
                if (!_isEditing)
                  const _BurnoutNotice(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Aviso educativo sobre el Sistema de Voltaje.
class _BurnoutNotice extends StatelessWidget {
  const _BurnoutNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'VOLT limita los Voltios diarios para prevenir la sobrecarga. '
              'Si superas tu límite, considera redistribuir tareas.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
