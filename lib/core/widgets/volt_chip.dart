import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/volt_utils.dart';

/// Chip que muestra el nivel de energía de una tarea.
///
/// Color codificado por voltaje: verde (baja), ámbar (media), rojo (alta).
class VoltChip extends StatelessWidget {
  final int volts;

  const VoltChip({super.key, required this.volts});

  @override
  Widget build(BuildContext context) {
    final color = _colorForVolts(volts);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '${volts}V',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForVolts(int v) {
    if (v <= 10) return AppColors.voltLow;
    if (v <= 30) return AppColors.voltMedium;
    return AppColors.voltHigh;
  }
}

/// Selector de nivel de energía para el formulario de tarea.
class VoltLevelSelector extends StatelessWidget {
  final int selectedVolts;
  final ValueChanged<int> onSelected;

  const VoltLevelSelector({
    super.key,
    required this.selectedVolts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: VoltUtils.levels.map((level) {
        final isSelected = level.volts == selectedVolts;
        final color = level.color;
        return ChoiceChip(
          label: Text('${level.label} · ${level.volts}V'),
          selected: isSelected,
          onSelected: (_) => onSelected(level.volts),
          selectedColor: color.withOpacity(0.25),
          labelStyle: TextStyle(
            color: isSelected ? color : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
          side: BorderSide(
            color: isSelected ? color : AppColors.border,
          ),
          avatar: Icon(Icons.bolt, size: 18, color: color),
        );
      }).toList(),
    );
  }
}
