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
    switch (style) {
      case AvatarStyle.initials:
        return Text(
          initials?.isNotEmpty == true ? initials! : '?',
          style: AppTypography.titleMedium.primary().copyWith(fontSize: radius * 0.7),
        );
      case AvatarStyle.bot:
        return _buildBotAvatar(radius);
      case AvatarStyle.astronaut:
        return _buildAstronautAvatar(radius);
      case AvatarStyle.rocket:
        return _buildRocketAvatar(radius);
      case AvatarStyle.star:
        return _buildStarAvatar(radius);
      case AvatarStyle.gear:
        return _buildGearAvatar(radius);
      case AvatarStyle.sparkles:
        return _buildSparklesAvatar(radius);
      case AvatarStyle.crown:
        return _buildCrownAvatar(radius);
    }
  }

  Widget _buildBotAvatar(double radius) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: _BotAvatarPainter(radius: radius, color: AppColors.primary),
    );
  }

  Widget _buildAstronautAvatar(double radius) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: _AstronautAvatarPainter(radius: radius, color: AppColors.primary),
    );
  }

  Widget _buildRocketAvatar(double radius) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: _RocketAvatarPainter(radius: radius, color: AppColors.primary),
    );
  }

  Widget _buildStarAvatar(double radius) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: _StarAvatarPainter(radius: radius, color: AppColors.primary),
    );
  }

  Widget _buildGearAvatar(double radius) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: _GearAvatarPainter(radius: radius, color: AppColors.primary),
    );
  }

  Widget _buildSparklesAvatar(double radius) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: _SparklesAvatarPainter(radius: radius, color: AppColors.primary),
    );
  }

  Widget _buildCrownAvatar(double radius) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: _CrownAvatarPainter(radius: radius, color: AppColors.primary),
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

enum AvatarStyle {
  initials('Initials'),
  bot('Bot'),
  astronaut('Astronaut'),
  rocket('Rocket'),
  star('Star'),
  gear('Gear'),
  sparkles('Sparkles'),
  crown('Crown');

  const AvatarStyle(this.displayName);
  final String displayName;
}

class _BotAvatarPainter extends CustomPainter {
  final double radius;
  final Color color;

  _BotAvatarPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = radius / 36.0;
    final headPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7C5CFF), Color(0xFF8B5CF6), Color(0xFF6366F1)],
      ).createShader(Rect.fromLTWH(0, 0, 36 * scale, 36 * scale))
      ..style = PaintingStyle.fill;
    final accentPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx - 18 * scale, center.dy - 18 * scale);
    canvas.scale(scale);

    final headRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(4, 2, 28, 22),
      const Radius.circular(4),
    );
    canvas.drawRRect(headRect, headPaint);

    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(12, 12), 2.5, eyePaint);
    canvas.drawCircle(const Offset(24, 12), 2.5, eyePaint);

    final antennaPaint = Paint()..color = const Color(0xFF7C5CFF)..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(12, 2), const Offset(12, -6), antennaPaint);
    canvas.drawCircle(const Offset(12, -8), 2, accentPaint);

    final bodyRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(6, 26, 24, 18),
      const Radius.circular(3),
    );
    canvas.drawRRect(bodyRect, headPaint);

    final armPaint = Paint()..color = const Color(0xFF7C5CFF)..strokeWidth = 3..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(4, 30), const Offset(-2, 38), armPaint);
    canvas.drawLine(const Offset(32, 30), const Offset(38, 38), armPaint);

    canvas.drawLine(const Offset(12, 44), const Offset(12, 52), Paint()..color = const Color(0xFF7C5CFF)..strokeWidth = 3);
    canvas.drawLine(const Offset(24, 44), const Offset(24, 52), Paint()..color = const Color(0xFF7C5CFF)..strokeWidth = 3);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AstronautAvatarPainter extends CustomPainter {
  final double radius;
  final Color color;

  _AstronautAvatarPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = radius / 36.0;
    final helmetPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7C5CFF), Color(0xFF8B5CF6)],
      ).createShader(Rect.fromLTWH(0, 0, 36 * scale, 36 * scale))
      ..style = PaintingStyle.fill;
    final visorPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
      ).createShader(Rect.fromLTWH(8 * scale, 8 * scale, 20 * scale, 22 * scale))
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx - 18 * scale, center.dy - 18 * scale);
    canvas.scale(scale);

    final helmetPath = Path()
      ..moveTo(18, 2)
      ..quadraticBezierTo(34, 2, 34, 16)
      ..lineTo(34, 28)
      ..quadraticBezierTo(34, 34, 18, 34)
      ..quadraticBezierTo(2, 34, 2, 28)
      ..lineTo(2, 16)
      ..quadraticBezierTo(2, 2, 18, 2)
      ..close();
    canvas.drawPath(helmetPath, helmetPaint);

    final visorPath = Path()
      ..moveTo(18, 8)
      ..quadraticBezierTo(28, 8, 28, 18)
      ..lineTo(28, 26)
      ..quadraticBezierTo(28, 30, 18, 30)
      ..quadraticBezierTo(8, 30, 8, 26)
      ..lineTo(8, 18)
      ..quadraticBezierTo(8, 8, 18, 8)
      ..close();
    canvas.drawPath(visorPath, visorPaint);

    final badgePaint = Paint()..color = const Color(0xFFF59E0B)..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(28, 10), 4, badgePaint);

    final bodyPaint = Paint()..color = const Color(0xFF7C5CFF)..strokeWidth = 3..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(18, 34), const Offset(18, 42), bodyPaint);
    canvas.drawLine(const Offset(18, 38), const Offset(10, 46), bodyPaint);
    canvas.drawLine(const Offset(18, 38), const Offset(26, 46), bodyPaint);
    canvas.drawLine(const Offset(18, 42), const Offset(12, 50), bodyPaint);
    canvas.drawLine(const Offset(18, 42), const Offset(24, 50), bodyPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RocketAvatarPainter extends CustomPainter {
  final double radius;
  final Color color;

  _RocketAvatarPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = radius / 36.0;
    final rocketPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF7C5CFF), Color(0xFF8B5CF6)],
      ).createShader(Rect.fromLTWH(0, 0, 36 * scale, 36 * scale))
      ..style = PaintingStyle.fill;
    final windowPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
      ).createShader(Rect.fromLTWH(12 * scale, 10 * scale, 12 * scale, 12 * scale))
      ..style = PaintingStyle.fill;
    final flamePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFF87171)],
      ).createShader(Rect.fromLTWH(0, 30 * scale, 36 * scale, 12 * scale))
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx - 18 * scale, center.dy - 18 * scale);
    canvas.scale(scale);

    final rocketPath = Path()
      ..moveTo(18, 2)
      ..lineTo(24, 16)
      ..lineTo(30, 16)
      ..lineTo(26, 8)
      ..lineTo(34, 30)
      ..lineTo(2, 30)
      ..lineTo(10, 16)
      ..lineTo(16, 16)
      ..close();
    canvas.drawPath(rocketPath, rocketPaint);

    final windowRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(12, 10, 12, 12),
      const Radius.circular(3),
    );
    canvas.drawRRect(windowRect, windowPaint);

    final finPaint = Paint()..color = const Color(0xFF7C5CFF)..style = PaintingStyle.fill;
    canvas.drawPath(Path()
      ..moveTo(2, 30)
      ..lineTo(-2, 38)
      ..lineTo(10, 30)
      ..close(), finPaint);
    canvas.drawPath(Path()
      ..moveTo(34, 30)
      ..lineTo(38, 38)
      ..lineTo(26, 30)
      ..close(), finPaint);

    canvas.drawPath(Path()
      ..moveTo(10, 30)
      ..lineTo(14, 40)
      ..lineTo(18, 30)
      ..close(), flamePaint);
    canvas.drawPath(Path()
      ..moveTo(18, 30)
      ..lineTo(22, 42)
      ..lineTo(26, 30)
      ..close(), flamePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarAvatarPainter extends CustomPainter {
  final double radius;
  final Color color;

  _StarAvatarPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = radius / 36.0;
    final starPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24), Color(0xFFFEF08A)],
      ).createShader(Rect.fromLTWH(-22 * scale, -22 * scale, 44 * scale, 44 * scale))
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFEF08A), Color(0xFFF59E0B), Color(0x00F59E0B)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: 12 * scale))
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);

    const outerRadius = 22.0;
    const innerRadius = 9.0;
    final starPath = Path()
      ..moveTo(0, -outerRadius)
      ..lineTo(innerRadius * math.cos(3.14159 / 5), -innerRadius * math.sin(3.14159 / 5))
      ..lineTo(outerRadius * math.cos(2 * 3.14159 / 5 - 3.14159 / 2), outerRadius * math.sin(2 * 3.14159 / 5 - 3.14159 / 2))
      ..lineTo(innerRadius * math.cos(3 * 3.14159 / 5 - 3.14159 / 2), innerRadius * math.sin(3 * 3.14159 / 5 - 3.14159 / 2))
      ..lineTo(-outerRadius * math.cos(3.14159 / 5), outerRadius * math.sin(3.14159 / 5))
      ..lineTo(-innerRadius * math.cos(3.14159 / 5), -innerRadius * math.sin(3.14159 / 5))
      ..lineTo(-outerRadius * math.cos(2 * 3.14159 / 5 - 3.14159 / 2), -outerRadius * math.sin(2 * 3.14159 / 5 - 3.14159 / 2))
      ..lineTo(-innerRadius * math.cos(3 * 3.14159 / 5 - 3.14159 / 2), -innerRadius * math.sin(3 * 3.14159 / 5 - 3.14159 / 2))
      ..lineTo(innerRadius * math.cos(4 * 3.14159 / 5 - 3.14159 / 2), -innerRadius * math.sin(4 * 3.14159 / 5 - 3.14159 / 2))
      ..lineTo(outerRadius * math.cos(3.14159 / 5), outerRadius * math.sin(3.14159 / 5))
      ..close();
    canvas.drawPath(starPath, starPaint);

    final glowPath = Path()
      ..addOval(Rect.fromCircle(center: Offset.zero, radius: 6));
    canvas.drawPath(glowPath, glowPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GearAvatarPainter extends CustomPainter {
  final double radius;
  final Color color;

  _GearAvatarPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = radius / 36.0;
    final gearPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7C5CFF), Color(0xFF6366F1), Color(0xFF8B5CF6)],
      ).createShader(Rect.fromLTWH(-22 * scale, -22 * scale, 44 * scale, 44 * scale))
      ..style = PaintingStyle.fill;
    final holePaint = Paint()..color = AppColors.surface..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);

    final teeth = 12;
    final outerRadius = 22.0;
    final innerRadius = 16.0;
    final holeRadius = 6.0;

    final gearPath = Path();
    for (int i = 0; i < teeth * 2; i++) {
      final angle = i * 3.14159 / teeth;
      final r = i.isEven ? outerRadius : innerRadius;
      final x = r * math.cos(angle);
      final y = r * math.sin(angle);
      if (i == 0) {
        gearPath.moveTo(x, y);
      } else {
        gearPath.lineTo(x, y);
      }
    }
    gearPath.close();
    canvas.drawPath(gearPath, gearPaint);

    canvas.drawCircle(Offset.zero, holeRadius, holePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SparklesAvatarPainter extends CustomPainter {
  final double radius;
  final Color color;

  _SparklesAvatarPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = radius / 36.0;
    final sparklePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24), Color(0xFFFEF08A), Color(0xFFFFFFFF)],
      ).createShader(Rect.fromLTWH(-22 * scale, -22 * scale, 44 * scale, 44 * scale))
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);

    _drawSparkle(canvas, sparklePaint, 0, -16, 10);
    _drawSparkle(canvas, sparklePaint, 14, 10, 8);
    _drawSparkle(canvas, sparklePaint, -14, 10, 8);
    _drawSparkle(canvas, sparklePaint, -6, -4, 5);
    _drawSparkle(canvas, sparklePaint, 8, -8, 4);
    _drawSparkle(canvas, sparklePaint, 0, 18, 3);

    canvas.restore();
  }

  void _drawSparkle(Canvas canvas, Paint paint, double cx, double cy, double size) {
    final path = Path()
      ..moveTo(cx, cy - size)
      ..lineTo(cx + size * 0.3, cy - size * 0.3)
      ..lineTo(cx + size, cy)
      ..lineTo(cx + size * 0.3, cy + size * 0.3)
      ..lineTo(cx, cy + size)
      ..lineTo(cx - size * 0.3, cy + size * 0.3)
      ..lineTo(cx - size, cy)
      ..lineTo(cx - size * 0.3, cy - size * 0.3)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CrownAvatarPainter extends CustomPainter {
  final double radius;
  final Color color;

  _CrownAvatarPainter({required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = radius / 36.0;
    final crownPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24), Color(0xFFFEF08A), Color(0xFFFFFFFF)],
      ).createShader(Rect.fromLTWH(0, 0, 36 * scale, 36 * scale))
      ..style = PaintingStyle.fill;
    final jewelPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      ).createShader(Rect.fromLTWH(0, 0, 36 * scale, 36 * scale))
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx - 18 * scale, center.dy - 18 * scale);
    canvas.scale(scale);

    final crownPath = Path()
      ..moveTo(2, 30)
      ..lineTo(2, 20)
      ..quadraticBezierTo(6, 10, 10, 20)
      ..lineTo(10, 30)
      ..moveTo(10, 20)
      ..quadraticBezierTo(14, 6, 18, 20)
      ..lineTo(18, 30)
      ..moveTo(18, 20)
      ..quadraticBezierTo(22, 10, 26, 20)
      ..lineTo(26, 30)
      ..moveTo(26, 20)
      ..quadraticBezierTo(30, 10, 34, 20)
      ..lineTo(34, 30)
      ..close();
    canvas.drawPath(crownPath, crownPaint);

    canvas.drawCircle(const Offset(10, 20), 3, jewelPaint);
    canvas.drawCircle(const Offset(18, 6), 4, jewelPaint);
    canvas.drawCircle(const Offset(26, 20), 3, jewelPaint);

    final basePaint = Paint()..color = const Color(0xFFF59E0B)..style = PaintingStyle.fill;
    canvas.drawRect(const Rect.fromLTWH(2, 30, 32, 4), basePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}