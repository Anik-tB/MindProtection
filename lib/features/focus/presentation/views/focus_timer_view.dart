import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../viewmodels/focus_timer_notifier.dart';

class FocusTimerView extends ConsumerStatefulWidget {
  const FocusTimerView({super.key});

  @override
  ConsumerState<FocusTimerView> createState() => _FocusTimerViewState();
}

class _FocusTimerViewState extends ConsumerState<FocusTimerView> {
  late final TextEditingController _subjectController;
  final _emergencyController = TextEditingController();
  final String _validationPhrase = 'I WILL UNLEASH MY POTENTIAL';

  @override
  void initState() {
    super.initState();
    final initialSubject = ref.read(focusTimerProvider).subject;
    _subjectController = TextEditingController(text: initialSubject);
    _subjectController.addListener(_onSubjectChanged);
  }

  void _onSubjectChanged() {
    ref.read(focusTimerProvider.notifier).setSubject(_subjectController.text);
  }

  @override
  void dispose() {
    _subjectController.removeListener(_onSubjectChanged);
    _subjectController.dispose();
    _emergencyController.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getModeLabel(FocusMode mode) {
    switch (mode) {
      case FocusMode.pomodoro:
        return 'Pomodoro';
      case FocusMode.shortBreak:
        return 'Short break';
      case FocusMode.longBreak:
        return 'Long break';
      case FocusMode.custom:
        return 'Custom';
      case FocusMode.stopwatch:
        return 'Stopwatch';
    }
  }

  Color _getModeColor(FocusMode mode) {
    switch (mode) {
      case FocusMode.shortBreak:
      case FocusMode.longBreak:
        return AppTheme.secondary;
      default:
        return AppTheme.primary;
    }
  }

  void _showEmergencyUnlockSheet(BuildContext context) {
    _emergencyController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 10,
            left: 20,
            right: 20,
          ),
          child: LiquidGlassPanel(
            padding: const EdgeInsets.all(20),
            shadows: const [],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const LiquidIconBadge(
                      icon: Icons.warning_amber_rounded,
                      color: AppTheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Emergency unlock',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Type the phrase exactly to end Deep Focus early.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                LiquidGlassPanel(
                  padding: const EdgeInsets.all(14),
                  radius: 16,
                  shadows: const [],
                  tint: AppTheme.primaryLight,
                  borderColor: AppTheme.borderAccent,
                  child: Text(
                    _validationPhrase,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _emergencyController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(labelText: 'Verification phrase'),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  icon: const Icon(Icons.lock_open_rounded),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.error,
                    side: BorderSide(color: AppTheme.error.withValues(alpha: 0.45)),
                  ),
                  onPressed: () {
                    if (_emergencyController.text.trim() == _validationPhrase) {
                      HapticFeedback.heavyImpact();
                      Navigator.of(context).pop();
                      ref.read(focusTimerProvider.notifier).reset();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Deep focus session terminated.'),
                          backgroundColor: AppTheme.warning,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Phrase does not match. Stay focused.'),
                          backgroundColor: AppTheme.error,
                        ),
                      );
                    }
                  },
                  label: const Text('Confirm unlock'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(focusTimerProvider);
    final timerNotifier = ref.read(focusTimerProvider.notifier);
    final sessionsAsync = ref.watch(focusSessionListProvider);
    final sessions = sessionsAsync.value ?? [];

    final customSubjects = sessions
        .where((s) => s.isCompleted)
        .map((s) => s.subject.trim())
        .where((sub) =>
            sub.isNotEmpty &&
            sub != 'General' &&
            sub != 'Coding & Engineering' &&
            sub != 'Deep Reading & Exam Prep' &&
            sub != 'Creative Design Sprint' &&
            sub != 'Mindful Breathing & Stillness')
        .toSet()
        .toList()
      ..sort();

    final today = DateTime.now();
    final todaySessions = sessions.where((session) {
      return session.startTime.year == today.year &&
          session.startTime.month == today.month &&
          session.startTime.day == today.day &&
          session.isCompleted;
    }).toList();
    final completedCount = todaySessions.length;
    final totalFocusMinutes =
        todaySessions.fold(0, (sum, session) => sum + session.durationMinutes);

    final progress = timerState.mode == FocusMode.stopwatch
        ? (timerState.durationSecondsRemaining % 60) / 60.0
        : timerState.totalDurationSeconds > 0
            ? timerState.durationSecondsRemaining / timerState.totalDurationSeconds
            : 0.0;

    final isRunning = timerState.status == TimerStatus.running;
    final isDeepFocusLockActive = timerState.isDeepFocus && isRunning;
    final modeColor = _getModeColor(timerState.mode);

    return PopScope(
      canPop: !isDeepFocusLockActive,
      onPopInvokedWithResult: (didPop, _) {
        if (isDeepFocusLockActive && !didPop) _showEmergencyUnlockSheet(context);
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 145),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const AppPageHeader(
                      title: 'Focus studio',
                      subtitle: 'Start clean sessions and protect deep work.',
                      icon: Icons.timer_rounded,
                    ),
                    const SizedBox(height: 24),
                    _TimerDial(
                      progress: progress,
                      time: _formatDuration(timerState.durationSecondsRemaining),
                      modeLabel: _getModeLabel(timerState.mode),
                      color: modeColor,
                      isRunning: isRunning,
                    ),
                    const SizedBox(height: 22),
                    _ModeSelector(
                      currentMode: timerState.mode,
                      onModeChanged: timerNotifier.setMode,
                    ),
                    if (timerState.mode == FocusMode.custom &&
                        timerState.status == TimerStatus.idle) ...[
                      const SizedBox(height: 16),
                      _DurationPanel(
                        minutes: timerState.totalDurationSeconds ~/ 60,
                        onChanged: (minutes) =>
                            timerNotifier.setCustomDuration(minutes * 60),
                      ),
                    ],
                    const SizedBox(height: 16),
                    LiquidGlassPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: TextField(
                        controller: _subjectController,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Current focus subject',
                          prefixIcon: Icon(Icons.edit_note_rounded),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _SubjectPresetPill(
                            label: '💻 Coding / Dev',
                            onTap: () {
                              _subjectController.text = 'Coding & Engineering';
                              HapticFeedback.lightImpact();
                            },
                          ),
                          const SizedBox(width: 8),
                          _SubjectPresetPill(
                            label: '📚 Exam Prep & Study',
                            onTap: () {
                              _subjectController.text = 'Deep Reading & Exam Prep';
                              HapticFeedback.lightImpact();
                            },
                          ),
                          const SizedBox(width: 8),
                          _SubjectPresetPill(
                            label: '🎨 Design & Creative',
                            onTap: () {
                              _subjectController.text = 'Creative Design Sprint';
                              HapticFeedback.lightImpact();
                            },
                          ),
                          const SizedBox(width: 8),
                          _SubjectPresetPill(
                            label: '🧘 Meditation & Rest',
                            onTap: () {
                              _subjectController.text = 'Mindful Breathing & Stillness';
                              HapticFeedback.lightImpact();
                            },
                          ),
                          ...customSubjects.map((sub) => Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _SubjectPresetPill(
                                  label: '📁 $sub',
                                  onTap: () {
                                    _subjectController.text = sub;
                                    HapticFeedback.lightImpact();
                                  },
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (timerState.mode == FocusMode.stopwatch &&
                            timerState.status != TimerStatus.idle) ...[
                          _RoundControlButton(
                            icon: Icons.stop_circle_outlined,
                            color: AppTheme.primary,
                            tooltip: 'Finish',
                            onTap: timerNotifier.finishStopwatch,
                          ),
                          const SizedBox(width: 14),
                        ],
                        if (timerState.mode != FocusMode.stopwatch) ...[
                          _RoundControlButton(
                            icon: Icons.replay_rounded,
                            color: AppTheme.textSecondary,
                            tooltip: 'Reset',
                            onTap: timerNotifier.reset,
                          ),
                          const SizedBox(width: 14),
                        ],
                        _PrimaryTimerButton(
                          isRunning: isRunning,
                          onTap: () {
                            if (timerState.status == TimerStatus.running) {
                              timerNotifier.pause();
                            } else if (timerState.status == TimerStatus.paused) {
                              timerNotifier.resume();
                            } else {
                              timerNotifier.start();
                            }
                          },
                        ),
                        const SizedBox(width: 14),
                        _RoundControlButton(
                          icon: timerState.isDeepFocus
                              ? Icons.security_rounded
                              : Icons.security_outlined,
                          color: timerState.isDeepFocus
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          tooltip: timerState.isDeepFocus
                              ? 'Deep Focus active'
                              : 'Enable Deep Focus',
                          isActive: timerState.isDeepFocus,
                          onTap: timerNotifier.toggleDeepFocus,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _FocusSummaryCard(
                      completedCount: completedCount,
                      totalFocusMinutes: totalFocusMinutes,
                      subject: timerState.subject,
                    ),
                    if (sessions.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const SectionTitle(title: 'Recent sessions'),
                      const SizedBox(height: 12),
                      _RecentSessionsList(
                        sessions: sessions.take(5).toList(),
                        formatTimeOfDay: _formatTimeOfDay,
                      ),
                    ],
                  ],
                ),
              ),
              if (isDeepFocusLockActive)
                _DeepFocusOverlay(
                  remainingTime: _formatDuration(timerState.durationSecondsRemaining),
                  subject: timerState.subject,
                  onEmergencyExit: () => _showEmergencyUnlockSheet(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeOfDay(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _SubjectPresetPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SubjectPresetPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.primaryLight,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerDial extends StatelessWidget {
  final double progress;
  final String time;
  final String modeLabel;
  final Color color;
  final bool isRunning;

  const _TimerDial({
    required this.progress,
    required this.time,
    required this.modeLabel,
    required this.color,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 276,
      height: 276,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.surfaceRaised.withValues(alpha: 0.7),
        border: Border.all(color: AppTheme.glassStroke, width: 1.5),
        boxShadow: isRunning ? AppTheme.primaryGlow : AppTheme.cardShadow,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 236,
            height: 236,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 9,
              backgroundColor: AppTheme.border,
              color: color,
              strokeCap: StrokeCap.round,
            ),
          ),
          Container(
            width: 198,
            height: 198,
            decoration: BoxDecoration(
              color: AppTheme.surfaceRaised.withValues(alpha: 0.86),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.16)),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: GoogleFonts.outfit(
                  color: AppTheme.textPrimary,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 12),
              StatusPill(
                label: modeLabel,
                icon: Icons.bolt_rounded,
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final FocusMode currentMode;
  final ValueChanged<FocusMode> onModeChanged;

  const _ModeSelector({
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final modes = [
      (FocusMode.pomodoro, 'Pomodoro', AppTheme.primary),
      (FocusMode.custom, 'Custom', AppTheme.primary),
      (FocusMode.stopwatch, 'Stopwatch', AppTheme.primary),
      (FocusMode.shortBreak, 'Short break', AppTheme.secondary),
      (FocusMode.longBreak, 'Long break', AppTheme.secondary),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final mode in modes) ...[
            _ModeChip(
              label: mode.$2,
              color: mode.$3,
              isActive: currentMode == mode.$1,
              onTap: () => onModeChanged(mode.$1),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) {
        HapticFeedback.lightImpact();
        onTap();
      },
      selectedColor: color.withValues(alpha: 0.16),
      checkmarkColor: color,
      labelStyle: GoogleFonts.inter(
        color: isActive ? color : AppTheme.textSecondary,
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
      side: BorderSide(color: isActive ? color.withValues(alpha: 0.36) : AppTheme.border),
    );
  }
}

class _DurationPanel extends StatelessWidget {
  final int minutes;
  final ValueChanged<int> onChanged;

  const _DurationPanel({
    required this.minutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Column(
        children: [
          Row(
            children: [
              Text('Duration', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(
                '$minutes minutes',
                style: GoogleFonts.inter(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Slider(
            value: minutes.toDouble(),
            min: 5,
            max: 180,
            divisions: 35,
            onChanged: (value) => onChanged(value.toInt()),
          ),
        ],
      ),
    );
  }
}

class _PrimaryTimerButton extends StatelessWidget {
  final bool isRunning;
  final VoidCallback onTap;

  const _PrimaryTimerButton({
    required this.isRunning,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isRunning ? AppTheme.error : AppTheme.primary;
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        gradient: isRunning
            ? const LinearGradient(colors: [AppTheme.error, Color(0xFFFF7A70)])
            : AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.32),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.heavyImpact();
            onTap();
          },
          child: Icon(
            isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: AppTheme.onPrimary,
            size: 38,
          ),
        ),
      ),
    );
  }
}

class _RoundControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;

  const _RoundControlButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: LiquidGlassPanel(
        padding: EdgeInsets.zero,
        radius: 999,
        shadows: const [],
        tint: isActive ? color.withValues(alpha: 0.1) : null,
        borderColor: isActive ? color.withValues(alpha: 0.28) : AppTheme.glassStroke,
        onTap: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: color, size: 25),
        ),
      ),
    );
  }
}

class _FocusSummaryCard extends StatelessWidget {
  final int completedCount;
  final int totalFocusMinutes;
  final String subject;

  const _FocusSummaryCard({
    required this.completedCount,
    required this.totalFocusMinutes,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      child: Row(
        children: [
          Expanded(child: _SummaryStat(label: 'Sessions', value: '$completedCount')),
          const _VerticalDivider(),
          Expanded(child: _SummaryStat(label: 'Focus', value: '${totalFocusMinutes}m')),
          const _VerticalDivider(),
          Expanded(
            child: _SummaryStat(
              label: 'Subject',
              value: subject.trim().isEmpty ? 'Unset' : subject.trim(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _RecentSessionsList extends StatelessWidget {
  final List<dynamic> sessions;
  final String Function(DateTime) formatTimeOfDay;

  const _RecentSessionsList({
    required this.sessions,
    required this.formatTimeOfDay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: sessions.map((session) {
        final isDeep = session.isDeepFocus as bool;
        final color = isDeep ? AppTheme.primary : AppTheme.secondary;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            radius: 18,
            child: Row(
              children: [
                LiquidIconBadge(
                  icon: isDeep ? Icons.security_rounded : Icons.wb_sunny_rounded,
                  color: color,
                  size: 42,
                  iconSize: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.subject as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Started at ${formatTimeOfDay(session.startTime as DateTime)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                StatusPill(
                  label: '${session.durationMinutes}m',
                  color: color,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DeepFocusOverlay extends StatelessWidget {
  final String remainingTime;
  final String subject;
  final VoidCallback onEmergencyExit;

  const _DeepFocusOverlay({
    required this.remainingTime,
    required this.subject,
    required this.onEmergencyExit,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            color: AppTheme.background.withValues(alpha: 0.88),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: LiquidGlassPanel(
                  padding: const EdgeInsets.all(26),
                  radius: 30,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: AppTheme.primaryGlow,
                        ),
                        child: const Icon(
                          Icons.security_rounded,
                          color: AppTheme.onPrimary,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Deep Focus Shield',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your focus is protected. Stay with the task.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        remainingTime,
                        style: GoogleFonts.outfit(
                          color: AppTheme.primaryDark,
                          fontSize: 62,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 14),
                      StatusPill(
                        label: subject.trim().isEmpty ? 'Deep focus' : subject.trim(),
                        icon: Icons.bolt_rounded,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(height: 34),
                      OutlinedButton.icon(
                        onPressed: onEmergencyExit,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: BorderSide(color: AppTheme.error.withValues(alpha: 0.42)),
                        ),
                        icon: const Icon(Icons.exit_to_app_rounded),
                        label: const Text('Emergency exit'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      color: AppTheme.border,
    );
  }
}
