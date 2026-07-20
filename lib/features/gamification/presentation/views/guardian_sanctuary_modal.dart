import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../viewmodels/gamification_notifier.dart';

class GuardianSanctuaryModal extends ConsumerStatefulWidget {
  const GuardianSanctuaryModal({super.key});

  static void show(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GuardianSanctuaryModal(),
    );
  }

  @override
  ConsumerState<GuardianSanctuaryModal> createState() => _GuardianSanctuaryModalState();
}

class _GuardianSanctuaryModalState extends ConsumerState<GuardianSanctuaryModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _unlockedRewards = {'Initiate Shield'};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _purchaseItem(String title, int cost) async {
    if (_unlockedRewards.contains(title)) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title is already active in your sanctuary!'),
          backgroundColor: AppTheme.primary,
        ),
      );
      return;
    }

    final success = await ref.read(gamificationProvider.notifier).spendCoins(cost);
    if (!mounted) return;

    if (success) {
      HapticFeedback.heavyImpact();
      setState(() {
        _unlockedRewards.add(title);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: AppTheme.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Unlocked: $title! Sanctuary defenses upgraded.',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.surfaceRaised,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      HapticFeedback.vibrate();
      final needed = cost - ref.read(gamificationProvider).coins;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Need $needed more coins! Complete habits or focus sessions to earn coins.',
          ),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(gamificationProvider);
    final targetXp = (stats.level * 100).clamp(100, 100000);
    final progress = (stats.xp / targetXp).clamp(0.0, 1.0);

    return Container(
      height: MediaQuery.of(context).size.height * 0.84,
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft.withValues(alpha: 0.94),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: AppTheme.secondary.withValues(alpha: 0.28),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondary.withValues(alpha: 0.15),
            blurRadius: 36,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.secondary.withValues(alpha: 0.36),
                    ),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppTheme.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guardian Sanctuary',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Mastery & Defenses • Level ${stats.level}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusPill(
                  label: '${stats.coins} coins',
                  icon: Icons.monetization_on_rounded,
                  color: AppTheme.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Daily Check-in Banner
          if (ref.read(gamificationProvider.notifier).canClaimDailyCheckIn())
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: GestureDetector(
                onTap: () async {
                  HapticFeedback.heavyImpact();
                  final rewards = await ref
                      .read(gamificationProvider.notifier)
                      .claimDailyCheckIn();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(
                            Icons.card_giftcard_rounded,
                            color: AppTheme.accent,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '🎉 Daily Guardian Supply claimed! +${rewards['xp']} XP and +${rewards['coins']} Coins!',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: AppTheme.surfaceRaised,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accent.withValues(alpha: 0.25),
                        AppTheme.primary.withValues(alpha: 0.25),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.5),
                    ),
                    boxShadow: AppTheme.primaryGlow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.card_giftcard_rounded,
                          color: AppTheme.accent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Claim Daily Guardian Supply',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+${50 + (stats.level * 10)} XP  •  +${25 + (stats.level * 5)} Coins',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'CLAIM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 14),

          // Tab Switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LiquidGlassPanel(
              padding: const EdgeInsets.all(4),
              radius: 18,
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                onTap: (_) => HapticFeedback.selectionClick(),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.emoji_events_rounded, size: 18),
                    text: 'Achievements',
                  ),
                  Tab(
                    icon: Icon(Icons.storefront_rounded, size: 18),
                    text: 'Sanctuary Shop',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAchievementsTab(context, stats, targetXp, progress),
                _buildShopTab(context, stats),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(
    BuildContext context,
    GamificationState stats,
    int targetXp,
    double progress,
  ) {
    final trophies = _getTrophyList();
    final unlockedCount = trophies.where((t) => t.isUnlocked(stats)).length;
    final totalCount = trophies.length;
    final overallProgress = (unlockedCount / totalCount).clamp(0.0, 1.0);

    final bronzeTrophies = trophies.where((t) => t.tier == 'Bronze').toList();
    final silverTrophies = trophies.where((t) => t.tier == 'Silver').toList();
    final goldTrophies = trophies.where((t) => t.tier == 'Gold').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Status & Trophy Summary Card
          LiquidGlassPanel(
            padding: const EdgeInsets.all(20),
            radius: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _getGuardianTitle(stats.level),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '$unlockedCount / $totalCount Badges Unlocked',
                        style: const TextStyle(
                          color: AppTheme.primaryLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${stats.xp} / $targetXp XP to next rank (${(overallProgress * 100).toStringAsFixed(0)}% Trophies Collected)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: overallProgress,
                    minHeight: 10,
                    backgroundColor: AppTheme.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryLight),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Bronze Tier
          const SectionTitle(title: '🥉 Bronze Tier (Foundations)'),
          const SizedBox(height: 14),
          _buildTrophyGrid(context, bronzeTrophies, stats),
          const SizedBox(height: 22),

          // Silver Tier
          const SectionTitle(title: '🥈 Silver Tier (Vanguard)'),
          const SizedBox(height: 14),
          _buildTrophyGrid(context, silverTrophies, stats),
          const SizedBox(height: 22),

          // Gold Tier
          const SectionTitle(title: '🥇 Gold Tier (Apex Mastery)'),
          const SizedBox(height: 14),
          _buildTrophyGrid(context, goldTrophies, stats),
        ],
      ),
    );
  }

  Widget _buildTrophyGrid(BuildContext context, List<_AchievementTrophy> tierTrophies, GamificationState stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.12,
      children: tierTrophies.map((trophy) {
        final unlocked = trophy.isUnlocked(stats);
        final claimed = stats.claimedAchievementIds.contains(trophy.id);
        return _AchievementBadgeCard(
          trophy: trophy,
          isUnlocked: unlocked,
          isClaimed: claimed,
          onTap: () {
            HapticFeedback.lightImpact();
            _showAchievementDetailDialog(context, trophy, unlocked, claimed);
          },
        );
      }).toList(),
    );
  }

  List<_AchievementTrophy> _getTrophyList() {
    return [
      _AchievementTrophy(
        id: 'initiate_shield',
        title: 'Initiate Shield',
        subtitle: 'Begin your cyber defense journey',
        loreDescription: 'Every cyber fortress begins with a single line of defense. You have stepped forward to reclaim your attention and take ownership of your mental sanctuary.',
        tier: 'Bronze',
        icon: Icons.shield_rounded,
        color: AppTheme.primary,
        xpReward: 30,
        coinReward: 15,
        isUnlocked: (s) => s.level >= 1,
      ),
      _AchievementTrophy(
        id: 'first_spark',
        title: 'First Spark',
        subtitle: 'Complete 1st Focus Session',
        loreDescription: 'The human mind is a beacon of light in a sea of digital noise. Completing your first deep focus cycle proves your resolve against distraction.',
        tier: 'Bronze',
        icon: Icons.bolt_rounded,
        color: AppTheme.accent,
        xpReward: 35,
        coinReward: 20,
        isUnlocked: (s) => s.focusStreak >= 1 || s.level >= 2,
      ),
      _AchievementTrophy(
        id: 'ritualist_3d',
        title: 'Ritualist',
        subtitle: 'Reach 3-Day Habit Streak',
        loreDescription: 'Discipline is not a momentary act, but a daily ritual. Three consecutive days forge the neural pathways of consistency and self-mastery.',
        tier: 'Bronze',
        icon: Icons.spa_rounded,
        color: AppTheme.info,
        xpReward: 45,
        coinReward: 25,
        isUnlocked: (s) => s.habitStreak >= 3 || s.level >= 3,
      ),
      _AchievementTrophy(
        id: 'mindful_warrior',
        title: 'Mindful Warrior',
        subtitle: 'Reach Guardian Level 3',
        loreDescription: 'A true protector guards physical wellbeing alongside mental clarity. Hydration, rest, and emotional equilibrium form the bedrock of endurance.',
        tier: 'Silver',
        icon: Icons.water_drop_rounded,
        color: AppTheme.secondary,
        xpReward: 60,
        coinReward: 30,
        isUnlocked: (s) => s.level >= 3,
      ),
      _AchievementTrophy(
        id: 'deep_focus_titan',
        title: 'Deep Focus Titan',
        subtitle: 'Reach 5+ Focus Sessions or Lv 4',
        loreDescription: 'Immunity to interruptions is a rare superpower in the modern world. You have spent hours immersed in deep, high-value concentration.',
        tier: 'Silver',
        icon: Icons.psychology_rounded,
        color: AppTheme.primaryLight,
        xpReward: 75,
        coinReward: 40,
        isUnlocked: (s) => s.focusStreak >= 5 || s.level >= 4,
      ),
      _AchievementTrophy(
        id: 'protector_7d',
        title: '7-Day Protector',
        subtitle: 'Maintain 7-Day Habit Streak or Lv 5',
        loreDescription: 'One full week of continuous digital sovereignty. The addictive algorithms of the net break against your willpower like waves against granite.',
        tier: 'Silver',
        icon: Icons.local_fire_department_rounded,
        color: AppTheme.error,
        xpReward: 100,
        coinReward: 50,
        isUnlocked: (s) => s.habitStreak >= 7 || s.level >= 5,
      ),
      _AchievementTrophy(
        id: 'iron_streak_14',
        title: '14-Day Iron Aegis',
        subtitle: 'Maintain 14-Day Streak or Lv 7',
        loreDescription: 'Two uninterrupted weeks of discipline. Your daily routines have solidified into an impenetrable cyber shield guarding your potential.',
        tier: 'Gold',
        icon: Icons.security_rounded,
        color: AppTheme.accent,
        xpReward: 150,
        coinReward: 75,
        isUnlocked: (s) => s.habitStreak >= 14 || s.level >= 7,
      ),
      _AchievementTrophy(
        id: 'cyber_paladin',
        title: 'Cyber Paladin',
        subtitle: 'Accumulate 100+ Coins or Lv 8',
        loreDescription: 'Through unwavering focus and daily execution, you have gathered immense wealth inside the Sanctuary. A paladin of focus and wisdom.',
        tier: 'Gold',
        icon: Icons.monetization_on_rounded,
        color: AppTheme.secondary,
        xpReward: 200,
        coinReward: 100,
        isUnlocked: (s) => s.coins >= 100 || s.level >= 8,
      ),
      _AchievementTrophy(
        id: 'apex_guardian',
        title: 'Apex Guardian',
        subtitle: 'Ascend to Level 10+ Mastery',
        loreDescription: 'The highest order of Guardian nobility. You have conquered digital addiction, mastered deep work, and achieved complete command over your mind.',
        tier: 'Gold',
        icon: Icons.auto_awesome_rounded,
        color: AppTheme.primary,
        xpReward: 300,
        coinReward: 150,
        isUnlocked: (s) => s.level >= 10,
      ),
    ];
  }

  void _showAchievementDetailDialog(
    BuildContext context,
    _AchievementTrophy trophy,
    bool isUnlocked,
    bool isClaimed,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: LiquidGlassPanel(
            padding: const EdgeInsets.all(24),
            radius: 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: trophy.color.withValues(alpha: isUnlocked ? 0.22 : 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: trophy.color.withValues(alpha: isUnlocked ? 0.6 : 0.2),
                      width: 2,
                    ),
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: trophy.color.withValues(alpha: 0.35),
                              blurRadius: 24,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    trophy.icon,
                    size: 48,
                    color: isUnlocked ? trophy.color : AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSoft,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    '${trophy.tier} Tier Trophy',
                    style: TextStyle(
                      color: trophy.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  trophy.title,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  trophy.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: trophy.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.background.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderAccent),
                  ),
                  child: Text(
                    trophy.loreDescription,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.45,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceRaised,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: AppTheme.accent, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Milestone Reward: +${trophy.xpReward} XP & +${trophy.coinReward} Coins',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                if (!isUnlocked)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.border.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 18, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Locked — Keep Training',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isClaimed)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4)),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 18, color: AppTheme.primaryLight),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Reward Claimed ✔',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: GradientActionButton(
                      label: 'Claim Trophy Reward 🎉',
                      icon: Icons.card_giftcard_rounded,
                      onPressed: () async {
                        HapticFeedback.heavyImpact();
                        final success = await ref
                            .read(gamificationProvider.notifier)
                            .claimAchievementReward(trophy.id, trophy.xpReward, trophy.coinReward);
                        if (success && context.mounted) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '🎉 Claimed ${trophy.title}! +${trophy.xpReward} XP & +${trophy.coinReward} Coins added to your vault.',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: AppTheme.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Close',
                    style: GoogleFonts.inter(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShopTab(BuildContext context, GamificationState stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.18),
                  AppTheme.secondary.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.32),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exchange Coins for Sanctuary Perks',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Earn coins by completing focus sessions and daily habits.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle(title: 'Sanctuary Upgrades'),
          const SizedBox(height: 14),
          _ShopItemCard(
            title: '1-Day Streak Freeze',
            description: 'Preserves your streak if you miss one day of habit check-ins.',
            icon: Icons.ac_unit_rounded,
            color: AppTheme.info,
            cost: 100,
            isUnlocked: _unlockedRewards.contains('1-Day Streak Freeze'),
            onTap: () => _purchaseItem('1-Day Streak Freeze', 100),
          ),
          const SizedBox(height: 14),
          _ShopItemCard(
            title: 'Cyber Emerald Glow',
            description: 'Unlocks emerald aura visual energy for your dashboard shield.',
            icon: Icons.shield_moon_rounded,
            color: AppTheme.primary,
            cost: 250,
            isUnlocked: _unlockedRewards.contains('Cyber Emerald Glow'),
            onTap: () => _purchaseItem('Cyber Emerald Glow', 250),
          ),
          const SizedBox(height: 14),
          _ShopItemCard(
            title: 'Amethyst Focus Theme',
            description: 'Deep violet visual resonance for deep focus timers.',
            icon: Icons.timer_rounded,
            color: AppTheme.secondary,
            cost: 300,
            isUnlocked: _unlockedRewards.contains('Amethyst Focus Theme'),
            onTap: () => _purchaseItem('Amethyst Focus Theme', 300),
          ),
          const SizedBox(height: 14),
          _ShopItemCard(
            title: 'Solar Flare Gold Shield',
            description: 'Ultimate golden glassmorphic shield prestige.',
            icon: Icons.wb_sunny_rounded,
            color: AppTheme.accent,
            cost: 500,
            isUnlocked: _unlockedRewards.contains('Solar Flare Gold Shield'),
            onTap: () => _purchaseItem('Solar Flare Gold Shield', 500),
          ),
        ],
      ),
    );
  }

  String _getGuardianTitle(int level) {
    if (level >= 25) return 'Apex Guardian';
    if (level >= 10) return 'Master Defender';
    if (level >= 5) return 'Cyber Knight';
    if (level >= 2) return 'Shield Bearer';
    return 'Novice Guardian';
  }
}

class _AchievementTrophy {
  final String id;
  final String title;
  final String subtitle;
  final String loreDescription;
  final String tier;
  final IconData icon;
  final Color color;
  final int xpReward;
  final int coinReward;
  final bool Function(GamificationState stats) isUnlocked;

  const _AchievementTrophy({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.loreDescription,
    required this.tier,
    required this.icon,
    required this.color,
    required this.xpReward,
    required this.coinReward,
    required this.isUnlocked,
  });
}

class _AchievementBadgeCard extends StatelessWidget {
  final _AchievementTrophy trophy;
  final bool isUnlocked;
  final bool isClaimed;
  final VoidCallback onTap;

  const _AchievementBadgeCard({
    required this.trophy,
    required this.isUnlocked,
    required this.isClaimed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlassPanel(
        padding: const EdgeInsets.all(14),
        radius: 20,
        tint: isUnlocked
            ? trophy.color.withValues(alpha: 0.14)
            : AppTheme.surfaceRaised.withValues(alpha: 0.4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? trophy.color.withValues(alpha: 0.22)
                        : AppTheme.border.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    trophy.icon,
                    size: 22,
                    color: isUnlocked ? trophy.color : AppTheme.textSecondary,
                  ),
                ),
                if (isUnlocked && !isClaimed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: AppTheme.primaryGlow,
                    ),
                    child: const Text(
                      'CLAIM',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else
                  Icon(
                    isClaimed
                        ? Icons.check_circle_rounded
                        : (isUnlocked ? Icons.verified_rounded : Icons.lock_rounded),
                    size: 18,
                    color: isClaimed
                        ? AppTheme.primaryLight
                        : (isUnlocked ? trophy.color : AppTheme.textSecondary.withValues(alpha: 0.6)),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              trophy.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: isUnlocked ? Colors.white : AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              trophy.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary.withValues(alpha: 0.8),
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int cost;
  final bool isUnlocked;
  final VoidCallback onTap;

  const _ShopItemCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.cost,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(16),
      radius: 22,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.36)),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isUnlocked ? null : AppTheme.primaryGradient,
                color: isUnlocked ? AppTheme.surfaceRaised : null,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isUnlocked ? AppTheme.border : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isUnlocked) ...[
                    const Icon(Icons.monetization_on_rounded, size: 16, color: AppTheme.accent),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    isUnlocked ? 'Unlocked ✔' : '$cost',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isUnlocked ? AppTheme.textSecondary : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
