import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class EmergencySosGroundingModal extends StatefulWidget {
  const EmergencySosGroundingModal({super.key});

  @override
  State<EmergencySosGroundingModal> createState() =>
      _EmergencySosGroundingModalState();
}

class _EmergencySosGroundingModalState extends State<EmergencySosGroundingModal>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _isBreathingActive = false;
  String _breathPhaseText = 'Breathe In (4s)';
  Timer? _breathTimer;

  late AnimationController _breathingAnimController;

  final List<Map<String, dynamic>> _steps = [
    {
      'title': '5 Things You Can SEE',
      'instruction':
          'Look around you right now. Identify and name 5 distinct physical objects in your immediate room.',
      'icon': Icons.visibility_rounded,
      'color': const Color(0xFF00D4FF),
      'examples': ['Desk lamp', 'Window frame', 'Coffee mug', 'Book cover', 'Curtain fold'],
    },
    {
      'title': '4 Things You Can TOUCH',
      'instruction':
          'Feel 4 distinct physical textures around you. Focus purely on tactile sensation.',
      'icon': Icons.back_hand_rounded,
      'color': const Color(0xFF00F5A0),
      'examples': ['Fabric of your chair', 'Cool phone glass', 'Wooden desk edge', 'Your shirt sleeve'],
    },
    {
      'title': '3 Things You Can HEAR',
      'instruction':
          'Listen intently. Identify 3 ambient sounds around you or outside.',
      'icon': Icons.hearing_rounded,
      'color': const Color(0xFFFFB800),
      'examples': ['Computer fan hum', 'Distant traffic sound', 'Clock ticking / breath sound'],
    },
    {
      'title': '2 Things You Can SMELL',
      'instruction':
          'Notice 2 scents in your environment, or recall pleasant calming scents.',
      'icon': Icons.air_rounded,
      'color': const Color(0xFFFF6F91),
      'examples': ['Fresh air / room scent', 'Coffee aroma / clean clothes'],
    },
    {
      'title': '1 Thing You Can TASTE',
      'instruction':
          'Notice the current taste in your mouth, or take a slow sip of fresh water.',
      'icon': Icons.water_drop_rounded,
      'color': const Color(0xFF9D4EDD),
      'examples': ['Fresh cool water', 'Mint or natural taste'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _breathingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _breathTimer?.cancel();
    _breathingAnimController.dispose();
    super.dispose();
  }

  void _startBreathingExercise() {
    setState(() {
      _isBreathingActive = true;
      _breathPhaseText = 'Breathe In (4s)';
    });
    _breathingAnimController.repeat(reverse: true);

    _breathTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        if (_breathPhaseText.contains('In')) {
          _breathPhaseText = 'Hold Breath (4s)';
        } else if (_breathPhaseText.contains('Hold')) {
          _breathPhaseText = 'Breathe Out (4s)';
        } else {
          _breathPhaseText = 'Breathe In (4s)';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final stepColor = step['color'] as Color;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1420).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: stepColor.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: stepColor.withValues(alpha: 0.15),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.sos_rounded,
                            color: AppTheme.error,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency SOS Grounding',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                '5-4-3-2-1 Sensory Protocol',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress Stepper Bar
              Row(
                children: List.generate(_steps.length, (index) {
                  final isDone = index <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isDone
                            ? stepColor
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Active Card Body
              if (!_isBreathingActive) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: stepColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: stepColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          step['icon'] as IconData,
                          color: stepColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        step['title'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step['instruction'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: (step['examples'] as List<String>)
                            .map((ex) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: stepColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    ex,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: stepColor,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              _currentStep--;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppTheme.borderAccent,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Previous',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          if (_currentStep < _steps.length - 1) {
                            setState(() {
                              _currentStep++;
                            });
                          } else {
                            _startBreathingExercise();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: stepColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _currentStep < _steps.length - 1
                                ? 'Next Step (${_currentStep + 1}/5)'
                                : 'Start Calming Breathing',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Breathing Exercise Interactive Visual
                Column(
                  children: [
                    Text(
                      'Box Breathing Protocol',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Regulate your nervous system to dissolve impulse',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AnimatedBuilder(
                      animation: _breathingAnimController,
                      builder: (ctx, child) {
                        final size = 100 + (_breathingAnimController.value * 50);
                        return Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF00D4FF).withValues(alpha: 0.8),
                                const Color(0xFF00F5A0).withValues(alpha: 0.2),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00D4FF).withValues(alpha: 0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.spa_rounded,
                              color: Colors.white,
                              size: size * 0.4,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _breathPhaseText,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF00D4FF),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check_circle_rounded,
                          color: Colors.black),
                      label: Text(
                        'I Am Grounded & In Control',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00F5A0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
