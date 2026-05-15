import 'package:flutter/material.dart';

/// Central color palette for RENTO app.
/// Dark-first, fintech-inspired design system.
class AppColors {
  AppColors._();

  // ── Dark Mode ──────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0B0B0B); // Matte Black
  static const Color surface = Color(0xFF121212); // Cards / Surfaces
  static const Color surfaceElevated = Color(0xFF1A1A1A); // Slightly lighter surface
  static const Color border = Color(0xFF1F1F1F); // Subtle borders
  static const Color divider = Color(0xFF262626);

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFB91C1C); // Deep Red – primary CTA
  static const Color accentHover = Color(0xFFDC2626); // Slightly brighter on press
  static const Color accentSubtle = Color(0x1AB91C1C); // 10% opacity red bg

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA); // Muted Gray
  static const Color textDisabled = Color(0xFF52525B);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successSubtle = Color(0x1A22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSubtle = Color(0x1AF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSubtle = Color(0x1AEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSubtle = Color(0x1A3B82F6);

  // ── Misc ──────────────────────────────────────────────────────────────────
  static const Color disabled = Color(0xFF444444);
  static const Color shimmerBase = Color(0xFF1A1A1A);
  static const Color shimmerHighlight = Color(0xFF2A2A2A);
  static const Color overlay = Color(0x80000000); // 50% black overlay

  // ── Light Mode ────────────────────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightBorder = Color(0xFFE4E4E7);
  static const Color lightText = Color(0xFF09090B);
  static const Color lightTextSecondary = Color(0xFF71717A);
}
