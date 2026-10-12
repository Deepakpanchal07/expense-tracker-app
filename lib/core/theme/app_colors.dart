import 'package:flutter/material.dart';

class AppColors {
  // Primary & Backgrounds (Modern sleek Dark & Light modes)
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);

  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color accent = Color(0xFF8B5CF6); // Purple

  // Financial Semantics
  static const Color income = Color(0xFF10B981); // Emerald green
  static const Color incomeBg = Color(0xFFE6F4EA);
  static const Color expense = Color(0xFFEF4444); // Crimson red
  static const Color expenseBg = Color(0xFFFDE8E8);
  static const Color warning = Color(0xFFF59E0B); // Amber warning
  static const Color warningBg = Color(0xFFFEF3C7);

  // Neutral Colors (Dark mode optimized)
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkSurfaceCard = Color(0xFF26334D); // Slightly lighter card
  static const Color darkBorder = Color(0xFF334155); // Slate 700
  
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textMutedDark = Color(0xFF64748B); // Slate 500

  // Neutral Colors (Light mode fallback)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);

  // Gradient presets
  static const LinearGradient balanceGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x336366F1), Color(0x110F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
