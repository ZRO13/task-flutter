import 'package:flutter/material.dart';

/// Sistema de colores de VOLT.
///
/// Tema oscuro con acentos de **amarillo neón/eléctrico** y **azul oscuro**,
/// haciendo honor al nombre VOLT. Se definen rampas completas para primary,
/// secondary, accent, success, warning, error y tonos neutros.
class AppColors {
  AppColors._();

  // ── Primary: amarillo neón / eléctrico ⚡ ────────────────
  static const Color primary = Color(0xFFFFE600);
  static const Color primaryBright = Color(0xFFFFF200);
  static const Color primaryDim = Color(0xFFB8A800);
  static const Color primaryGlow = Color(0x66FFE600); // semitransparente

  // ── Secondary: azul oscuro / eléctrico ──────────────────
  static const Color secondary = Color(0xFF1B2A4A);
  static const Color secondaryLight = Color(0xFF2A3F6B);
  static const Color secondaryDark = Color(0xFF0E1730);

  // ── Accent ──────────────────────────────────────────────
  static const Color accent = Color(0xFF00C2FF);

  // ── Rampas semánticas ───────────────────────────────────
  static const Color success = Color(0xFF3DDC84);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF40C4FF);

  // ── Neutros (fondo oscuro) ──────────────────────────────
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111622);
  static const Color surfaceVariant = Color(0xFF1A2030);
  static const Color card = Color(0xFF161C2C);
  static const Color border = Color(0xFF2A3245);
  static const Color divider = Color(0xFF1F2638);

  // ── Texto ───────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF2F4F8);
  static const Color textSecondary = Color(0xFFA0AABF);
  static const Color textMuted = Color(0xFF6B7488);
  static const Color textOnPrimary = Color(0xFF0A0E1A);

  // ── Niveles de Voltaje (energía) ────────────────────────
  /// Baja energía (10 V) — verde calmado.
  static const Color voltLow = Color(0xFF3DDC84);
  /// Media energía (30 V) — ámbar.
  static const Color voltMedium = Color(0xFFFFB300);
  /// Alta energía (50 V) — rojo eléctrico.
  static const Color voltHigh = Color(0xFFFF5252);
}
