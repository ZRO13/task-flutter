import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Medidor circular de Voltios consumidos vs. disponibles.
///
/// Widget reutilizable que muestra el consumo diario como un arco de progreso
/// circular con el estilo neón de VOLT. Es el componente visual central del
/// "Sistema de Voltaje" en el Dashboard.
class VoltMeter extends StatelessWidget {
  final int consumed;
  final int limit;
  final double size;

  const VoltMeter({
    super.key,
    required this.consumed,
    required this.limit,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (limit <= 0) ? 0.0 : (consumed / limit).clamp(0.0, 1.0);
    final remaining = (limit - consumed).clamp(0, limit);
    final overLimit = consumed > limit;

    final arcColor = overLimit
        ? AppColors.error
        : (ratio > 0.8 ? AppColors.voltHigh : AppColors.primary);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Track de fondo
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 12,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.surfaceVariant,
              ),
            ),
          ),
          // Progreso de consumo
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: ratio,
              strokeWidth: 12,
              strokeCap: StrokeCap.round,
              valueColor: AlwaysStoppedAnimation<Color>(arcColor),
              backgroundColor: Colors.transparent,
            ),
          ),
          // Texto central
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$consumed',
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w800,
                  color: arcColor,
                  height: 1,
                ),
              ),
              Text(
                '/ $limit V',
                style: TextStyle(
                  fontSize: size * 0.11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                overLimit
                    ? 'EXCEDIDO'
                    : (remaining == 0 ? 'LÍMITE ALCANZADO' : '$remaining V disponibles'),
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: overLimit ? AppColors.error : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
