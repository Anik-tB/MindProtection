import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../../../gamification/presentation/viewmodels/gamification_notifier.dart';
import '../viewmodels/community_provider.dart';

class CommunityHubView extends ConsumerStatefulWidget {
  const CommunityHubView({super.key});

  @override
  ConsumerState<CommunityHubView> createState() => _CommunityHubViewState();
}

class _CommunityHubViewState extends ConsumerState<CommunityHubView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LiquidBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    if (Navigator.canPop(context)) ...[
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.borderAccent),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guardian Community',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Study together, rank up, and support peers',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // TabBar Navigation Panel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: LiquidGlassPanel(
                  padding: const EdgeInsets.all(6),
                  radius: 18,
                  shadows: const [],
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.1,
                    ),
                    unselectedLabelStyle: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
                    tabs: const [
                      Tab(text: 'Board'),
                      Tab(text: 'Rooms'),
                      Tab(text: 'Buddies'),
                    ],
                  ),
                ),
              ),

              // Tab views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    const _LeaderboardTab(),
                    const _StudyRoomsTab(),
                    const _BuddiesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 1. LEADERBOARD TAB
// ──────────────────────────────────────────────────────────────────────────────
class _LeaderboardTab extends ConsumerWidget {
  const _LeaderboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(communityProvider);

    if (state.isLoading && state.leaderboard.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.leaderboard.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Failed to connect to Community Vault: ${state.error}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.error),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(communityProvider.notifier).fetchLeaderboard(),
      color: AppTheme.primary,
      backgroundColor: AppTheme.surfaceSoft,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 145),
        physics: const BouncingScrollPhysics(),
        itemCount: state.leaderboard.length,
        itemBuilder: (context, index) {
          final user = state.leaderboard[index];
          final rank = index + 1;
          final isCurrentUser = user.userId == ref.read(communitySupabaseServiceProvider).currentUserId;

          // Ranking designs
          Color medalColor = AppTheme.textSecondary;
          String medalEmoji = '';
          if (rank == 1) {
            medalColor = const Color(0xFFFFD700);
            medalEmoji = '🥇';
          } else if (rank == 2) {
            medalColor = const Color(0xFFC0C0C0);
            medalEmoji = '🥈';
          } else if (rank == 3) {
            medalColor = const Color(0xFFCD7F32);
            medalEmoji = '🥉';
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: LiquidGlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              radius: 18,
              shadows: const [],
              borderColor: isCurrentUser
                  ? AppTheme.primary.withValues(alpha: 0.6)
                  : (rank <= 3 ? medalColor.withValues(alpha: 0.4) : AppTheme.border),
              child: Row(
                children: [
                  // Rank number / Medal
                  Container(
                    width: 32,
                    alignment: Alignment.center,
                    child: medalEmoji.isNotEmpty
                        ? Text(medalEmoji, style: const TextStyle(fontSize: 22))
                        : Text(
                            '$rank',
                            style: GoogleFonts.outfit(
                              color: AppTheme.textHint,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                  ),
                  const SizedBox(width: 6),

                  // Avatar Emblem
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: rank <= 3 ? medalColor.withValues(alpha: 0.15) : AppTheme.surfaceRaised,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: rank <= 3 ? medalColor : AppTheme.border,
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: user.avatarUrl == '🛡️'
                          ? Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.cover,
                              width: 44,
                              height: 44,
                            )
                          : Center(
                              child: Text(
                                user.avatarUrl,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Username / Level
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (isCurrentUser) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppTheme.primary.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  'YOU',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Level ${user.level} Guardian',
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Streak Score count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${user.streakDays}d',
                        style: GoogleFonts.outfit(
                          color: AppTheme.error,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Streak',
                        style: GoogleFonts.inter(
                          color: AppTheme.textHint,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),

                  // Nudge trigger (Only for other users)
                  if (!isCurrentUser)
                    IconButton(
                      icon: const Icon(Icons.favorite_rounded, color: AppTheme.primary, size: 18),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ref.read(communityProvider.notifier).sendNudge(user.username);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Sent motivation shield to ${user.username}!'),
                            backgroundColor: AppTheme.primary,
                          ),
                        );
                      },
                    )
                  else
                    const SizedBox(width: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 2. STUDY ROOMS TAB
// ──────────────────────────────────────────────────────────────────────────────
class _StudyRoomsTab extends ConsumerStatefulWidget {
  const _StudyRoomsTab();

  @override
  ConsumerState<_StudyRoomsTab> createState() => _StudyRoomsTabState();
}

class _StudyRoomsTabState extends ConsumerState<_StudyRoomsTab> {
  final List<Map<String, String>> _rooms = const [
    {
      'name': 'Focus Sanctuary 🧠',
      'desc': 'Deep work & study logs. Silent Pomodoro timers.',
    },
    {
      'name': 'Zen Oasis 🧘',
      'desc': 'Mindfulness, reading & breathing exercises check-ins.',
    },
    {
      'name': 'No-Scroll Fortress 📵',
      'desc': 'Digital detox room. Keep screens locked down together.',
    },
  ];

  void _showJoinTimerDialog(String roomName) {
    int minutes = 25;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Select Session Time', style: Theme.of(ctx).textTheme.titleLarge),
        content: StatefulBuilder(
          builder: (context, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Determine how long you will commit to active study in the $roomName.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [25, 45, 60].map((m) {
                  final isSelected = minutes == m;
                  return ChoiceChip(
                    label: Text('$m min'),
                    selected: isSelected,
                    onSelected: (_) => setModalState(() => minutes = m),
                    backgroundColor: AppTheme.surfaceRaised,
                    selectedColor: AppTheme.primarySoft,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticFeedback.mediumImpact();
              final success = await ref
                  .read(communityProvider.notifier)
                  .joinStudyRoom(roomName, minutes);

              if (success && ctx.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Joined $roomName! Stand strong.'),
                    backgroundColor: AppTheme.primary,
                  ),
                );
              }
            },
            child: const Text('Join Room'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communityProvider);
    final inRoom = state.activeRoomName != null;

    if (inRoom) {
      return Column(
        children: [
          // Active Room banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: LiquidGlassPanel(
              padding: const EdgeInsets.all(18),
              radius: 20,
              borderColor: AppTheme.primary,
              child: Column(
                children: [
                  Text(
                    'Active Study Room',
                    style: GoogleFonts.inter(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.activeRoomName!,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ref.read(communityProvider.notifier).leaveStudyRoom();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.error,
                        side: const BorderSide(color: AppTheme.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Leave Study Room'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Active room participants list header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.people_alt_rounded, color: AppTheme.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Active Guardians (${state.activeRoomUsers.length})',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Active users list
          Expanded(
            child: state.activeRoomUsers.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.activeRoomUsers.length,
                    itemBuilder: (context, index) {
                      final u = state.activeRoomUsers[index];
                      return Card(
                        color: AppTheme.surfaceCard,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Text(u['avatar_url'] as String, style: const TextStyle(fontSize: 22)),
                          title: Text(
                            u['username'] as String,
                            style: GoogleFonts.outfit(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Level ${u['level']} Guardian • Active Study',
                            style: const TextStyle(fontSize: 11),
                          ),
                          trailing: const Text(
                            'Studying',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 145),
      physics: const BouncingScrollPhysics(),
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        final room = _rooms[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: LiquidGlassPanel(
            padding: const EdgeInsets.all(18),
            radius: 20,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room['name']!,
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        room['desc']!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                ElevatedButton(
                  onPressed: () => _showJoinTimerDialog(room['name']!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Enter'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// 3. BUDDIES TAB
// ──────────────────────────────────────────────────────────────────────────────
class _BuddiesTab extends ConsumerWidget {
  const _BuddiesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buddies = ref.watch(accountabilityBuddiesProvider);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 145),
      physics: const BouncingScrollPhysics(),
      itemCount: buddies.length,
      itemBuilder: (context, index) {
        final b = buddies[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: LiquidGlassPanel(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            radius: 20,
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar bubble
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppTheme.surfaceRaised,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(b.avatar, style: const TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),

                    // Name & Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.username,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: b.status == 'Studying' || b.status == 'Active Focus'
                                      ? AppTheme.primary
                                      : AppTheme.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                b.status,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Stats indicators
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '🔥 ${b.streak}d',
                              style: GoogleFonts.outfit(
                                color: AppTheme.error,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '⏱️ ${b.focusMinutes}m',
                              style: GoogleFonts.inter(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ref.read(gamificationProvider.notifier).addXp(5); // +5 XP accountability reward
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Motivation nudge sent to ${b.username}! (+5 XP check-in)'),
                              backgroundColor: AppTheme.primary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.send_rounded, size: 14),
                        label: const Text('Nudge Buddy'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Sent stay-strong guard to ${b.username}!'),
                              backgroundColor: AppTheme.secondary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.shield_outlined, size: 14),
                        label: const Text('Send Shield'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.secondary,
                          side: const BorderSide(color: AppTheme.secondary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
