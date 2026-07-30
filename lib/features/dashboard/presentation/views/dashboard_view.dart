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
import '../../../ai_coach/presentation/views/ai_coach_chat_view.dart';
import '../../../ai_coach/presentation/views/ai_smart_insights_card.dart';
import '../../../community/presentation/views/community_hub_view.dart';
import '../../../../core/ui/smooth_page_route.dart';
import '../../../../core/ui/mind_protection_logo.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dashboardProfileProvider = FutureProvider<Map<String, String>>((
  ref,
) async {
  final prefs = await SharedPreferences.getInstance();
  return {
    'name': prefs.getString('user_profile_name') ?? 'Cyber Guardian',
    'avatar': prefs.getString('user_profile_avatar') ?? '🛡️',
  };
});

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(gamificationProvider);
    final recoveryState = ref.watch(recoveryNotifierProvider);
    final sessionsAsync = ref.watch(focusSessionListProvider);
    final wellbeingAsync = ref.watch(todayWellbeingLogProvider);
    final profileAsync = ref.watch(dashboardProfileProvider);

    final sessions = sessionsAsync.value ?? [];
    final wellbeing = wellbeingAsync.value;
    final profile =
        profileAsync.value ?? {'name': 'Cyber Guardian', 'avatar': '🛡️'};

    final today = DateTime.now();
    final todaySessions = sessions.where((session) {
      return session.startTime.year == today.year &&
          session.startTime.month == today.month &&
          session.startTime.day == today.day &&
          session.isCompleted;
    }).toList();

    final totalFocusMinutes = todaySessions.fold(
      0,
      (sum, session) => sum + session.durationMinutes,
    );
    final waterIntake = wellbeing?.waterIntakeLiters ?? 0.0;
    final streakDays = recoveryState.sobriety?.currentStreakDays ?? 0;
    final focusScore = (60 + (todaySessions.length * 10) + (streakDays * 2))
        .clamp(0, 100);

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left Profile Badge
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              SmoothPageRoute(
                                page: const ProfileAccountView(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    width: 1.2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: profile['avatar'] == '🛡️'
                                      ? const MindProtectionLogo(
                                          size: 38,
                                          showGlow: false,
                                        )
                                      : Center(
                                          child: Text(
                                            profile['avatar']!,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile['name']!,
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  Text(
                                    'Level ${stats.level} Guardian',
                                    style: GoogleFonts.inter(
                                      color: AppTheme.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Right Action Buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            _AiCoachButton(),
                            SizedBox(width: 8),
                            _CommunityButton(),
                            SizedBox(width: 8),
                            _NotificationBellButton(),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Greeting Header Title
                    Text(
                      _greetingTitle(),
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Protection status subtitle
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your protection system is ready for today.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }
}

class _GuardianProgressCard extends StatefulWidget {
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
  State<_GuardianProgressCard> createState() => _GuardianProgressCardState();
}

class _GuardianProgressCardState extends State<_GuardianProgressCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final targetXp = (widget.level * 100).clamp(100, 100000);
    final progress = (widget.xp / targetXp).clamp(0.0, 1.0);

    return LiquidGlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _isExpanded = !_isExpanded);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular Level Indicator with Glowing Ring
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.background,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lv.',
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${widget.level}',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Guardian Status Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Guardian Progress',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: GoogleFonts.outfit(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Glowing XP bar
                      Container(
                        height: 7,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.15),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppTheme.surfaceRaised,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Rotating Dropdown Arrow
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutBack,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceRaised,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.border.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Expandable details block (XP text + status pills)
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                Text(
                  '${widget.xp} / $targetXp XP to next level',
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Divider(
                  color: AppTheme.border.withValues(alpha: 0.25),
                  height: 1,
                  thickness: 0.8,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusPill(
                      label: '${widget.coins} Coins',
                      icon: Icons.monetization_on_rounded,
                      color: AppTheme.accent,
                    ),
                    StatusPill(
                      label: '${widget.streakDays} Days Streak',
                      icon: Icons.local_fire_department_rounded,
                      color: AppTheme.error,
                    ),
                    const StatusPill(
                      label: 'Shield Active',
                      icon: Icons.verified_user_rounded,
                      color: AppTheme.primaryDark,
                    ),
                    StatusPill(
                      label: 'Lv.${widget.level + 1} Chest',
                      icon: Icons.card_giftcard_rounded,
                      color: AppTheme.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surfaceRaised,
                      foregroundColor: AppTheme.primary,
                      elevation: 0,
                      side: BorderSide(
                        color: AppTheme.border.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      GuardianSanctuaryModal.show(context);
                    },
                    icon: const Icon(Icons.workspace_premium_rounded, size: 16),
                    label: Text(
                      'Open Sanctuary Details',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _ModernStatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final double progress;
  final Widget? extra;

  const _ModernStatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.progress,
    this.subtitle,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    final extraWidget = extra;
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(14),
      radius: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              ?extraWidget,
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: AppTheme.textHint,
              ),
            ),
          ],
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppTheme.surfaceRaised,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
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
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
            childAspectRatio: 1.18,
            children: [
              _ModernStatTile(
                label: 'Focus time',
                value: '${totalFocusMinutes}m',
                subtitle: 'Goal: 60m',
                icon: Icons.timer_rounded,
                color: AppTheme.primary,
                progress: (totalFocusMinutes / 60.0).clamp(0.0, 1.0),
                extra: Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: AppTheme.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '+12%',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _ModernStatTile(
                label: 'Focus score',
                value: '$focusScore',
                subtitle: 'Top 5% user',
                icon: Icons.psychology_rounded,
                color: AppTheme.secondary,
                progress: (focusScore / 100.0).clamp(0.0, 1.0),
                extra: Row(
                  children: [
                    const Icon(
                      Icons.arrow_upward_rounded,
                      color: AppTheme.secondary,
                      size: 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '↗ 8.4%',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _ModernStatTile(
                label: 'Hydration',
                value: '${waterIntake.toStringAsFixed(1)}L',
                subtitle: 'Goal: 2.0L',
                icon: Icons.water_drop_rounded,
                color: AppTheme.info,
                progress: (waterIntake / 2.0).clamp(0.0, 1.0),
                extra: Text(
                  '${((waterIntake / 2.0) * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppTheme.info,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _ModernStatTile(
                label: 'Recovery streak',
                value: '$streakDays days',
                subtitle: 'Shield active',
                icon: Icons.local_fire_department_rounded,
                color: AppTheme.accent,
                progress: (streakDays / 30.0).clamp(0.0, 1.0),
                extra: const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppTheme.accent,
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          AiSmartInsightsCard(
            onAskCoachTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => const AiCoachChatView(),
                ),
              );
            },
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
                      backgroundColor: AppTheme.onPrimary.withValues(
                        alpha: 0.24,
                      ),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.onPrimary,
                      ),
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
                border: Border.all(
                  color: AppTheme.onPrimary.withValues(alpha: 0.28),
                ),
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
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
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
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.38),
            width: 1.2,
          ),
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
            const Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.primary,
              size: 14,
            ),
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
          MaterialPageRoute(
            builder: (context) => const NotificationsRemindersView(),
          ),
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
            child: const Icon(
              Icons.notifications_rounded,
              color: AppTheme.primary,
              size: 20,
            ),
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

class _AiCoachButton extends ConsumerWidget {
  const _AiCoachButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          SmoothPageRoute(page: const AiCoachChatView()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderAccent),
        ),
        child: const Icon(
          Icons.psychology_rounded,
          color: AppTheme.primary,
          size: 20,
        ),
      ),
    );
  }
}

class _CommunityButton extends StatelessWidget {
  const _CommunityButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          SmoothPageRoute(page: const CommunityHubView()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderAccent),
        ),
        child: const Icon(
          Icons.people_alt_rounded,
          color: AppTheme.primary,
          size: 20,
        ),
      ),
    );
  }
}
