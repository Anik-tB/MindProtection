import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/recovery_notifier.dart';
import '../../../wellbeing/presentation/views/breathing_exercises_view.dart';
import '../../../../core/ui/liquid_glass.dart';

class EmergencyLockOverlay extends ConsumerStatefulWidget {
  const EmergencyLockOverlay({super.key});

  @override
  ConsumerState<EmergencyLockOverlay> createState() => _EmergencyLockOverlayState();
}

class _EmergencyLockOverlayState extends ConsumerState<EmergencyLockOverlay> {
  Timer? _timer;
  int _secondsRemaining = 900; // 15 minutes lockout

  @override
  void initState() {
    super.initState();
    _startLockdownTimer();
  }

  void _startLockdownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        ref.read(recoveryNotifierProvider.notifier).setEmergencyLock(false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSecs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSecs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false, // Strict block
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LiquidBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Warning Header
                Column(
                  children: [
                    Icon(
                      Icons.shield,
                      color: theme.colorScheme.error,
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Emergency Urge Shield',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: theme.textTheme.displayMedium?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sit tight. Every urge has a peak duration of 10-15 minutes. This will pass.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),

                // Countdown Timer
                Column(
                  children: [
                    Text(
                      _formatDuration(_secondsRemaining),
                      style: GoogleFonts.outfit(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'STRICT LOCKDOWN ACTIVE',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),

                // Guidance and tools
                Column(
                  children: [
                    Text(
                      'Recommended Action:',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 14, 
                        color: theme.textTheme.bodyMedium?.color
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      child: ListTile(
                        leading: Icon(Icons.bubble_chart, color: theme.colorScheme.primary),
                        title: const Text('Start Guided Breathing Space'),
                        subtitle: const Text('Calm your nervous system immediately'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const BreathingExercisesView()),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // Panic Button / Contacts
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Accountability partner notified via secure mock channel.'),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  },
                  icon: Icon(Icons.chat_bubble_outline, color: theme.colorScheme.primary),
                  label: Text(
                    'TEXT ACCOUNTABILITY PARTNER',
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5), width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
}
}
