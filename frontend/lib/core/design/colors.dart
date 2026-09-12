import 'package:flutter/material.dart';

/// One immutable set of color values for a single brightness. AppColors
/// below exposes these as the app's actual token API; this class only
/// exists so dark and light can each be a complete, independently-designed
/// palette instead of one theme with a few fields flipped.
class _Palette {
  final Color background;
  final Color backgroundSecondary;
  final Color backgroundElevated;
  final Color backgroundOverlay;

  final Color surface;
  final Color surfaceSecondary;
  final Color surfaceElevated;
  final Color surfaceOverlay;
  final Color surfaceInteractive;

  final Color border;
  final Color borderStrong;
  final Color borderSubtle;
  final Color divider;

  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color primaryContainer;
  final Color onPrimary;
  final Color onPrimaryContainer;

  final Color success;
  final Color successLight;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color warningLight;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color danger;
  final Color dangerLight;
  final Color dangerContainer;
  final Color onDangerContainer;

  final Color info;
  final Color infoLight;
  final Color infoContainer;
  final Color onInfoContainer;

  final Color ai;
  final Color aiLight;
  final Color aiContainer;
  final Color onAiContainer;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textInverse;
  final Color textDisabled;

  final Color placeholder;
  final Color overlay;
  final Color scrim;

  final Color glass;
  final Color glassBorder;

  final List<Color> backgroundGradient;
  final List<Color> surfaceGradient;

  const _Palette({
    required this.background,
    required this.backgroundSecondary,
    required this.backgroundElevated,
    required this.backgroundOverlay,
    required this.surface,
    required this.surfaceSecondary,
    required this.surfaceElevated,
    required this.surfaceOverlay,
    required this.surfaceInteractive,
    required this.border,
    required this.borderStrong,
    required this.borderSubtle,
    required this.divider,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.primaryContainer,
    required this.onPrimary,
    required this.onPrimaryContainer,
    required this.success,
    required this.successLight,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningLight,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.danger,
    required this.dangerLight,
    required this.dangerContainer,
    required this.onDangerContainer,
    required this.info,
    required this.infoLight,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.ai,
    required this.aiLight,
    required this.aiContainer,
    required this.onAiContainer,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.textDisabled,
    required this.placeholder,
    required this.overlay,
    required this.scrim,
    required this.glass,
    required this.glassBorder,
    required this.backgroundGradient,
    required this.surfaceGradient,
  });
}

const _dark = _Palette(
  background: Color(0xFF050608),
  backgroundSecondary: Color(0xFF0A0C10),
  backgroundElevated: Color(0xFF0E1014),
  backgroundOverlay: Color(0xFF14161C),
  surface: Color(0xFF0E1014),
  surfaceSecondary: Color(0xFF14161C),
  surfaceElevated: Color(0xFF1A1E26),
  surfaceOverlay: Color(0xFF1E232D),
  surfaceInteractive: Color(0xFF1E232D),
  border: Color(0xFF242834),
  borderStrong: Color(0xFF2D3240),
  borderSubtle: Color(0xFF1E232D),
  divider: Color(0xFF242834),
  primary: Color(0xFF7C5CFF),
  primaryLight: Color(0xFF9B85FF),
  primaryDark: Color(0xFF5A3FE8),
  primaryContainer: Color(0xFF2A1F4D),
  onPrimary: Color(0xFFFFFFFF),
  onPrimaryContainer: Color(0xFFE8E0FF),
  success: Color(0xFF10B981),
  successLight: Color(0xFF34D399),
  successContainer: Color(0xFF064E33),
  onSuccessContainer: Color(0xFFA7F3D0),
  warning: Color(0xFFF59E0B),
  warningLight: Color(0xFFFBBF24),
  warningContainer: Color(0xFF78350F),
  onWarningContainer: Color(0xFFFDE68A),
  danger: Color(0xFFEF4444),
  dangerLight: Color(0xFFF87171),
  dangerContainer: Color(0xFF7F1D1D),
  onDangerContainer: Color(0xFFFCA5A5),
  info: Color(0xFF3B82F6),
  infoLight: Color(0xFF60A5FA),
  infoContainer: Color(0xFF1E3A5F),
  onInfoContainer: Color(0xFFBFDBFE),
  ai: Color(0xFF8B5CF6),
  aiLight: Color(0xFFA78BFA),
  aiContainer: Color(0xFF2E1A4E),
  onAiContainer: Color(0xFFDDD6FE),
  textPrimary: Color(0xFFF8FAFC),
  textSecondary: Color(0xFF94A3B8),
  textTertiary: Color(0xFF64748B),
  textInverse: Color(0xFF050608),
  textDisabled: Color(0xFF475569),
  placeholder: Color(0xFF475569),
  overlay: Color(0xCC050608),
  scrim: Color(0x99000000),
  glass: Color(0x1AFFFFFF),
  glassBorder: Color(0x1FFFFFFF),
  backgroundGradient: [Color(0xFF080A0F), Color(0xFF050608), Color(0xFF0A0C10)],
  surfaceGradient: [Color(0xFF14161C), Color(0xFF0E1014)],
);

// A real light palette, not an inverted dark one -- warm-neutral background
// (not stark white), white elevated surfaces, hairline borders, and the
// same brand hue family darkened just enough to hold AA contrast on white.
const _light = _Palette(
  background: Color(0xFFF7F7F9),
  backgroundSecondary: Color(0xFFF1F1F4),
  backgroundElevated: Color(0xFFFFFFFF),
  backgroundOverlay: Color(0xFFEAEAEF),
  surface: Color(0xFFFFFFFF),
  surfaceSecondary: Color(0xFFFBFBFC),
  surfaceElevated: Color(0xFFF2F2F5),
  surfaceOverlay: Color(0xFFEAEAEF),
  surfaceInteractive: Color(0xFFF0F0F4),
  border: Color(0xFFE3E3E9),
  borderStrong: Color(0xFFD2D2DA),
  borderSubtle: Color(0xFFEDEDF1),
  divider: Color(0xFFE3E3E9),
  primary: Color(0xFF6D4FE0),
  primaryLight: Color(0xFF8B72FF),
  primaryDark: Color(0xFF4F35B8),
  primaryContainer: Color(0xFFEBE6FF),
  onPrimary: Color(0xFFFFFFFF),
  onPrimaryContainer: Color(0xFF3D2B8C),
  success: Color(0xFF0E9F6E),
  successLight: Color(0xFF34D399),
  successContainer: Color(0xFFE3FCEF),
  onSuccessContainer: Color(0xFF03543F),
  warning: Color(0xFFB45309),
  warningLight: Color(0xFFF59E0B),
  warningContainer: Color(0xFFFEF3C7),
  onWarningContainer: Color(0xFF7C4A03),
  danger: Color(0xFFDC2626),
  dangerLight: Color(0xFFEF4444),
  dangerContainer: Color(0xFFFEE2E2),
  onDangerContainer: Color(0xFF8B1D1D),
  info: Color(0xFF2563EB),
  infoLight: Color(0xFF3B82F6),
  infoContainer: Color(0xFFDBEAFE),
  onInfoContainer: Color(0xFF1E3A6E),
  ai: Color(0xFF7C3AED),
  aiLight: Color(0xFF8B5CF6),
  aiContainer: Color(0xFFEEE5FF),
  onAiContainer: Color(0xFF4C1D95),
  textPrimary: Color(0xFF14151C),
  textSecondary: Color(0xFF5B5D6B),
  textTertiary: Color(0xFF8A8C99),
  textInverse: Color(0xFFFFFFFF),
  textDisabled: Color(0xFFB5B7C2),
  placeholder: Color(0xFF9A9CA8),
  overlay: Color(0xB3FFFFFF),
  scrim: Color(0x66000000),
  glass: Color(0x0A000000),
  glassBorder: Color(0x14000000),
  backgroundGradient: [Color(0xFFFBFBFD), Color(0xFFF7F7F9), Color(0xFFF1F1F4)],
  surfaceGradient: [Color(0xFFFFFFFF), Color(0xFFF7F7F9)],
);

/// The app's color tokens. Every field is a runtime-computed getter, not a
/// compile-time constant, because the same token needs to resolve to either
/// [_dark] or [_light] depending on the active theme -- set once, globally,
/// by ThemeController whenever the effective brightness changes (system
/// setting, or the user's explicit Light/Dark choice) and re-read on every
/// subsequent build. This is what actually makes light mode a first-class,
/// fully-themed experience instead of one inverted screen: every screen
/// already reads colors from here rather than duplicating literals, so
/// fixing the token source fixes every screen at once.
class AppColors {
  static Brightness _brightness = Brightness.dark;
  static _Palette get _p => _brightness == Brightness.dark ? _dark : _light;

  /// Called by ThemeController before triggering a rebuild. Not meant to be
  /// called from screens.
  static void setBrightness(Brightness brightness) {
    _brightness = brightness;
  }

  static Brightness get currentBrightness => _brightness;

  static Color get background => _p.background;
  static Color get backgroundSecondary => _p.backgroundSecondary;
  static Color get backgroundElevated => _p.backgroundElevated;
  static Color get backgroundOverlay => _p.backgroundOverlay;

  static Color get surface => _p.surface;
  static Color get surfaceSecondary => _p.surfaceSecondary;
  static Color get surfaceElevated => _p.surfaceElevated;
  static Color get surfaceOverlay => _p.surfaceOverlay;
  static Color get surfaceInteractive => _p.surfaceInteractive;

  static Color get border => _p.border;
  static Color get borderStrong => _p.borderStrong;
  static Color get borderSubtle => _p.borderSubtle;
  static Color get divider => _p.divider;

  static Color get primary => _p.primary;
  static Color get primaryLight => _p.primaryLight;
  static Color get primaryDark => _p.primaryDark;
  static Color get primaryContainer => _p.primaryContainer;
  static Color get onPrimary => _p.onPrimary;
  static Color get onPrimaryContainer => _p.onPrimaryContainer;

  static Color get success => _p.success;
  static Color get successLight => _p.successLight;
  static Color get successContainer => _p.successContainer;
  static Color get onSuccessContainer => _p.onSuccessContainer;

  static Color get warning => _p.warning;
  static Color get warningLight => _p.warningLight;
  static Color get warningContainer => _p.warningContainer;
  static Color get onWarningContainer => _p.onWarningContainer;

  static Color get danger => _p.danger;
  static Color get dangerLight => _p.dangerLight;
  static Color get dangerContainer => _p.dangerContainer;
  static Color get onDangerContainer => _p.onDangerContainer;

  static Color get info => _p.info;
  static Color get infoLight => _p.infoLight;
  static Color get infoContainer => _p.infoContainer;
  static Color get onInfoContainer => _p.onInfoContainer;

  static Color get ai => _p.ai;
  static Color get aiLight => _p.aiLight;
  static Color get aiContainer => _p.aiContainer;
  static Color get onAiContainer => _p.onAiContainer;

  static Color get textPrimary => _p.textPrimary;
  static Color get textSecondary => _p.textSecondary;
  static Color get textTertiary => _p.textTertiary;
  static Color get textInverse => _p.textInverse;
  static Color get textDisabled => _p.textDisabled;

  static Color get placeholder => _p.placeholder;
  static Color get overlay => _p.overlay;
  static Color get scrim => _p.scrim;

  static Color get glass => _p.glass;
  static Color get glassBorder => _p.glassBorder;

  static Color get accent => primary;
  static Color get accentSoft => primaryContainer;
  static Color get accentStrong => primaryLight;

  static LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _p.backgroundGradient,
        stops: const [0.0, 0.5, 1.0],
      );

  static LinearGradient get surfaceGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _p.surfaceGradient,
        stops: const [0.0, 1.0],
      );

  static LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, ai, Color.lerp(primary, ai, 0.5)!],
        stops: const [0.0, 0.5, 1.0],
      );

  static LinearGradient get successGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [success, Color.lerp(success, Colors.black, 0.15)!],
      );

  static LinearGradient get aiGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [ai, Color.lerp(ai, Colors.black, 0.15)!],
      );

  static LinearGradient get warningGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [warning, Color.lerp(warning, Colors.black, 0.15)!],
      );

  static LinearGradient get dangerGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [danger, Color.lerp(danger, Colors.black, 0.15)!],
      );
}

extension ColorExtensions on Color {
  Color withAlphaValue(int alpha) => withValues(alpha: alpha / 255);
}
