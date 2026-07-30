import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../viewmodels/wellbeing_notifier.dart';

class GuidedMeditationPlayerView extends ConsumerStatefulWidget {
  const GuidedMeditationPlayerView({super.key});

  @override
  ConsumerState<GuidedMeditationPlayerView> createState() =>
      _GuidedMeditationPlayerViewState();
}

class _GuidedMeditationPlayerViewState
    extends ConsumerState<GuidedMeditationPlayerView>
    with SingleTickerProviderStateMixin {
  int _selectedTrackIndex = 0;
  bool _isPlaying = false;
  int _secondsElapsed = 0;
  Timer? _timer;

  // Soundscape levels (0.0 to 1.0)
  double _rainVolume = 0.6;
  double _wavesVolume = 0.4;
  double _forestVolume = 0.0;
  double _whiteNoiseVolume = 0.0;

  late AnimationController _animController;

  static const List<Map<String, dynamic>> _tracks = [
    {
      'title': '4-7-8 Deep Stress Release',
      'durationMinutes': 5,
      'type': 'Breathing Protocol',
      'icon': Icons.spa_rounded,
      'color': Color(0xFF00D4FF),
      'description':
          'Inhale 4s, Hold 7s, Exhale 8s. Instantly lowers heart rate and parasympathetic stress.',
    },
    {
      'title': 'Alpha Wave Focus Flow',
      'durationMinutes': 10,
      'type': 'Cognitive Enhancement',
      'icon': Icons.psychology_rounded,
      'color': Color(0xFF00F5A0),
      'description':
          '10Hz binaural frequency simulation designed to lock your brain into flow state.',
    },
    {
      'title': 'Body Scan Urge Surfing',
      'durationMinutes': 7,
      'type': 'Recovery CBT',
      'icon': Icons.self_improvement_rounded,
      'color': Color(0xFFFFB800),
      'description':
          'Mindfully observe physical craving sensations without reacting or giving in.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          _secondsElapsed++;
        });

        final targetSec =
            (_tracks[_selectedTrackIndex]['durationMinutes'] as int) * 60;
        if (_secondsElapsed >= targetSec) {
          _completeSession();
        }
      });
    } else {
      _timer?.cancel();
    }
  }

  void _completeSession() {
    _timer?.cancel();
    final mins = _tracks[_selectedTrackIndex]['durationMinutes'] as int;
    ref.read(wellbeingNotifierProvider.notifier).logMindfulness(mins);

    setState(() {
      _isPlaying = false;
      _secondsElapsed = 0;
    });

    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.stars_rounded, color: Color(0xFF00F5A0)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Session Complete! +$mins Mindful Minutes logged to your Vault.',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  String _formatTime(int totalSec) {
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final track = _tracks[_selectedTrackIndex];
    final color = track['color'] as Color;
    final totalSec = (track['durationMinutes'] as int) * 60;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mindfulness Soundscapes',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: LiquidBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Interactive Visualizer Player Card ──
                LiquidGlassPanel(
                  padding: const EdgeInsets.all(24),
                  radius: 28,
                  child: Column(
                    children: [
                      // Animated Pulsing Core
                      AnimatedBuilder(
                        animation: _animController,
                        builder: (context, child) {
                          final pulse = _isPlaying
                              ? 1.0 + (_animController.value * 0.18)
                              : 1.0;
                          return Transform.scale(
                            scale: pulse,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    color.withValues(alpha: 0.8),
                                    color.withValues(alpha: 0.2),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.45),
                                    blurRadius: 36,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                track['icon'] as IconData,
                                color: Colors.white,
                                size: 54,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      Text(
                        track['title'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        track['type'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Timer readout
                      Text(
                        '${_formatTime(_secondsElapsed)} / ${_formatTime(totalSec)}',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Play/Pause Button
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Ambient Soundscape Mixer ──
                Text(
                  'Ambient Soundscape Mixer',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                LiquidGlassPanel(
                  padding: const EdgeInsets.all(18),
                  radius: 22,
                  child: Column(
                    children: [
                      _SoundSlider(
                        label: 'Rainfall',
                        icon: Icons.water_drop_rounded,
                        color: const Color(0xFF00D4FF),
                        value: _rainVolume,
                        onChanged: (v) => setState(() => _rainVolume = v),
                      ),
                      const Divider(height: 18),
                      _SoundSlider(
                        label: 'Ocean Waves',
                        icon: Icons.waves_rounded,
                        color: const Color(0xFF00F5A0),
                        value: _wavesVolume,
                        onChanged: (v) => setState(() => _wavesVolume = v),
                      ),
                      const Divider(height: 18),
                      _SoundSlider(
                        label: 'Forest Wind',
                        icon: Icons.forest_rounded,
                        color: const Color(0xFFFFB800),
                        value: _forestVolume,
                        onChanged: (v) => setState(() => _forestVolume = v),
                      ),
                      const Divider(height: 18),
                      _SoundSlider(
                        label: 'Cosmos White Noise',
                        icon: Icons.graphic_eq_rounded,
                        color: const Color(0xFFA29BFE),
                        value: _whiteNoiseVolume,
                        onChanged: (v) => setState(() => _whiteNoiseVolume = v),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Guided Track Presets ──
                Text(
                  'Guided Session Presets',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                ...List.generate(_tracks.length, (idx) {
                  final t = _tracks[idx];
                  final isSel = idx == _selectedTrackIndex;
                  final tColor = t['color'] as Color;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: LiquidGlassPanel(
                      padding: const EdgeInsets.all(16),
                      radius: 20,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedTrackIndex = idx;
                          _isPlaying = false;
                          _secondsElapsed = 0;
                          _timer?.cancel();
                        });
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? tColor
                                  : tColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              t['icon'] as IconData,
                              color: isSel ? Colors.black : tColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t['title'] as String,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  t['description'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: tColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${t['durationMinutes']}m',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: tColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SoundSlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double value;
  final ValueChanged<double> onChanged;

  const _SoundSlider({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            activeColor: color,
            inactiveColor: AppTheme.surfaceRaised,
            onChanged: onChanged,
          ),
        ),
        Text(
          '${(value * 100).toInt()}%',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
