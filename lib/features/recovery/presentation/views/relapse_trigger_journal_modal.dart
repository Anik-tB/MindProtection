import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../viewmodels/recovery_notifier.dart';

class RelapseTriggerJournalModal extends ConsumerStatefulWidget {
  const RelapseTriggerJournalModal({super.key});

  @override
  ConsumerState<RelapseTriggerJournalModal> createState() =>
      _RelapseTriggerJournalModalState();
}

class _RelapseTriggerJournalModalState
    extends ConsumerState<RelapseTriggerJournalModal> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _preventionController = TextEditingController();

  String _selectedTrigger = 'Boredom';
  double _urgeIntensity = 7.0;
  String _emotionalState = 'Stressed';

  final List<Map<String, String>> _triggers = [
    {'name': 'Boredom', 'icon': '🥱'},
    {'name': 'Stress / Anxiety', 'icon': '😰'},
    {'name': 'Late Night', 'icon': '🌙'},
    {'name': 'Social Media', 'icon': '📱'},
    {'name': 'Loneliness', 'icon': '👤'},
    {'name': 'Fatigue / Exhaustion', 'icon': '🔋'},
  ];

  final List<String> _emotions = [
    'Overwhelmed',
    'Stressed',
    'Restless',
    'Anxious',
    'Sad',
    'Tired',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    _preventionController.dispose();
    super.dispose();
  }

  void _submitRelapseJournal() {
    final note = _noteController.text.trim();
    final prevention = _preventionController.text.trim();

    final fullReflection = '''
Trigger: $_selectedTrigger
Urge Intensity: ${_urgeIntensity.toInt()}/10
Emotional State: $_emotionalState
Notes: ${note.isNotEmpty ? note : 'N/A'}
Action Plan for Next Time: ${prevention.isNotEmpty ? prevention : 'Activate Emergency SOS Grounding immediately.'}
''';

    HapticFeedback.heavyImpact();
    ref.read(recoveryNotifierProvider.notifier).reportRelapse(fullReflection);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.surfaceCard,
        content: Row(
          children: [
            const Icon(Icons.refresh_rounded, color: AppTheme.primary),
            const SizedBox(width: 10),
            Text(
              'Streak reset logged. Every reset is a lesson forward.',
              style: GoogleFonts.inter(color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF121826).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppTheme.error.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.error.withValues(alpha: 0.12),
              blurRadius: 28,
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restart_alt_rounded,
                          color: AppTheme.error,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Relapse Reflection Journal',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Honest self-reflection turns slip-ups into permanent strength. Identify what led to this urge.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),

              // 1. Primary Trigger Selector
              Text(
                '1. What triggered the slip-up?',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _triggers.map((trig) {
                  final isSelected = _selectedTrigger == trig['name'];
                  return ChoiceChip(
                    label: Text('${trig['icon']} ${trig['name']}'),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedTrigger = trig['name']!);
                      }
                    },
                    selectedColor: AppTheme.error.withValues(alpha: 0.25),
                    backgroundColor: AppTheme.surfaceCard,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.error
                          : AppTheme.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.error
                            : AppTheme.borderAccent,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // 2. Urge Intensity Slider
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '2. Peak Urge Intensity',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${_urgeIntensity.toInt()} / 10',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.error,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _urgeIntensity,
                min: 1.0,
                max: 10.0,
                divisions: 9,
                activeColor: AppTheme.error,
                inactiveColor: AppTheme.surfaceCard,
                onChanged: (val) {
                  setState(() => _urgeIntensity = val);
                },
              ),
              const SizedBox(height: 14),

              // 3. Emotional State
              Text(
                '3. Emotional State Beforehand',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _emotions.map((em) {
                  final isSelected = _emotionalState == em;
                  return ChoiceChip(
                    label: Text(em),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        HapticFeedback.lightImpact();
                        setState(() => _emotionalState = em);
                      }
                    },
                    selectedColor: AppTheme.primary.withValues(alpha: 0.2),
                    backgroundColor: AppTheme.surfaceCard,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.borderAccent,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // 4. Action plan for next time
              Text(
                '4. What will you do differently next time?',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _preventionController,
                maxLines: 2,
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText:
                      'e.g. Put phone in another room at 10 PM / Run Emergency SOS Grounding',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 12, color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.surfaceCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppTheme.borderAccent),
                  ),
                ),
              ),
              const SizedBox(height: 22),

              // Submit Button
              ElevatedButton(
                onPressed: _submitRelapseJournal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Confirm & Reset Streak with Resolve',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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
