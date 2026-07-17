import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../viewmodels/wellbeing_notifier.dart';
import '../../../gamification/presentation/views/guardian_sanctuary_modal.dart';

class BreathingExercisesView extends ConsumerStatefulWidget {
  const BreathingExercisesView({super.key});

  @override
  ConsumerState<BreathingExercisesView> createState() => _BreathingExercisesViewState();
}

class _BreathingExercisesViewState extends ConsumerState<BreathingExercisesView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _phaseTimer;
  Timer? _sessionTimer;

  int _selectedTechniqueIndex = 0;
  bool _isPlaying = false;
  bool _hapticsEnabled = true;
  int _phaseIndex = 0;
  int _secondsInPhaseRemaining = 0;
  int _totalSessionSeconds = 0;

  final List<_BreathingTechnique> _techniques = const [
    _BreathingTechnique(
      name: 'Box Breathing',
      subtitle: 'Focus & Stress Reset',
      description: 'Inhale, hold, exhale, and hold for equal intervals to reset anxiety and steady your pulse.',
      phases: [
        _BreathPhase(name: 'Inhale', duration: 4, scaleEnd: 1.0),
        _BreathPhase(name: 'Hold', duration: 4, scaleEnd: 1.0),
        _BreathPhase(name: 'Exhale', duration: 4, scaleEnd: 0.45),
        _BreathPhase(name: 'Hold', duration: 4, scaleEnd: 0.45),
      ],
      color: AppTheme.info,
    ),
    _BreathingTechnique(
      name: '4-7-8 Relaxing Breath',
      subtitle: 'Sleep & Deep Calm',
      description: 'A natural tranquilizer for the nervous system. Ideal when facing strong urges or insomnia.',
      phases: [
        _BreathPhase(name: 'Inhale', duration: 4, scaleEnd: 1.0),
        _BreathPhase(name: 'Hold', duration: 7, scaleEnd: 1.0),
        _BreathPhase(name: 'Exhale', duration: 8, scaleEnd: 0.4),
      ],
      color: AppTheme.primary,
    ),
    _BreathingTechnique(
      name: 'Coherent Breathing',
      subtitle: 'Balance & Presence',
      description: 'Gentle, steady rhythm of 5 seconds in and 5 seconds out to align heart rate variability.',
      phases: [
        _BreathPhase(name: 'Inhale', duration: 5, scaleEnd: 1.0),
        _BreathPhase(name: 'Exhale', duration: 5, scaleEnd: 0.45),
      ],
      color: AppTheme.accent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: 0.45,
    );
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    _sessionTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _selectTechnique(int index) {
    if (_hapticsEnabled) HapticFeedback.lightImpact();
    if (_isPlaying) _stopExercise();
    setState(() {
      _selectedTechniqueIndex = index;
      _phaseIndex = 0;
      _secondsInPhaseRemaining = _techniques[index].phases[0].duration;
      _controller.value = _techniques[index].phases[0].scaleEnd == 1.0 ? 0.45 : 1.0;
    });
  }

  void _toggleExercise() {
    if (_hapticsEnabled) HapticFeedback.heavyImpact();
    if (_isPlaying) {
      _stopExercise();
    } else {
      _startExercise();
    }
  }

  void _startExercise() {
    final technique = _techniques[_selectedTechniqueIndex];
    setState(() {
      _isPlaying = true;
      _phaseIndex = 0;
      _secondsInPhaseRemaining = technique.phases[0].duration;
    });

    _animateToPhase(technique.phases[0]);

    _phaseTimer?.cancel();
    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsInPhaseRemaining > 1) {
        if (_hapticsEnabled) HapticFeedback.lightImpact();
        setState(() => _secondsInPhaseRemaining--);
      } else {
        _nextPhase();
      }
    });

    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _totalSessionSeconds++);
    });
  }

  void _nextPhase() {
    final technique = _techniques[_selectedTechniqueIndex];
    final nextIndex = (_phaseIndex + 1) % technique.phases.length;
    final nextPhase = technique.phases[nextIndex];

    setState(() {
      _phaseIndex = nextIndex;
      _secondsInPhaseRemaining = nextPhase.duration;
    });

    if (_hapticsEnabled) HapticFeedback.mediumImpact();
    _animateToPhase(nextPhase);
  }

  void _animateToPhase(_BreathPhase phase) {
    _controller.animateTo(
      phase.scaleEnd,
      duration: Duration(seconds: phase.duration),
      curve: Curves.easeInOutSine,
    );
  }

  void _stopExercise() {
    _phaseTimer?.cancel();
    _sessionTimer?.cancel();
    _controller.stop();
    final completedSeconds = _totalSessionSeconds;
    setState(() {
      _isPlaying = false;
      _phaseIndex = 0;
      _secondsInPhaseRemaining = _techniques[_selectedTechniqueIndex].phases[0].duration;
      _totalSessionSeconds = 0;
    });

    if (completedSeconds >= 60) {
      final minutes = completedSeconds ~/ 60;
      ref.read(wellbeingNotifierProvider.notifier).logMindfulness(minutes);
      _showCompletionDialog(minutes);
    }
  }

  void _showCompletionDialog(int minutes) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceRaised,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const LiquidIconBadge(
              icon: Icons.auto_awesome_rounded,
              color: AppTheme.primary,
              size: 44,
              iconSize: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Session Complete!', style: Theme.of(ctx).textTheme.titleLarge),
            ),
          ],
        ),
        content: Text(
          'You completed $minutes mindful minute${minutes > 1 ? 's' : ''} of deep breathing! Logged to your daily wellbeing and awarded +${minutes * 5} XP for your Guardian Sanctuary.',
          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              GuardianSanctuaryModal.show(context);
            },
            icon: const Icon(Icons.storefront_rounded, size: 18),
            label: const Text('View Sanctuary Shop'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatSessionTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final technique = _techniques[_selectedTechniqueIndex];
    final currentPhase = technique.phases[_phaseIndex];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LiquidBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceRaised.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.glassStroke),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 18, color: AppTheme.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Guided Breathing Space',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() => _hapticsEnabled = !_hapticsEnabled);
                        if (_hapticsEnabled) HapticFeedback.mediumImpact();
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: StatusPill(
                        label: _hapticsEnabled ? 'Haptics ON' : 'Haptics OFF',
                        icon: _hapticsEnabled ? Icons.vibration_rounded : Icons.phone_android_rounded,
                        color: _hapticsEnabled ? AppTheme.primary : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    children: [
                      // Technique Selector Cards
                      SizedBox(
                        height: 104,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _techniques.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final tech = _techniques[index];
                            final isSelected = _selectedTechniqueIndex == index;
                            return GestureDetector(
                              onTap: () => _selectTechnique(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 240),
                                width: 170,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? tech.color.withValues(alpha: 0.18)
                                      : AppTheme.glassFill,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? tech.color
                                        : AppTheme.glassStroke,
                                    width: isSelected ? 2.0 : 1.2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      tech.name,
                                      style: GoogleFonts.outfit(
                                        color: isSelected ? tech.color : AppTheme.textPrimary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tech.subtitle,
                                      style: GoogleFonts.inter(
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      LiquidGlassPanel(
                        padding: const EdgeInsets.all(16),
                        radius: 18,
                        child: Row(
                          children: [
                            LiquidIconBadge(
                              icon: Icons.air_rounded,
                              color: technique.color,
                              size: 40,
                              iconSize: 20,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                technique.description,
                                style: GoogleFonts.inter(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Breathing Circle Animation
                      SizedBox(
                        height: 280,
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              final scale = _isPlaying ? _controller.value : 0.65;
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer Aura Ring
                                  Container(
                                    width: 250 * scale + 30,
                                    height: 250 * scale + 30,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: technique.color.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  // Inner Aura Ring
                                  Container(
                                    width: 230 * scale,
                                    height: 230 * scale,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: technique.color.withValues(alpha: 0.15),
                                    ),
                                  ),
                                  // Main Breathing Orb
                                  Container(
                                    width: 190 * scale,
                                    height: 190 * scale,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          technique.color.withValues(alpha: 0.8),
                                          technique.color.withValues(alpha: 0.45),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: technique.color.withValues(alpha: 0.35),
                                          blurRadius: 35,
                                          spreadRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _isPlaying
                                                ? currentPhase.name.toUpperCase()
                                                : 'READY',
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontSize: _isPlaying ? 22 : 24,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 2.0,
                                            ),
                                          ),
                                          if (_isPlaying) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '$_secondsInPhaseRemaining',
                                              style: GoogleFonts.outfit(
                                                color: Colors.white.withValues(alpha: 0.9),
                                                fontSize: 36,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Start/Stop Control Button
                      GestureDetector(
                        onTap: _toggleExercise,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: _isPlaying
                                ? LinearGradient(colors: [
                                    AppTheme.error.withValues(alpha: 0.8),
                                    AppTheme.error,
                                  ])
                                : LinearGradient(colors: [
                                    technique.color.withValues(alpha: 0.8),
                                    technique.color,
                                  ]),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: (_isPlaying ? AppTheme.error : technique.color)
                                    .withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isPlaying
                                      ? Icons.stop_circle_outlined
                                      : Icons.play_circle_fill_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _isPlaying ? 'END SESSION' : 'START BREATHING',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Session Counter / Stats
                      if (_totalSessionSeconds > 0)
                        LiquidGlassPanel(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          radius: 16,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer_outlined,
                                  color: AppTheme.textSecondary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Total Session Time: ${_formatSessionTime(_totalSessionSeconds)}',
                                style: GoogleFonts.inter(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathingTechnique {
  final String name;
  final String subtitle;
  final String description;
  final List<_BreathPhase> phases;
  final Color color;

  const _BreathingTechnique({
    required this.name,
    required this.subtitle,
    required this.description,
    required this.phases,
    required this.color,
  });
}

class _BreathPhase {
  final String name;
  final int duration;
  final double scaleEnd;

  const _BreathPhase({
    required this.name,
    required this.duration,
    required this.scaleEnd,
  });
}
