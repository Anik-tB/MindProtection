import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MindProtectionLogo extends StatefulWidget {
  final double size;
  final bool showGlow;

  const MindProtectionLogo({
    super.key,
    this.size = 80,
    this.showGlow = true,
  });

  @override
  State<MindProtectionLogo> createState() => _MindProtectionLogoState();
}

class _MindProtectionLogoState extends State<MindProtectionLogo> {
  @override
  void initState() {
    super.initState();
    // Evict any cached legacy logo image from memory
    PaintingBinding.instance.imageCache.evict(const AssetImage('assets/logo.png'));
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final showGlow = widget.showGlow;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (showGlow)
          Container(
            width: size * 1.3,
            height: size * 1.3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.35),
                  const Color(0xFF00D4FF).withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E1428), Color(0xFF0B0712)],
            ),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.35),
                blurRadius: size * 0.3,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.50),
                blurRadius: size * 0.2,
                offset: Offset(0, size * 0.1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.26),
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.cover,
              key: ValueKey(DateTime.now().millisecondsSinceEpoch ~/ 10000),
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.shield_outlined,
                    color: AppTheme.primary,
                    size: size * 0.5,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
