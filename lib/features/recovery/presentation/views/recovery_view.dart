import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodels/recovery_notifier.dart';
import 'emergency_lock_overlay.dart';
import '../../../blocking/data/services/android_blocking_service.dart';
import '../../../blocking/presentation/views/app_blocker_view.dart';
import '../../../blocking/presentation/viewmodels/app_blocker_notifier.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/supabase_auth_service.dart';

class RecoveryView extends ConsumerStatefulWidget {
  const RecoveryView({super.key});

  @override
  ConsumerState<RecoveryView> createState() => _RecoveryViewState();
}

class _RecoveryViewState extends ConsumerState<RecoveryView>
    with WidgetsBindingObserver {
  final _triggerController = TextEditingController();

  bool _isAccessibilityGranted  = false;
  bool _isUsageStatsGranted     = false;
  bool _isNotificationGranted   = false;
  bool _isDeviceAdminGranted    = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAllPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _triggerController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    final accessibility = await AndroidBlockingService.checkAccessibilityPermission();
    final usage         = await AndroidBlockingService.checkUsageStatsPermission();
    final notification  = await AndroidBlockingService.checkNotificationListenerPermission();
    final admin         = await AndroidBlockingService.checkDeviceAdminActive();
    if (mounted) {
      setState(() {
        _isAccessibilityGranted = accessibility;
        _isUsageStatsGranted    = usage;
        _isNotificationGranted  = notification;
        _isDeviceAdminGranted   = admin;
      });
    }
  }

  void _showLogDialog(BuildContext context, {required bool isRelapse}) {
    _triggerController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isRelapse ? AppTheme.error : AppTheme.primary).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isRelapse ? Icons.warning_rounded : Icons.flag_rounded,
                  color: isRelapse ? AppTheme.error : AppTheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(isRelapse ? 'Report Relapse' : 'Log Urge',
                style: GoogleFonts.outfit(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isRelapse
                    ? 'Admitting a slip-up is the first step back to recovery. What triggered it?'
                    : 'Great job logging! Identifying triggers builds awareness. What caused the urge?',
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _triggerController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Trigger factor (e.g. Boredom, Instagram)',
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _QuickTriggerChip(
                      label: '🥱 Boredom',
                      onTap: () {
                        _triggerController.text = 'Boredom & Idle Time';
                        HapticFeedback.lightImpact();
                      },
                    ),
                    const SizedBox(width: 8),
                    _QuickTriggerChip(
                      label: '🌙 Late Night',
                      onTap: () {
                        _triggerController.text = 'Late Night Surfing';
                        HapticFeedback.lightImpact();
                      },
                    ),
                    const SizedBox(width: 8),
                    _QuickTriggerChip(
                      label: '😤 Stress / Anxiety',
                      onTap: () {
                        _triggerController.text = 'High Stress & Exhaustion';
                        HapticFeedback.lightImpact();
                      },
                    ),
                    const SizedBox(width: 8),
                    _QuickTriggerChip(
                      label: '📱 Social Media',
                      onTap: () {
                        _triggerController.text = 'Instagram / TikTok Feed';
                        HapticFeedback.lightImpact();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final trigger = _triggerController.text.trim();
                if (trigger.isEmpty) return;
                HapticFeedback.heavyImpact();
                final notifier = ref.read(recoveryNotifierProvider.notifier);
                if (isRelapse) {
                  await notifier.reportRelapse(trigger);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Relapse logged. Streak reset. Get back up—you can do this!'),
                        backgroundColor: AppTheme.error,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } else {
                  await notifier.reportUrge(trigger);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Urge logged. +20 XP for discipline!'),
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.9),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('LOG'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recoveryState   = ref.watch(recoveryNotifierProvider);
    final recoveryNotifier = ref.read(recoveryNotifierProvider.notifier);

    if (recoveryState.isEmergencyLockActive) {
      return const EmergencyLockOverlay();
    }

    final int streakDays   = recoveryState.sobriety?.currentStreakDays ?? 0;
    final int bestStreak   = recoveryState.sobriety?.longestStreakDays ?? 0;
    final List<String> logs = recoveryState.sobriety?.triggersLog ?? [];

    final allPermissionsGranted = _isAccessibilityGranted &&
        _isUsageStatsGranted &&
        _isNotificationGranted &&
        _isDeviceAdminGranted;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 145),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────────────
              Text('Recovery Hub',
                style: GoogleFonts.outfit(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary, letterSpacing: -0.6)),
              const SizedBox(height: 3),
              Text('Break free from digital addictions',
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 24),

              // ── Permission status card ──────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: allPermissionsGranted
                        ? AppTheme.borderAccent
                        : AppTheme.warning.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('System Blocker Status',
                          style: GoogleFonts.outfit(
                            fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: (allPermissionsGranted ? AppTheme.primary : AppTheme.warning)
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            allPermissionsGranted
                                ? Icons.check_circle_rounded
                                : Icons.warning_amber_rounded,
                            color: allPermissionsGranted ? AppTheme.primary : AppTheme.warning,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      allPermissionsGranted
                          ? 'All permissions secured. Blocking engine is fully active.'
                          : 'Some permissions are missing. Enable them to activate real-time blocks.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
                    ),
                    if (!allPermissionsGranted) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: [
                          if (!_isAccessibilityGranted)
                            _PermChip(
                              icon: Icons.accessibility_rounded,
                              label: 'Accessibility',
                              onTap: () => AndroidBlockingService.requestAccessibilityPermission(),
                            ),
                          if (!_isUsageStatsGranted)
                            _PermChip(
                              icon: Icons.bar_chart_rounded,
                              label: 'Usage Stats',
                              onTap: () => AndroidBlockingService.requestUsageStatsPermission(),
                            ),
                          if (!_isNotificationGranted)
                            _PermChip(
                              icon: Icons.notifications_rounded,
                              label: 'Notifications',
                              onTap: () => AndroidBlockingService.requestNotificationListenerPermission(),
                            ),
                          if (!_isDeviceAdminGranted)
                            _PermChip(
                              icon: Icons.admin_panel_settings_rounded,
                              label: 'Anti-Uninstall',
                              onTap: () => AndroidBlockingService.requestDeviceAdminPermission(),
                            ),
                        ],
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.shield_rounded, color: AppTheme.primary, size: 16),
                          const SizedBox(width: 6),
                          Text('Device locks & active blockers enabled.',
                            style: GoogleFonts.inter(
                              color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Streak card ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.error.withValues(alpha: 0.25), width: 1),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.error.withValues(alpha: 0.25)),
                            ),
                            child: Text('🔥  SOBRIETY',
                              style: GoogleFonts.outfit(
                                color: AppTheme.error, fontSize: 10,
                                fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                          ),
                          const SizedBox(height: 12),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: '$streakDays ',
                                style: GoogleFonts.outfit(
                                  fontSize: 40, fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary, letterSpacing: -1.0),
                              ),
                              TextSpan(
                                text: 'days',
                                style: GoogleFonts.outfit(
                                  fontSize: 20, fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary),
                              ),
                            ]),
                          ),
                          const SizedBox(height: 4),
                          Text('Best streak: $bestStreak days',
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _showLogDialog(context, isRelapse: true);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.error.withValues(alpha: 0.3), width: 1),
                        ),
                        child: const Icon(Icons.refresh_rounded, color: AppTheme.error, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Emergency Shield ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Emergency Shield',
                            style: GoogleFonts.outfit(
                              fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                          const SizedBox(height: 5),
                          Text('Intense urge? Activate absolute device lock for 15 minutes.',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.4)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        recoveryNotifier.setEmergencyLock(true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.error.withValues(alpha: 0.4),
                              blurRadius: 12, offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Text('LOCK NOW',
                          style: GoogleFonts.inter(
                            color: Colors.white, fontWeight: FontWeight.w800,
                            fontSize: 12, letterSpacing: 0.5)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Active App Blocker Card ─────────────────────────────────
              const _AppBlockerEntryCard(),
              const SizedBox(height: 24),

              // ── Guard Toggles ───────────────────────────────────────────
              _SectionLabel(title: 'Blocking Guards'),
              const SizedBox(height: 12),
              _GuardSwitch(
                title: 'Adult Website Blocker',
                subtitle: 'Strict local DNS filter + SafeSearch enforcement',
                icon: Icons.vpn_lock_rounded,
                color: AppTheme.error,
                isActive: recoveryState.isAdultBlockerActive,
                onChanged: (value) {
                  HapticFeedback.mediumImpact();
                  recoveryNotifier.toggleAdultBlocker();
                },
              ),
              const SizedBox(height: 10),
              _GuardSwitch(
                title: 'Shorts & Reels Blocker',
                subtitle: 'Auto-hides TikTok, FB/IG Reels, and YT Shorts',
                icon: Icons.visibility_off_rounded,
                color: AppTheme.secondary,
                isActive: recoveryState.isShortsBlockerActive,
                onChanged: (value) {
                  HapticFeedback.mediumImpact();
                  recoveryNotifier.toggleShortsBlocker();
                  if (value) {
                    ref.read(appBlockerProvider.notifier).addCustomApp('com.zhiliaoapp.musically');
                    ref.read(appBlockerProvider.notifier).addCustomApp('com.google.android.youtube');
                  }
                },
              ),
              const SizedBox(height: 10),
              _GuardSwitch(
                title: 'App Limiters',
                subtitle: 'Restricts social apps after 30 mins daily usage',
                icon: Icons.app_blocking_rounded,
                color: AppTheme.primary,
                isActive: recoveryState.isAppLimiterActive,
                onChanged: (value) {
                  HapticFeedback.mediumImpact();
                  recoveryNotifier.toggleAppLimiter();
                  if (value) {
                    ref.read(appBlockerProvider.notifier).addCustomApp('com.instagram.android');
                    ref.read(appBlockerProvider.notifier).addCustomApp('com.twitter.android');
                    ref.read(appBlockerProvider.notifier).addCustomApp('com.facebook.katana');
                  }
                },
              ),
              const SizedBox(height: 24),

              // ── Discipline Log ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionLabel(title: 'Discipline Log'),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showLogDialog(context, isRelapse: false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderAccent, width: 1),
                      ),
                      child: Text('Log Urge',
                        style: GoogleFonts.inter(
                          color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (logs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Center(
                    child: Text('No urges or relapses reported this week.',
                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.take(5).length,
                  itemBuilder: (context, index) {
                    final logEntry = logs[logs.length - 1 - index];
                    final isRelapseLog = logEntry.startsWith('Relapse');
                    final logColor = isRelapseLog ? AppTheme.error : AppTheme.primary;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: logColor.withValues(alpha: 0.2), width: 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: logColor.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isRelapseLog
                                  ? Icons.error_outline_rounded
                                  : Icons.check_circle_outline_rounded,
                              color: logColor, size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(logEntry,
                              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textPrimary)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 28),
              _SectionLabel(title: 'Account & Storage'),
              const SizedBox(height: 12),
              const _AccountSecurityCard(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Active App Blocker Entry Card ──────────────────────────────────────────
class _AppBlockerEntryCard extends ConsumerWidget {
  const _AppBlockerEntryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blockedAsync = ref.watch(appBlockerProvider);
    final count = blockedAsync.value?.length ?? 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AppBlockerView()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderAccent),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.35)),
              ),
              child: const Icon(Icons.shield_rounded, color: AppTheme.primary, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'App Blocker Engine',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: count > 0
                              ? AppTheme.error.withValues(alpha: 0.15)
                              : AppTheme.surfaceRaised,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: count > 0
                                ? AppTheme.error.withValues(alpha: 0.4)
                                : AppTheme.border,
                          ),
                        ),
                        child: Text(
                          count > 0 ? '$count RESTRICTED' : 'INACTIVE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: count > 0 ? AppTheme.error : AppTheme.textHint,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configure specific social apps and games to intercept and lock during focus mode.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.textHint, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Permission Chip ──────────────────────────────────────────────────────────
class _PermChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PermChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.warning.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.warning.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.warning, size: 14),
            const SizedBox(width: 6),
            Text(label,
              style: GoogleFonts.inter(
                color: AppTheme.warning, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3, height: 16,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title,
          style: GoogleFonts.outfit(
            fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      ],
    );
  }
}

// ─── Guard Switch Card ────────────────────────────────────────────────────────
class _GuardSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const _GuardSwitch({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? color.withValues(alpha: 0.3) : AppTheme.border,
          width: 1,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  style: GoogleFonts.outfit(
                    fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Text(subtitle,
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary, height: 1.4)),
              ],
            ),
          ),
          Switch(value: isActive, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ─── Account & Security Card ──────────────────────────────────────────────────
class _AccountSecurityCard extends ConsumerWidget {
  const _AccountSecurityCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 1),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25), width: 1),
                ),
                child: const Icon(Icons.cloud_done_rounded, color: AppTheme.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cloud Synced Account',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Encrypted recovery & guardian profile active',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: AppTheme.border,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                  Text(
                    'Protected Status: Active',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context, ref),
                icon: const Icon(Icons.logout_rounded, size: 16),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: BorderSide(color: AppTheme.error.withValues(alpha: 0.4), width: 1),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.72),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppTheme.glassStroke, width: 1.2),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.error.withValues(alpha: 0.4), width: 1.5),
                      ),
                      child: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 28),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Sign Out of MindProtection?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your streaks, guardian level, and blocker logs will remain safely synced to your cloud account.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.textPrimary,
                              side: BorderSide(color: AppTheme.glassStroke, width: 1.2),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await ref.read(authServiceProvider).signOut();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.error,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Sign Out'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }
}

class _QuickTriggerChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickTriggerChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.glassStroke),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

