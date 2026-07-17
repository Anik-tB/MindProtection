import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class LiquidBackground extends StatefulWidget {
  final Widget child;

  const LiquidBackground({super.key, required this.child});

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LiquidFieldPainter(progress: _animation.value),
                );
              },
            ),
          ),
          Positioned.fill(child: widget.child),
        ],
      ),
    );
  }
}

class LiquidGlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? tint;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const LiquidGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.radius = 22,
    this.tint,
    this.borderColor,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows ?? AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: tint ?? AppTheme.glassFill,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: borderColor ?? AppTheme.glassStroke,
                width: 1.2,
              ),
              gradient: tint == null ? AppTheme.cardGradient : null,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap == null) return panel;

    return _InteractiveLiquidPanel(
      onTap: onTap!,
      radius: radius,
      child: panel,
    );
  }
}

class _InteractiveLiquidPanel extends StatefulWidget {
  final VoidCallback onTap;
  final double radius;
  final Widget child;

  const _InteractiveLiquidPanel({
    required this.onTap,
    required this.radius,
    required this.child,
  });

  @override
  State<_InteractiveLiquidPanel> createState() => _InteractiveLiquidPanelState();
}

class _InteractiveLiquidPanelState extends State<_InteractiveLiquidPanel> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 160),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: widget.child,
      ),
    );
  }
}

class AppPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final Widget? trailing;

  const AppPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          LiquidIconBadge(icon: icon!, color: AppTheme.primary),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;

  const SectionTitle({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class LiquidIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;

  const LiquidIconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 46,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Icon(icon, color: color, size: iconSize),
    );
  }
}

class MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final IconData icon;
  final Color color;

  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LiquidIconBadge(icon: icon, color: color, size: 34, iconSize: 18),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                if (suffix != null) ...[
                  const SizedBox(width: 3),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      suffix!,
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool filled;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? AppTheme.onPrimary : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: filled ? 0 : 0.26)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: foreground, size: 14),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class GradientActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expanded;

  const GradientActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: AppTheme.onPrimary, size: 18),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: AppTheme.onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: onPressed == null ? null : AppTheme.primaryGradient,
        color: onPressed == null ? AppTheme.border : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed == null ? null : AppTheme.primaryGlow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            child: content,
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LiquidGlassPanel(
        padding: const EdgeInsets.all(24),
        shadows: const [],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LiquidIconBadge(
              icon: icon,
              color: AppTheme.primary,
              size: 60,
              iconSize: 28,
            ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}

class _LiquidFieldPainter extends CustomPainter {
  final double progress;

  const _LiquidFieldPainter({this.progress = 0.5});

  @override
  void paint(Canvas canvas, Size size) {
    final topCenter = Offset(
      size.width * (0.15 + 0.06 * progress),
      size.height * (0.15 + 0.04 * progress),
    );
    final topRadius = size.width * (0.58 + 0.06 * progress);

    // Top-left Bioluminescent Aurora Orb
    final topOrbPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00F5A0).withValues(alpha: 0.14),
          const Color(0xFF00D4FF).withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: topCenter, radius: topRadius));
    canvas.drawCircle(topCenter, topRadius, topOrbPaint);

    final bottomCenter = Offset(
      size.width * (0.85 - 0.06 * progress),
      size.height * (0.78 - 0.04 * progress),
    );
    final bottomRadius = size.width * (0.62 + 0.06 * progress);

    // Bottom-right Cyber Cyan Aurora Orb
    final bottomOrbPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00D4FF).withValues(alpha: 0.12),
          const Color(0xFF8A2BE2).withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: bottomCenter, radius: bottomRadius));
    canvas.drawCircle(bottomCenter, bottomRadius, bottomOrbPaint);

    // Smooth Aurora Wave 1
    final bandPaint1 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x1A00F5A0), Color(0x0000F5A0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);

    final firstBand = Path()
      ..moveTo(0, size.height * (0.06 + 0.02 * progress))
      ..cubicTo(
        size.width * 0.28,
        size.height * (0.01 - 0.01 * progress),
        size.width * 0.52,
        size.height * (0.16 + 0.02 * progress),
        size.width,
        size.height * (0.06 + 0.01 * progress),
      )
      ..lineTo(size.width, size.height * 0.24)
      ..cubicTo(
        size.width * 0.64,
        size.height * (0.34 + 0.02 * progress),
        size.width * 0.32,
        size.height * 0.16,
        0,
        size.height * (0.26 + 0.02 * progress),
      )
      ..close();

    // Smooth Aurora Wave 2
    final bandPaint2 = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x1800D4FF), Color(0x0000D4FF)],
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
      ).createShader(Offset.zero & size);

    final secondBand = Path()
      ..moveTo(0, size.height * (0.74 - 0.02 * progress))
      ..cubicTo(
        size.width * 0.36,
        size.height * (0.64 - 0.02 * progress),
        size.width * 0.62,
        size.height * (0.88 - 0.01 * progress),
        size.width,
        size.height * (0.74 - 0.02 * progress),
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(firstBand, bandPaint1);
    canvas.drawPath(secondBand, bandPaint2);
  }

  @override
  bool shouldRepaint(covariant _LiquidFieldPainter oldDelegate) => oldDelegate.progress != progress;
}
