import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  static const String fontFamily = 'Inter';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 56,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -1.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 44,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -1,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.15,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.1,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // Not `const` (unlike the styles above) because these two bake in a
  // color, and that color must track the active theme.
  static TextStyle get caption => TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.4,
        color: AppColors.textSecondary,
      );

  static TextStyle get overline => TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 1.5,
        color: AppColors.textTertiary,
      );

  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.15,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.1,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.5,
  );
}

extension TextStyleExtensions on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);
  TextStyle withSize(double size) => copyWith(fontSize: size);
  TextStyle withHeight(double height) => copyWith(height: height);
  TextStyle withLetterSpacing(double spacing) => copyWith(letterSpacing: spacing);
  // These read AppColors at call time (not compile-time literals) so text
  // styled with them still flips correctly when the theme changes.
  TextStyle muted() => copyWith(color: AppColors.textSecondary);
  TextStyle subtle() => copyWith(color: AppColors.textTertiary);
  TextStyle onSurface() => copyWith(color: AppColors.textPrimary);
  TextStyle onPrimary() => copyWith(color: AppColors.onPrimary);
  TextStyle primary() => copyWith(color: AppColors.primary);
  TextStyle success() => copyWith(color: AppColors.success);
  TextStyle warning() => copyWith(color: AppColors.warning);
  TextStyle danger() => copyWith(color: AppColors.danger);
  TextStyle ai() => copyWith(color: AppColors.ai);
}