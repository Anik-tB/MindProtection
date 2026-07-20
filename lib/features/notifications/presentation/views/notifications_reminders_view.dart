import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../viewmodels/notification_notifier.dart';

class NotificationsRemindersView extends ConsumerStatefulWidget {
  const NotificationsRemindersView({super.key});

  @override
  ConsumerState<NotificationsRemindersView> createState() => _NotificationsRemindersViewState();
}

class _NotificationsRemindersViewState extends ConsumerState<NotificationsRemindersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationNotifierProvider.notifier).checkPermission();
      ref.read(notificationNotifierProvider.notifier).refreshVault();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(notificationNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceRaised,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderAccent),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reminders & Vault',
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Schedule daily focus nudges & inspect intercepted alerts',
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

                // TabBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: LiquidGlassPanel(
                    padding: const EdgeInsets.all(4),
                    radius: 16,
                    shadows: const [],
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                      onTap: (_) => HapticFeedback.selectionClick(),
                      tabs: [
                        const Tab(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('🔔 Push Reminders'),
                          ),
                        ),
                        Tab(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('🛡️ Notification Vault'),
                                if (stateAsync.value?.vaultItems.isNotEmpty == true) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${stateAsync.value!.vaultItems.length}',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tab Content
                Expanded(
                  child: stateAsync.when(
                    data: (state) => TabBarView(
                      controller: _tabController,
                      children: [
                        _buildRemindersTab(context, state),
                        _buildVaultTab(context, state),
                      ],
                    ),
                    loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                    error: (err, _) => Center(child: Text('Error loading notifications: $err', style: const TextStyle(color: AppTheme.error))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersTab(BuildContext context, NotificationState state) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // Permission Status Card
        if (!state.isPermissionGranted) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.warning.withValues(alpha: 0.45)),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_off_rounded, color: AppTheme.warning, size: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notification Permission Required',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enable permissions so exact daily focus alarms and nudges can reach you reliably.',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ref.read(notificationNotifierProvider.notifier).requestPermission();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warning,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Enable', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Test Instant Notification Banner
        GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            ref.read(notificationNotifierProvider.notifier).testInstantNotification();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.20),
                  AppTheme.secondary.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.45)),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.rocket_launch_rounded, color: Colors.black, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Push Notification Now',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tap to immediately trigger our native high-priority reminder alert.',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.touch_app_rounded, color: AppTheme.primary, size: 22),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        _SectionHeading(title: 'DAILY SCHEDULED ALARMS'),
        const SizedBox(height: 12),

        // Morning Focus Kickoff
        _ReminderToggleCard(
          title: 'Morning Focus Kickoff',
          subtitle: 'Daily reminder to schedule deep work blocks & set intentions.',
          icon: Icons.wb_sunny_rounded,
          iconColor: Colors.amberAccent,
          isActive: state.isMorningFocusEnabled,
          timeString: _formatTime(state.morningHour, state.morningMinute),
          onToggle: (val) {
            HapticFeedback.lightImpact();
            ref.read(notificationNotifierProvider.notifier).toggleMorningFocus(val);
          },
          onPickTime: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: state.morningHour, minute: state.morningMinute),
              builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
            );
            if (picked != null) {
              ref.read(notificationNotifierProvider.notifier).setMorningTime(picked.hour, picked.minute);
            }
          },
        ),
        const SizedBox(height: 12),

        // Evening Wellbeing Review
        _ReminderToggleCard(
          title: 'Evening Wellbeing Review',
          subtitle: 'Take 2 minutes to log daily habits, reflection & secure your streak.',
          icon: Icons.nightlight_round,
          iconColor: Colors.purpleAccent,
          isActive: state.isEveningReflectionEnabled,
          timeString: _formatTime(state.eveningHour, state.eveningMinute),
          onToggle: (val) {
            HapticFeedback.lightImpact();
            ref.read(notificationNotifierProvider.notifier).toggleEveningReflection(val);
          },
          onPickTime: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: state.eveningHour, minute: state.eveningMinute),
              builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
            );
            if (picked != null) {
              ref.read(notificationNotifierProvider.notifier).setEveningTime(picked.hour, picked.minute);
            }
          },
        ),
        const SizedBox(height: 24),

        _SectionHeading(title: 'HABIT & STREAK PROTECTION'),
        const SizedBox(height: 12),

        // Hydration Nudge
        _SimpleToggleCard(
          title: 'Hydration & Posture Nudges',
          subtitle: 'Periodic check-in notifications during active focus blocks.',
          icon: Icons.water_drop_rounded,
          iconColor: Colors.lightBlueAccent,
          isActive: state.isHydrationNudgeEnabled,
          onToggle: (val) {
            HapticFeedback.lightImpact();
            ref.read(notificationNotifierProvider.notifier).toggleHydrationNudge(val);
          },
        ),
        const SizedBox(height: 12),

        // Streak Protection Warning
        _SimpleToggleCard(
          title: 'Streak Protection Alert',
          subtitle: 'Urgent 8:00 PM warning if no deep focus session was logged today.',
          icon: Icons.local_fire_department_rounded,
          iconColor: Colors.orangeAccent,
          isActive: state.isStreakWarningEnabled,
          onToggle: (val) {
            HapticFeedback.lightImpact();
            ref.read(notificationNotifierProvider.notifier).toggleStreakWarning(val);
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildVaultTab(BuildContext context, NotificationState state) {
    if (state.vaultItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.borderAccent),
                ),
                child: const Icon(Icons.shield_rounded, size: 56, color: AppTheme.primary),
              ),
              const SizedBox(height: 20),
              Text(
                'Vault Inbox Empty',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'No distracting notifications intercepted yet.\nWhen Instagram, TikTok, or WhatsApp ping you during Deep Focus, they will be silenced and stored safely right here!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.vaultItems.length} Intercepted Alerts',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(notificationNotifierProvider.notifier).clearVault();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.error.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.delete_sweep_rounded, color: AppTheme.error, size: 16),
                      const SizedBox(width: 6),
                      Text('Clear Vault', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.error)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            itemCount: state.vaultItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = state.vaultItems[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderAccent),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceRaised,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.app_blocking_rounded, color: AppTheme.error, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title.isEmpty ? item.packageName : item.title,
                                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _formatTimestamp(item.timestamp),
                                style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textHint),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.text.isEmpty ? 'Silenced during active focus mode' : item.text,
                            style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.packageName,
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatTime(int hour, int minute) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour >= 12 ? 'PM' : 'AM';
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day}';
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  const _SectionHeading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppTheme.textHint,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ReminderToggleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isActive;
  final String timeString;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickTime;

  const _ReminderToggleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isActive,
    required this.timeString,
    required this.onToggle,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isActive ? AppTheme.primary.withValues(alpha: 0.35) : AppTheme.borderAccent),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isActive,
                onChanged: onToggle,
                activeThumbColor: AppTheme.primary,
                activeTrackColor: AppTheme.primary.withValues(alpha: 0.35),
                inactiveThumbColor: AppTheme.textHint,
                inactiveTrackColor: AppTheme.surfaceRaised,
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 12),
            const Divider(color: AppTheme.borderAccent, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trigger Time:',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onPickTime();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceRaised,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, color: AppTheme.primary, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          timeString,
                          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SimpleToggleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isActive;
  final ValueChanged<bool> onToggle;

  const _SimpleToggleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isActive ? AppTheme.primary.withValues(alpha: 0.35) : AppTheme.borderAccent),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: onToggle,
            activeThumbColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withValues(alpha: 0.35),
            inactiveThumbColor: AppTheme.textHint,
            inactiveTrackColor: AppTheme.surfaceRaised,
          ),
        ],
      ),
    );
  }
}
