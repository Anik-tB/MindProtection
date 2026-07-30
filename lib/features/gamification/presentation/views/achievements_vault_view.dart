import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../viewmodels/gamification_notifier.dart';
import '../../../recovery/presentation/viewmodels/recovery_notifier.dart';

class AchievementsVaultView extends ConsumerWidget {
  const AchievementsVaultView({super.key});

  static const List<Map<String, dynamic>> _badges = [
    {
      'id': 'badge_iron_mind',
      'title': 'Iron Mind',
      'subtitle': 'Reach a 7-day Sobriety Streak',
      'icon': Icons.security_rounded,
      'color': Color(0xFF00D4FF),
      'requiredStreak': 7,
      'xpReward': 250,
    },
    {
      'id': 'badge_sovereign_30',
      'title': '30-Day Sovereign',
      'subtitle': 'Maintain 30 consecutive days of recovery',
      'icon': Icons.military_tech_rounded,
      'color': Color(0xFFFFB800),
      'requiredStreak': 30,
      'xpReward': 1000,
    },
    {
      'id': 'badge_zen_master',
      'title': 'Zen Master',
      'subtitle': 'Complete 50 total mindful minutes',
      'icon': Icons.spa_rounded,
      'color': Color(0xFF00F5A0),
      'requiredStreak': 0,
      'xpReward': 300,
    },
    {
      'id': 'badge_focus_pioneer',
      'title': 'Focus Pioneer',
      'subtitle': 'Complete 10 Deep Focus Sessions',
      'icon': Icons.timer_rounded,
      'color': Color(0xFF8A2BE2),
      'requiredStreak': 0,
      'xpReward': 400,
    },
    {
      'id': 'badge_hydration_hero',
      'title': 'Hydration Hero',
      'subtitle': 'Log 2.0L water intake for 3 consecutive days',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF00D4FF),
      'requiredStreak': 0,
      'xpReward': 200,
    },
    {
      'id': 'badge_digital_detox',
      'title': 'Digital Detox Master',
      'subtitle': 'Keep screen time under 2 hours for a full day',
      'icon': Icons.phone_disabled_rounded,
      'color': Color(0xFFFF3366),
      'requiredStreak': 0,
      'xpReward': 500,
    },
    {
      'id': 'badge_routine_samurai',
      'title': 'Routine Samurai',
      'subtitle': 'Check off all Morning & Evening routines',
      'icon': Icons.task_alt_rounded,
      'color': Color(0xFF00F5A0),
      'requiredStreak': 0,
      'xpReward': 350,
    },
    {
      'id': 'badge_fortress_architect',
      'title': 'Fortress Architect',
      'subtitle': 'Activate PIN Security and Anti-Uninstall Guard',
      'icon': Icons.lock_outline_rounded,
      'color': Color(0xFFFFB800),
      'requiredStreak': 0,
      'xpReward': 600,
    },
  ];

  String _getRankTitle(int level) {
    if (level >= 20) return 'Fortress Master Sovereign';
    if (level >= 10) return 'Elite Guardian';
    if (level >= 5) return 'Mind Sentinel';
    return 'Novice Guardian';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamificationState = ref.watch(gamificationProvider);
    final recoveryState = ref.watch(recoveryNotifierProvider);

    final streak = recoveryState.sobriety?.currentStreakDays ?? 0;
    final level = gamificationState.level;
    final totalXp = gamificationState.xp;
    final rankTitle = _getRankTitle(level);

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
          'Achievements & Ranks',
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
                // ── Rank Banner Card ──
                LiquidGlassPanel(
                  padding: const EdgeInsets.all(22),
                  radius: 26,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFB800).withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.black,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rankTitle,
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Level $level  •  $totalXp Total XP Earned',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // XP Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: ((totalXp % 500) / 500.0).clamp(0.0, 1.0),
                                minHeight: 6,
                                backgroundColor: AppTheme.surfaceRaised,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Badges Grid Section Title ──
                Text(
                  'Unlockable Badges',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Badges Grid ──
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _badges.length,
                  itemBuilder: (context, idx) {
                    final badge = _badges[idx];
                    final reqStreak = badge['requiredStreak'] as int;
                    final isUnlocked = reqStreak > 0 ? streak >= reqStreak : idx <= 3;
                    final badgeColor = badge['color'] as Color;

                    return LiquidGlassPanel(
                      padding: const EdgeInsets.all(16),
                      radius: 22,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Opacity(
                            opacity: isUnlocked ? 1.0 : 0.35,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isUnlocked
                                    ? badgeColor.withValues(alpha: 0.2)
                                    : AppTheme.surfaceRaised,
                                border: Border.all(
                                  color: isUnlocked
                                      ? badgeColor
                                      : AppTheme.border,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                isUnlocked
                                    ? (badge['icon'] as IconData)
                                    : Icons.lock_rounded,
                                color: isUnlocked ? badgeColor : AppTheme.textHint,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            badge['title'] as String,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isUnlocked
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            badge['subtitle'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                              height: 1.3,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? badgeColor.withValues(alpha: 0.15)
                                  : AppTheme.surfaceRaised,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isUnlocked ? 'Unlocked  •  +${badge['xpReward']} XP' : 'Locked',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isUnlocked ? badgeColor : AppTheme.textHint,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
