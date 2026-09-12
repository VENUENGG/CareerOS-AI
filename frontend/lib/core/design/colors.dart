import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF050608);
  static const Color backgroundSecondary = Color(0xFF0A0C10);
  static const Color backgroundElevated = Color(0xFF0E1014);
  static const Color backgroundOverlay = Color(0xFF14161C);

  static const Color surface = Color(0xFF0E1014);
  static const Color surfaceSecondary = Color(0xFF14161C);
  static const Color surfaceElevated = Color(0xFF1A1E26);
  static const Color surfaceOverlay = Color(0xFF1E232D);
  static const Color surfaceInteractive = Color(0xFF1E232D);

  static const Color border = Color(0xFF242834);
  static const Color borderStrong = Color(0xFF2D3240);
  static const Color borderSubtle = Color(0xFF1E232D);
  static const Color divider = Color(0xFF242834);

  static const Color primary = Color(0xFF7C5CFF);
  static const Color primaryLight = Color(0xFF9B85FF);
  static const Color primaryDark = Color(0xFF5A3FE8);
  static const Color primaryContainer = Color(0xFF2A1F4D);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFE8E0FF);

  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successContainer = Color(0xFF064E33);
  static const Color onSuccessContainer = Color(0xFFA7F3D0);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningContainer = Color(0xFF78350F);
  static const Color onWarningContainer = Color(0xFFFDE68A);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFF87171);
  static const Color dangerContainer = Color(0xFF7F1D1D);
  static const Color onDangerContainer = Color(0xFFFCA5A5);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoContainer = Color(0xFF1E3A5F);
  static const Color onInfoContainer = Color(0xFFBFDBFE);

  static const Color ai = Color(0xFF8B5CF6);
  static const Color aiLight = Color(0xFFA78BFA);
  static const Color aiContainer = Color(0xFF2E1A4E);
  static const Color onAiContainer = Color(0xFFDDD6FE);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textInverse = Color(0xFF050608);
  static const Color textDisabled = Color(0xFF475569);

  static const Color placeholder = Color(0xFF475569);
  static const Color overlay = Color(0xCC050608);
  static const Color scrim = Color(0x99000000);

  static const Color glass = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x1FFFFFFF);

  static const Color accent = primary;
  static const Color accentSoft = primaryContainer;
  static const Color accentStrong = primaryLight;

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF080A0F),
      Color(0xFF050608),
      Color(0xFF0A0C10),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF14161C),
      Color(0xFF0E1014),
    ],
    stops: [0.0, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7C5CFF),
      Color(0xFF8B5CF6),
      Color(0xFF6366F1),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
  );

  static const LinearGradient aiGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B5CF6),
      Color(0xFF7C3AED),
    ],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF59E0B),
      Color(0xFFD97706),
    ],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEF4444),
      Color(0xFFDC2626),
    ],
  );
}

extension ColorExtensions on Color {
  Color withAlphaValue(int alpha) => withValues(alpha: alpha / 255);
}