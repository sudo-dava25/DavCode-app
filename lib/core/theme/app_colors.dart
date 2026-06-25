import 'package:flutter/material.dart';

/// Color tokens for Dav Code's IDE-style dark theme.
/// Naming mirrors common editor design tokens (Bg, Surface, Border, ...)
/// so they map cleanly onto VS-Code-like theming.
class AppColors {
  AppColors._();

  // Base surfaces
  static const Color bg = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceElevated = Color(0xFF1F2530);
  static const Color border = Color(0xFF30363D);

  // Text
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF6E7681);

  // Accent / brand
  static const Color accent = Color(0xFF58A6FF);
  static const Color accentMuted = Color(0xFF1F6FEB);

  // Semantic
  static const Color success = Color(0xFF3FB950);
  static const Color warning = Color(0xFFD29922);
  static const Color error = Color(0xFFF85149);
  static const Color info = Color(0xFF58A6FF);

  // Git status colors
  static const Color gitAdded = Color(0xFF3FB950);
  static const Color gitModified = Color(0xFFD29922);
  static const Color gitDeleted = Color(0xFFF85149);
  static const Color gitUntracked = Color(0xFF8B949E);

  // Syntax highlighting palette (used by SyntaxHighlighterService)
  static const Color syntaxKeyword = Color(0xFFFF7B72);
  static const Color syntaxString = Color(0xFFA5D6FF);
  static const Color syntaxComment = Color(0xFF8B949E);
  static const Color syntaxNumber = Color(0xFF79C0FF);
  static const Color syntaxFunction = Color(0xFFD2A8FF);
  static const Color syntaxType = Color(0xFFFFA657);
  static const Color syntaxVariable = Color(0xFFE6EDF3);
  static const Color syntaxOperator = Color(0xFFFF7B72);

  // Terminal
  static const Color terminalBg = Color(0xFF010409);
  static const Color terminalText = Color(0xFFE6EDF3);
}
