import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Utilidades del Sistema de Voltaje.
///
/// Centraliza los cálculos relacionados con Voltios: niveles predefinidos,
/// consumo del día y validación del límite diario. Mantener esta lógica
/// fuera de la UI y de los controladores facilita testearla y defenderla
/// en la sustentación.
class VoltUtils {
  VoltUtils._();

  /// Niveles de energía predefinidos que el usuario puede asignar.
  static const List<VoltLevel> levels = [
    VoltLevel(label: 'Baja', volts: 10, color: AppColors.voltLow),
    VoltLevel(label: 'Media', volts: 30, color: AppColors.voltMedium),
    VoltLevel(label: 'Alta', volts: 50, color: AppColors.voltHigh)
  ];

  /// Límite diario por defecto (Voltios disponibles por jornada).
  static const int defaultDailyLimit = 100;

  /// Calcula el total de Voltios consumidos por una lista de tareas.
  ///
  /// Se cuentan todas las tareas del día, sin importar su estado, porque
  /// la energía se "reserva" al planificarla.
  static int consumed(Iterable<int> volts) {
    var sum = 0;
    for (final v in volts) {
      sum += v;
    }
    return sum;
  }

  /// Voltios restantes del día.
  static int remaining(int consumed, int limit) {
    return (limit - consumed).clamp(0, limit);
  }

  /// Porcentaje de uso (0.0 – 1.0).
  static double usageRatio(int consumed, int limit) {
    if (limit <= 0) return 1;
    return (consumed / limit).clamp(0.0, 1.0);
  }

  /// Indica si agregar [volts] excedería el límite diario.
  static bool wouldExceed(int consumed, int limit, int volts) {
    return consumed + volts > limit;
  }

  /// Devuelve el color asociado a una cantidad de voltios.
  static Color colorForVolts(int volts) {
    if (volts <= 10) return AppColors.voltLow;
    if (volts <= 30) return AppColors.voltMedium;
    return AppColors.voltHigh;
  }
}

/// Representa un nivel de energía seleccionable.
class VoltLevel {
  final String label;
  final int volts;
  final Color color;

  const VoltLevel({
    required this.label,
    required this.volts,
    required this.color,
  });
}