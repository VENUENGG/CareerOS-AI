import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../core/design/design.dart';
import '../../providers/app_providers.dart';

class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? initials;
  final double radius;
  final AvatarStyle? fallbackStyle;
  final VoidCallback? onTap;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.radius = 36,
    this.fallbackStyle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Consumer<AvatarController>(
      builder: (context, avatarController, _) {
        final effectiveFallback = fallbackStyle ?? avatarController.selectedStyle;

        return GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.primaryContainer,
            backgroundImage: hasImage ? NetworkImage(imageUrl!) : null,
            child: !hasImage ? _buildFallbackAvatar(effectiveFallback, radius) : null,
          ),
        );
      },
    );
  }

  Widget _buildFallbackAvatar(AvatarStyle style, double radius) {
    if (style == AvatarStyle.initials) {
      return Text(
        initials?.isNotEmpty == true ? initials! : '?',
        style: AppTypography.titleMedium.primary().copyWith(fontSize: radius * 0.7),
      );
    }
    return ClipOval(
      child: CustomPaint(
        size: Size(radius * 2, radius * 2),
        painter: _GeometricAvatarPainter(style: style),
      ),
    );
  }
}

class AvatarPicker extends StatelessWidget {
  final String? currentInitials;
  final ValueChanged<AvatarStyle> onSelect;
  final double radius;

  const AvatarPicker({
    super.key,
    this.currentInitials,
    required this.onSelect,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    final styles = AvatarStyle.values;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: AppSpacing.horizontalLg,
          child: Row(
            children: [
              Text('Choose Avatar', style: AppTypography.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: AppTypography.labelMedium),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: radius * 2 + 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.horizontalLg,
            itemCount: styles.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) {
              final style = styles[index];
              return Consumer<AvatarController>(
                builder: (context, avatarController, _) {
                  final isSelected = style == avatarController.selectedStyle;
                  return _AvatarOption(
                    style: style,
                    initials: currentInitials,
                    radius: radius,
                    isSelected: isSelected,
                    onTap: () {
                      onSelect(style);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _AvatarOption extends StatelessWidget {
  final AvatarStyle style;
  final String? initials;
  final double radius;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarOption({
    required this.style,
    this.initials,
    required this.radius,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      radius: AppRadii.lg,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        width: radius * 2 + 16,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAvatar(
              initials: initials,
              radius: radius,
              fallbackStyle: style,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              style.displayName,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              const SizedBox(height: AppSpacing.xs),
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

/// A cohesive set of abstract, geometric identity marks -- the deliberate
/// replacement for the previous literal-object set (bot/astronaut/rocket/
/// star/gear/sparkles/crown), which read as generic clip-art rather than a
/// premium product's avatar system. Each style below is a distinct abstract
/// composition (faceted forms, layered arcs, concentric rings, etc.) with
/// its own fixed, curated color pairing -- fixed rather than theme-derived
/// so a chosen avatar is a stable identity marker independent of light/dark
/// mode, and so avatars stop being uniformly purple across the app.
enum AvatarStyle {
  initials('Initials'),
  prism('Prism'),
  aurora('Aurora'),
  horizon('Horizon'),
  facet('Facet'),
  nebula('Nebula'),
  monolith('Monolith'),
  orbit('Orbit'),
  lattice('Lattice');

  const AvatarStyle(this.displayName);
  final String displayName;
}

class _GeometricAvatarPainter extends CustomPainter {
  final AvatarStyle style;

  const _GeometricAvatarPainter({required this.style});

  static const Map<AvatarStyle, List<Color>> _palettes = {
    AvatarStyle.prism: [Color(0xFF4F3BB8), Color(0xFF7C5CFF), Color(0xFFB09BFF)],
    AvatarStyle.aurora: [Color(0xFF0E7C66), Color(0xFF10B981), Color(0xFF6EE7C4)],
    AvatarStyle.horizon: [Color(0xFFB4530F), Color(0xFFF59E0B), Color(0xFFFFD98E)],
    AvatarStyle.facet: [Color(0xFF334155), Color(0xFF64748B), Color(0xFFB6C2D1)],
    AvatarStyle.nebula: [Color(0xFF6B21A8), Color(0xFFB44FD8), Color(0xFFE8B8FF)],
    AvatarStyle.monolith: [Color(0xFF1E2430), Color(0xFF3A4152), Color(0xFF8891A3)],
    AvatarStyle.orbit: [Color(0xFF0E5FA8), Color(0xFF3B82F6), Color(0xFF93C5FD)],
    AvatarStyle.lattice: [Color(0xFF14532D), Color(0xFF3F8F4F), Color(0xFF9BD9A6)],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final colors = _palettes[style] ?? _palettes[AvatarStyle.prism]!;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final center = rect.center;
    final r = size.width / 2;

    // Every style shares a soft diagonal backdrop wash in its own palette so
    // the set reads as one family, then layers a distinct motif on top.
    final backdrop = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colors[0], colors[1]],
      ).createShader(rect);
    canvas.drawRect(rect, backdrop);

    switch (style) {
      case AvatarStyle.initials:
        break;
      case AvatarStyle.prism:
        _paintPrism(canvas, center, r, colors);
      case AvatarStyle.aurora:
        _paintAurora(canvas, center, r, colors);
      case AvatarStyle.horizon:
        _paintHorizon(canvas, rect, r, colors);
      case AvatarStyle.facet:
        _paintFacet(canvas, center, r, colors);
      case AvatarStyle.nebula:
        _paintNebula(canvas, center, r, colors);
      case AvatarStyle.monolith:
        _paintMonolith(canvas, rect, r, colors);
      case AvatarStyle.orbit:
        _paintOrbit(canvas, center, r, colors);
      case AvatarStyle.lattice:
        _paintLattice(canvas, rect, r, colors);
    }
  }

  void _paintPrism(Canvas canvas, Offset c, double r, List<Color> colors) {
    // Three overlapping angular facets fanning from the center, each a
    // translucent tint of the palette's lightest tone.
    for (var i = 0; i < 3; i++) {
      final angle = -math.pi / 2 + i * (2 * math.pi / 3);
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + r * 1.1 * math.cos(angle - 0.5), c.dy + r * 1.1 * math.sin(angle - 0.5))
        ..lineTo(c.dx + r * 1.1 * math.cos(angle + 0.5), c.dy + r * 1.1 * math.sin(angle + 0.5))
        ..close();
      canvas.drawPath(path, Paint()..color = colors[2].withValues(alpha: 0.28 + i * 0.1));
    }
  }

  void _paintAurora(Canvas canvas, Offset c, double r, List<Color> colors) {
    // Soft overlapping radial blooms -- a flowing, weightless gradient
    // composition rather than a hard shape.
    final blooms = [
      (Offset(c.dx - r * 0.3, c.dy - r * 0.2), r * 0.75),
      (Offset(c.dx + r * 0.35, c.dy + r * 0.1), r * 0.65),
      (Offset(c.dx - r * 0.1, c.dy + r * 0.4), r * 0.5),
    ];
    for (final (pos, radius) in blooms) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [colors[2].withValues(alpha: 0.55), colors[2].withValues(alpha: 0.0)],
        ).createShader(Rect.fromCircle(center: pos, radius: radius));
      canvas.drawCircle(pos, radius, paint);
    }
  }

  void _paintHorizon(Canvas canvas, Rect rect, double r, List<Color> colors) {
    // Layered horizon bands rising from the bottom edge, like sunrise light.
    final c = rect.center;
    canvas.drawCircle(Offset(c.dx, c.dy - r * 0.15), r * 0.28, Paint()..color = colors[2].withValues(alpha: 0.9));
    for (var i = 0; i < 3; i++) {
      final bandTop = c.dy + r * (0.15 + i * 0.35);
      final band = Rect.fromLTRB(rect.left, bandTop, rect.right, rect.bottom);
      canvas.drawRect(band, Paint()..color = colors[0].withValues(alpha: 0.35 - i * 0.08));
    }
  }

  void _paintFacet(Canvas canvas, Offset c, double r, List<Color> colors) {
    // A faceted gem: a diamond split into shaded triangular panels.
    final top = Offset(c.dx, c.dy - r * 0.85);
    final bottom = Offset(c.dx, c.dy + r * 0.85);
    final left = Offset(c.dx - r * 0.75, c.dy - r * 0.1);
    final right = Offset(c.dx + r * 0.75, c.dy - r * 0.1);
    final mid = Offset(c.dx, c.dy + r * 0.15);

    void tri(Offset a, Offset b, Offset cc, double alpha) {
      canvas.drawPath(Path()..moveTo(a.dx, a.dy)..lineTo(b.dx, b.dy)..lineTo(cc.dx, cc.dy)..close(), Paint()..color = colors[2].withValues(alpha: alpha));
    }

    tri(top, left, mid, 0.55);
    tri(top, right, mid, 0.35);
    tri(left, mid, bottom, 0.45);
    tri(right, mid, bottom, 0.25);
  }

  void _paintNebula(Canvas canvas, Offset c, double r, List<Color> colors) {
    // A scattered cluster of soft circles, varying size -- restrained, not
    // busy: five elements, gentle overlap.
    final specks = [
      (Offset(c.dx - r * 0.35, c.dy - r * 0.3), r * 0.32),
      (Offset(c.dx + r * 0.25, c.dy - r * 0.4), r * 0.2),
      (Offset(c.dx + r * 0.4, c.dy + r * 0.2), r * 0.28),
      (Offset(c.dx - r * 0.15, c.dy + r * 0.4), r * 0.22),
      (Offset(c.dx + r * 0.05, c.dy - r * 0.05), r * 0.16),
    ];
    for (final (pos, radius) in specks) {
      canvas.drawCircle(pos, radius, Paint()..color = colors[2].withValues(alpha: 0.5));
    }
  }

  void _paintMonolith(Canvas canvas, Rect rect, double r, List<Color> colors) {
    // Two Bauhaus-style vertical bars of differing height plus one thin
    // accent line -- quiet, structural, confident.
    final c = rect.center;
    final barW = r * 0.34;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(c.dx - r * 0.55, c.dy - r * 0.5, barW, r * 1.05), const Radius.circular(3)),
      Paint()..color = colors[2].withValues(alpha: 0.85),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(c.dx + r * 0.05, c.dy - r * 0.75, barW, r * 1.4), const Radius.circular(3)),
      Paint()..color = colors[2].withValues(alpha: 0.5),
    );
    canvas.drawRect(Rect.fromLTWH(rect.left, c.dy + r * 0.62, rect.width, r * 0.06), Paint()..color = colors[2].withValues(alpha: 0.9));
  }

  void _paintOrbit(Canvas canvas, Offset c, double r, List<Color> colors) {
    // Three concentric, slightly offset rings plus a single orbiting dot.
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final radii = [r * 0.85, r * 0.6, r * 0.35];
    for (var i = 0; i < radii.length; i++) {
      canvas.drawCircle(c, radii[i], ringPaint..color = colors[2].withValues(alpha: 0.55 - i * 0.12)..strokeWidth = r * 0.06);
    }
    final dotAngle = -math.pi / 4;
    canvas.drawCircle(Offset(c.dx + radii[0] * math.cos(dotAngle), c.dy + radii[0] * math.sin(dotAngle)), r * 0.1, Paint()..color = colors[2]);
  }

  void _paintLattice(Canvas canvas, Rect rect, double r, List<Color> colors) {
    // A 3x3 grid of small rounded cells with varying opacity -- an orderly,
    // architectural pattern.
    final c = rect.center;
    final cell = r * 0.42;
    final gap = r * 0.12;
    final start = c - Offset(cell + gap, cell + gap);
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 3; col++) {
        final rr = Rect.fromLTWH(start.dx + col * (cell + gap), start.dy + row * (cell + gap), cell, cell);
        final alpha = 0.25 + ((row + col) % 3) * 0.2;
        canvas.drawRRect(RRect.fromRectAndRadius(rr, Radius.circular(cell * 0.28)), Paint()..color = colors[2].withValues(alpha: alpha));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GeometricAvatarPainter oldDelegate) => oldDelegate.style != style;
}
