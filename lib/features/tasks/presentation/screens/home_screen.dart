import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/supabase_client.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/volt_utils.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../../../core/widgets/volt_meter.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/enums/task_status.dart';
import '../controllers/task_list_state.dart';
import '../providers/task_providers.dart';
import 'widgets/task_card.dart';

/// Provider del límite diario de Voltios desde el perfil en Supabase.
final homeVoltLimitProvider = FutureProvider<int>((ref) async {
  try {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return VoltUtils.defaultDailyLimit;
    final res = await supabase
        .from('profiles')
        .select('daily_volt_limit')
        .eq('id', userId)
        .maybeSingle();
    final limit = res?['daily_volt_limit'];
    return (limit is int) ? limit : VoltUtils.defaultDailyLimit;
  } catch (_) {
    return VoltUtils.defaultDailyLimit;
  }
});

/// Dashboard principal de VOLT.
///
/// Muestra:
/// - El medidor circular de Voltios consumidos vs. disponibles del día.
/// - Las tareas del día agrupadas por estado (To-Do, In Progress, Done).
/// - Botón para crear una nueva tarea.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carga inicial de tareas al entrar al dashboard.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskControllerProvider.notifier).loadToday();
    });
  }

  Future<void> _refresh() async {
    await ref.read(taskControllerProvider.notifier).loadToday();
    ref.invalidate(homeVoltLimitProvider);
  }

  @override
  Widget build(BuildContext context) {
    final taskState = ref.watch(taskControllerProvider);
    final limitAsync = ref.watch(homeVoltLimitProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.bolt, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            const Text(
              'VOLT',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.taskForm),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: AsyncValueWidget<int>(
          value: limitAsync,
          data: (limit) => _Body(taskState: taskState, limit: limit),
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await ref.read(authControllerProvider.notifier).signOut();
  }
}

/// Cuerpo del dashboard: medidor + secciones de tareas.
class _Body extends ConsumerWidget {
  final TaskListState taskState;
  final int limit;

  const _Body({required this.taskState, required this.limit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (taskState.isLoading && taskState.tasks.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (taskState.error != null && taskState.tasks.isEmpty) {
      return _ErrorView(message: taskState.error ?? 'Ocurrió un error inesperado');
    }

    final consumed = taskState.consumedVolts;
    final today = DateFormat.yMMMMd('es').format(DateTime.now());

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: [
        // ── Encabezado del día ─────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hoy',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  today,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
              onPressed: () => ref.read(taskControllerProvider.notifier).loadToday(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // ── Medidor de Voltios ────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              VoltMeter(consumed: consumed, limit: limit),
              const SizedBox(height: 16),
              Text(
                'Sistema de Voltaje',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // ── Secciones por estado ──────────────────────────
        _StatusSection(
          title: 'Por hacer',
          color: AppColors.textSecondary,
          tasks: taskState.byStatus(TaskStatus.todo),
        ),
        _StatusSection(
          title: 'En progreso',
          color: AppColors.warning,
          tasks: taskState.byStatus(TaskStatus.inProgress),
        ),
        _StatusSection(
          title: 'Completadas',
          color: AppColors.success,
          tasks: taskState.byStatus(TaskStatus.done),
        ),
      ],
    );
  }
}

/// Sección de tareas agrupada por estado.
class _StatusSection extends StatelessWidget {
  final String title;
  final Color color;
  final List<TaskEntity> tasks;

  const _StatusSection({
    required this.title,
    required this.color,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${tasks.length})',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Sin tareas',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          )
        else
          ...tasks.map<Widget>((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TaskCard(task: t),
              )),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Vista de error reutilizable.
class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            const Text('No se pudieron cargar las tareas'),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
