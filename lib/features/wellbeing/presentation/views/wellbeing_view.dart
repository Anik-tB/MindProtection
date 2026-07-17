import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../viewmodels/wellbeing_notifier.dart';
import 'breathing_exercises_view.dart';

class WellbeingView extends ConsumerStatefulWidget {
  const WellbeingView({super.key});

  @override
  ConsumerState<WellbeingView> createState() => _WellbeingViewState();
}

class _WellbeingViewState extends ConsumerState<WellbeingView> {
  Timer? _eyeCareTimer;
  int _eyeCareSecondsRemaining = 1200;
  bool _isEyeCareRunning = false;

  void _toggleEyeCare() {
    HapticFeedback.mediumImpact();
    if (_isEyeCareRunning) {
      _eyeCareTimer?.cancel();
      setState(() {
        _isEyeCareRunning = false;
        _eyeCareSecondsRemaining = 1200;
      });
      return;
    }

    setState(() => _isEyeCareRunning = true);
    _eyeCareTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_eyeCareSecondsRemaining > 0) {
        setState(() => _eyeCareSecondsRemaining--);
      } else {
        timer.cancel();
        setState(() {
          _isEyeCareRunning = false;
          _eyeCareSecondsRemaining = 1200;
        });
        _showEyeCareAlert();
      }
    });
  }

  void _showEyeCareAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const LiquidIconBadge(
              icon: Icons.remove_red_eye_rounded,
              color: AppTheme.info,
              size: 40,
              iconSize: 19,
            ),
            const SizedBox(width: 10),
            Text('Eye care break', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        content: Text(
          'It has been 20 minutes of screen time. Look at something 20 feet away for 20 seconds.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSleepDialog(BuildContext context, double currentSleep) {
    final controller =
        TextEditingController(text: currentSleep > 0 ? '$currentSleep' : '8.0');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Log sleep hours', style: Theme.of(ctx).textTheme.titleLarge),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Hours slept last night',
            suffixText: 'hrs',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final hours = double.tryParse(controller.text) ?? 8.0;
              await ref.read(wellbeingNotifierProvider.notifier).updateSleep(hours);
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sleep logged ($hours hrs). Rest is fuel for focus!'),
                    backgroundColor: AppTheme.secondary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _eyeCareTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final logStream = ref.watch(todayWellbeingLogProvider);
    final log = logStream.value;
    final waterIntake = log?.waterIntakeLiters ?? 0.0;
    final sleepHours = log?.sleepDurationHours ?? 0.0;
    final mood = log?.moodRating ?? 3;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 145),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'Wellbeing',
                subtitle: 'Tune the body so the mind can stay steady.',
                icon: Icons.favorite_rounded,
              ),
              const SizedBox(height: 22),
              const SectionTitle(title: 'Hydration'),
              const SizedBox(height: 12),
              _HydrationCard(
                waterIntake: waterIntake,
                onAddWater: (liters) {
                  HapticFeedback.lightImpact();
                  ref.read(wellbeingNotifierProvider.notifier).addWater(liters);
                },
              ),
              const SizedBox(height: 22),
              const SectionTitle(title: 'Sleep and mood'),
              const SizedBox(height: 12),
              _SleepCard(
                sleepHours: sleepHours,
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showSleepDialog(context, sleepHours);
                },
              ),
              const SizedBox(height: 12),
              _MoodCard(
                mood: mood,
                onMoodSelected: (rating) {
                  HapticFeedback.mediumImpact();
                  ref.read(wellbeingNotifierProvider.notifier).logMood(rating);
                  final moodText = _MoodCard.labels[rating - 1];
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mood logged: $moodText. +10 XP for self-awareness!'),
                      backgroundColor: AppTheme.accent.withValues(alpha: 0.95),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 22),
              const SectionTitle(title: 'Eye care'),
              const SizedBox(height: 12),
              _EyeCareCard(
                isRunning: _isEyeCareRunning,
                secondsRemaining: _eyeCareSecondsRemaining,
                formatDuration: _formatDuration,
                onToggle: _toggleEyeCare,
              ),
              const SizedBox(height: 22),
              const SectionTitle(title: 'Mindfulness'),
              const SizedBox(height: 12),
              _BreathingCard(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BreathingExercisesView()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HydrationCard extends StatelessWidget {
  final double waterIntake;
  final ValueChanged<double> onAddWater;

  const _HydrationCard({
    required this.waterIntake,
    required this.onAddWater,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (waterIntake / 2.0).clamp(0.0, 1.0);

    return LiquidGlassPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LiquidIconBadge(
                icon: Icons.water_drop_rounded,
                color: AppTheme.info,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hydration goal', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      '${waterIntake.toStringAsFixed(1)}L of 2.0L',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.outfit(
                  color: AppTheme.info,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.info),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _WaterButton(label: '+250ml', onTap: () => onAddWater(0.25)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _WaterButton(
                  label: '+500ml',
                  filled: true,
                  onTap: () => onAddWater(0.5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _WaterButton(label: '+1L', onTap: () => onAddWater(1.0)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _WaterButton({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: filled ? AppTheme.primaryGradient : null,
            color: filled ? null : AppTheme.surfaceRaised,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: filled ? AppTheme.primary : AppTheme.border,
              width: 1.2,
            ),
            boxShadow: filled ? AppTheme.primaryGlow : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: GoogleFonts.inter(
                color: filled ? AppTheme.onPrimary : AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SleepCard extends StatelessWidget {
  final double sleepHours;
  final VoidCallback onTap;

  const _SleepCard({
    required this.sleepHours,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(18),
      onTap: onTap,
      child: Row(
        children: [
          const LiquidIconBadge(
            icon: Icons.nightlight_round,
            color: AppTheme.secondary,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sleep duration', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  sleepHours > 0 ? '${sleepHours.toStringAsFixed(1)} hours logged' : 'No sleep logged today',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                sleepHours > 0 ? '${sleepHours.toStringAsFixed(1)}h' : 'Unset',
                style: GoogleFonts.outfit(
                  color: AppTheme.secondary,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 2),
              Text('Goal: 7-9 hrs', style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final int mood;
  final ValueChanged<int> onMoodSelected;

  const _MoodCard({
    required this.mood,
    required this.onMoodSelected,
  });

  static const labels = ['Bad', 'Low', 'OK', 'Good', 'Great'];
  static const icons = [
    Icons.sentiment_very_dissatisfied_rounded,
    Icons.sentiment_dissatisfied_rounded,
    Icons.sentiment_neutral_rounded,
    Icons.sentiment_satisfied_alt_rounded,
    Icons.sentiment_very_satisfied_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final safeMood = mood.clamp(1, 5);

    return LiquidGlassPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LiquidIconBadge(
                icon: Icons.wb_sunny_rounded,
                color: AppTheme.accent,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mood tracking', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      'Log how you feel throughout the day.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                labels[safeMood - 1],
                style: GoogleFonts.outfit(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: List.generate(5, (index) {
              final rating = index + 1;
              final isSelected = safeMood == rating;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 4 ? 8.0 : 0.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onMoodSelected(rating),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.accent.withValues(alpha: 0.18)
                              : AppTheme.surfaceRaised,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.accent
                                : AppTheme.border,
                            width: isSelected ? 1.4 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.accent.withValues(alpha: 0.25),
                                    blurRadius: 12,
                                  )
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icons[index],
                              color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                              size: isSelected ? 26 : 22,
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                labels[index],
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? AppTheme.accent : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _EyeCareCard extends StatelessWidget {
  final bool isRunning;
  final int secondsRemaining;
  final String Function(int) formatDuration;
  final VoidCallback onToggle;

  const _EyeCareCard({
    required this.isRunning,
    required this.secondsRemaining,
    required this.formatDuration,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = isRunning ? AppTheme.info : AppTheme.primary;

    return LiquidGlassPanel(
      padding: const EdgeInsets.all(16),
      borderColor: isRunning ? AppTheme.info.withValues(alpha: 0.28) : null,
      child: Row(
        children: [
          LiquidIconBadge(
            icon: Icons.remove_red_eye_rounded,
            color: color,
            size: 44,
            iconSize: 21,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Eye care 20-20-20', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  isRunning
                      ? '${formatDuration(secondsRemaining)} remaining'
                      : 'Look 20 feet away after 20 minutes.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isRunning ? AppTheme.info : AppTheme.textSecondary,
                        fontWeight: isRunning ? FontWeight.w800 : FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          isRunning
              ? OutlinedButton(onPressed: onToggle, child: const Text('Stop'))
              : GradientActionButton(
                  label: 'Start',
                  expanded: false,
                  onPressed: onToggle,
                ),
        ],
      ),
    );
  }
}

class _BreathingCard extends StatelessWidget {
  final VoidCallback onTap;

  const _BreathingCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppTheme.primaryGlow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusPill(
                        label: 'Mindfulness',
                        icon: Icons.self_improvement_rounded,
                        color: AppTheme.onPrimary,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Guided breathing',
                        style: GoogleFonts.outfit(
                          color: AppTheme.onPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Calm the nervous system with a focused breathing cycle.',
                        style: GoogleFonts.inter(
                          color: AppTheme.onPrimary.withValues(alpha: 0.82),
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: AppTheme.onPrimary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppTheme.onPrimary.withValues(alpha: 0.28)),
                  ),
                  child: const Icon(
                    Icons.air_rounded,
                    color: AppTheme.onPrimary,
                    size: 34,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
