import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          const SizedBox(height: 18),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Status Card
          LiquidGlassPanel(
            padding: const EdgeInsets.all(20),
            radius: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getGuardianTitle(stats.level),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Level ${stats.level}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${stats.xp} / $targetXp XP to next rank',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: AppTheme.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionTitle(title: 'Unlockable Badges'),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.15,
            children: [
              _AchievementBadgeCard(
                title: 'Initiate Shield',
                subtitle: 'Begin your cyber defense journey',
                icon: Icons.shield_rounded,
                color: AppTheme.primary,
                isUnlocked: stats.level >= 1,
              ),
              _AchievementBadgeCard(
                title: 'Iron Will',
                subtitle: 'Reach Guardian Level 2',
                icon: Icons.fitness_center_rounded,
                color: AppTheme.secondary,
                isUnlocked: stats.level >= 2,
              ),
              _AchievementBadgeCard(
                title: 'Deep Focus Titan',
                subtitle: 'Complete 3+ Focus Sessions',
                icon: Icons.psychology_rounded,
                color: AppTheme.info,
                isUnlocked: stats.focusStreak >= 3 || stats.level >= 3,
              ),
              _AchievementBadgeCard(
                title: 'Hydration Master',
                subtitle: 'Log optimal daily hydration',
                icon: Icons.water_drop_rounded,
                color: AppTheme.accent,
                isUnlocked: stats.level >= 3,
              ),
              _AchievementBadgeCard(
                title: '7-Day Protector',
                subtitle: 'Maintain 7 days of discipline',
                icon: Icons.local_fire_department_rounded,
                color: AppTheme.error,
                isUnlocked: stats.habitStreak >= 7 || stats.level >= 5,
              ),
              _AchievementBadgeCard(
                title: 'Apex Guardian',
                subtitle: 'Ascend to Level 10 mastery',
                icon: Icons.auto_awesome_rounded,
                color: AppTheme.secondary,
                isUnlocked: stats.level >= 10,
              ),
            ],
          ),
        ],
      ),
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

class _AchievementBadgeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isUnlocked;

  const _AchievementBadgeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(14),
      radius: 20,
      tint: isUnlocked
          ? color.withValues(alpha: 0.14)
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
                      ? color.withValues(alpha: 0.22)
                      : AppTheme.border.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isUnlocked ? color : AppTheme.textSecondary,
                ),
              ),
              Icon(
                isUnlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
                size: 18,
                color: isUnlocked ? color : AppTheme.textSecondary.withValues(alpha: 0.6),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isUnlocked ? Colors.white : AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary.withValues(alpha: 0.8),
              fontSize: 11,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
