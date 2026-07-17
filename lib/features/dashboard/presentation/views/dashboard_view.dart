import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../../../focus/presentation/viewmodels/focus_timer_notifier.dart';
import '../../../gamification/presentation/viewmodels/gamification_notifier.dart';
import '../../../recovery/presentation/viewmodels/recovery_notifier.dart';
import '../../../wellbeing/presentation/viewmodels/wellbeing_notifier.dart';
import '../../../gamification/presentation/views/guardian_sanctuary_modal.dart';
import '../../../notifications/presentation/viewmodels/notification_notifier.dart';
import '../../../notifications/presentation/views/notifications_reminders_view.dart';
import '../../../auth/presentation/views/profile_account_view.dart';
import 'analytics_view.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(gamificationProvider);
    final recoveryState = ref.watch(recoveryNotifierProvider);
    final sessionsAsync = ref.watch(focusSessionListProvider);
    final wellbeingAsync = ref.watch(todayWellbeingLogProvider);

    final sessions = sessionsAsync.value ?? [];
    final wellbeing = wellbeingAsync.value;

    final today = DateTime.now();
    final todaySessions = sessions.where((session) {
      return session.startTime.year == today.year &&
          session.startTime.month == today.month &&
          session.startTime.day == today.day &&
          session.isCompleted;
    }).toList();

    final totalFocusMinutes =
        todaySessions.fold(0, (sum, session) => sum + session.durationMinutes);
    final waterIntake = wellbeing?.waterIntakeLiters ?? 0.0;
    final streakDays = recoveryState.sobriety?.currentStreakDays ?? 0;
    final focusScore =
        (60 + (todaySessions.length * 10) + (streakDays * 2)).clamp(0, 100);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppPageHeader(
                      title: _greetingTitle(),
                      subtitle: 'Your protection system is ready for today.',
                      icon: Icons.shield_rounded,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _NotificationBellButton(),
                          const SizedBox(width: 10),
                          _ProfileAccountButton(level: stats.level),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _GuardianProgressCard(
                      level: stats.level,
                      xp: stats.xp,
                      coins: stats.coins,
                      streakDays: streakDays,
                    ),
                    const SizedBox(height: 14),
                    LiquidGlassPanel(
                      padding: const EdgeInsets.all(4),
                      radius: 18,
                      shadows: const [],
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        onTap: (_) => HapticFeedback.selectionClick(),
                        tabs: const [
                          Tab(text: 'Today'),
                          Tab(text: 'Analytics'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _TodayTab(
                      totalFocusMinutes: totalFocusMinutes,
                      focusScore: focusScore,
                      waterIntake: waterIntake,
                      streakDays: streakDays,
                      isSecure: recoveryState.isAdultBlockerActive,
                    ),
                    const AnalyticsView(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greetingTitle() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _GuardianProgressCard extends StatelessWidget {
  final int level;
  final int xp;
  final int coins;
  final int streakDays;

  const _GuardianProgressCard({
    required this.level,
    required this.xp,
    required this.coins,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final targetXp = (level * 100).clamp(100, 100000);
    final progress = (xp / targetXp).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        GuardianSanctuaryModal.show(context);
      },
      child: LiquidGlassPanel(
        padding: const EdgeInsets.all(18),
        radius: 24,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LiquidIconBadge(
                icon: Icons.workspace_premium_rounded,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Guardian progress', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      '$xp / $targetXp XP toward the next level',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: '$coins coins',
                icon: Icons.monetization_on_rounded,
                color: AppTheme.accent,
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
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(
                label: '$streakDays day recovery streak',
                icon: Icons.local_fire_department_rounded,
                color: AppTheme.error,
              ),
              const StatusPill(
                label: 'Glass shield active',
                icon: Icons.verified_user_rounded,
                color: AppTheme.primary,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}

class _TodayTab extends StatelessWidget {
  final int totalFocusMinutes;
  final int focusScore;
  final double waterIntake;
  final int streakDays;
  final bool isSecure;

  const _TodayTab({
    required this.totalFocusMinutes,
    required this.focusScore,
    required this.waterIntake,
    required this.streakDays,
    required this.isSecure,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 145),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "Today's pulse"),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.12,
            children: [
              MetricTile(
                label: 'Focus time',
                value: '${totalFocusMinutes}m',
                icon: Icons.timer_rounded,
                color: AppTheme.primary,
              ),
              MetricTile(
                label: 'Focus score',
                value: '$focusScore',
                suffix: '/100',
                icon: Icons.psychology_rounded,
                color: AppTheme.secondary,
              ),
              MetricTile(
                label: 'Hydration',
                value: '${waterIntake.toStringAsFixed(1)}L',
                suffix: '/2L',
                icon: Icons.water_drop_rounded,
                color: AppTheme.info,
              ),
              MetricTile(
                label: 'Recovery streak',
                value: '$streakDays',
                suffix: 'days',
                icon: Icons.local_fire_department_rounded,
                color: AppTheme.error,
              ),
            ],
          ),
          const SizedBox(height: 22),
          _MilestoneCard(streakDays: streakDays),
          const SizedBox(height: 22),
          const SectionTitle(title: 'Daily progress'),
          const SizedBox(height: 12),
          _ProgressTile(
            label: 'Water intake',
            progress: (waterIntake / 2.0).clamp(0.0, 1.0),
            value: '${waterIntake.toStringAsFixed(1)}L / 2.0L',
            icon: Icons.water_drop_rounded,
            color: AppTheme.info,
          ),
          const SizedBox(height: 10),
          _ProgressTile(
            label: 'Focus sessions',
            progress: (totalFocusMinutes / 60.0).clamp(0.0, 1.0),
            value: '${totalFocusMinutes}m / 60m goal',
            icon: Icons.alarm_on_rounded,
            color: AppTheme.primary,
          ),
          const SizedBox(height: 10),
          _ProgressTile(
            label: 'Blocker shield',
            progress: isSecure ? 1 : 0.35,
            value: isSecure ? 'Fully protected' : 'Enable blockers',
            icon: Icons.shield_rounded,
            color: isSecure ? AppTheme.primary : AppTheme.warning,
          ),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final int streakDays;

  const _MilestoneCard({required this.streakDays});

  @override
  Widget build(BuildContext context) {
    final progress = (streakDays / 30.0).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppTheme.primaryGlow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusPill(
                    label: '30 day milestone',
                    icon: Icons.flag_rounded,
                    color: AppTheme.onPrimary,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '$streakDays days protected',
                    style: GoogleFonts.outfit(
                      color: AppTheme.onPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    streakDays > 0
                        ? 'Your discipline is becoming visible.'
                        : 'Start today with one clean decision.',
                    style: GoogleFonts.inter(
                      color: AppTheme.onPrimary.withValues(alpha: 0.82),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppTheme.onPrimary.withValues(alpha: 0.24),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppTheme.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: AppTheme.onPrimary.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.onPrimary.withValues(alpha: 0.28)),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: AppTheme.onPrimary,
                size: 38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressTile extends StatelessWidget {
  final String label;
  final double progress;
  final String value;
  final IconData icon;
  final Color color;

  const _ProgressTile({
    required this.label,
    required this.progress,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Row(
        children: [
          LiquidIconBadge(icon: icon, color: color, size: 42, iconSize: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(label, style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: AppTheme.border,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAccountButton extends ConsumerWidget {
  final int level;
  const _ProfileAccountButton({required this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileAccountView()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.38), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.16),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppTheme.primary, size: 14),
            const SizedBox(width: 6),
            Text(
              'Lv.$level',
              style: GoogleFonts.outfit(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 12,
              color: AppTheme.primary.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.person_rounded, color: AppTheme.primary, size: 16),
          ],
        ),
      ),
    );
  }
}

class _NotificationBellButton extends ConsumerWidget {
  const _NotificationBellButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationNotifierProvider);
    final count = notifState.value?.vaultItems.length ?? 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsRemindersView()),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderAccent),
            ),
            child: const Icon(Icons.notifications_rounded, color: AppTheme.textPrimary, size: 20),
          ),
          if (count > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.surfaceCard, width: 1.5),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
