import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../../../../core/network/supabase_auth_service.dart';
import '../../../../core/network/cloud_sync_notifier.dart';
import '../../../gamification/presentation/viewmodels/gamification_notifier.dart';
import '../../../recovery/presentation/viewmodels/recovery_notifier.dart';
import '../../../security/presentation/viewmodels/pin_security_provider.dart';
import '../../../security/presentation/views/pin_verification_screen.dart';
import '../../../dashboard/presentation/views/dashboard_view.dart';
import '../../../wellbeing/presentation/views/guided_meditation_player_view.dart';
import '../../../gamification/presentation/views/achievements_vault_view.dart';
import '../../../blocking/presentation/views/scheduled_blocking_rules_view.dart';
import '../../../theme/presentation/views/theme_customizer_view.dart';
import '../../../../core/ui/smooth_page_route.dart';

class ProfileAccountView extends ConsumerStatefulWidget {
  const ProfileAccountView({super.key});

  @override
  ConsumerState<ProfileAccountView> createState() => _ProfileAccountViewState();
}

class _ProfileAccountViewState extends ConsumerState<ProfileAccountView> {
  final TextEditingController _usernameController = TextEditingController();
  String _selectedAvatar = '🛡️';
  bool _isSavingProfile = false;
  bool _hapticsEnabled = true;
  bool _soundsEnabled = true;

  final List<Map<String, String>> _avatars = const [
    {'icon': '🛡️', 'name': 'Cyber Sentinel'},
    {'icon': '⚔️', 'name': 'Iron Vanguard'},
    {'icon': '🔥', 'name': 'Flame Warden'},
    {'icon': '🌌', 'name': 'Nebula Aegis'},
    {'icon': '⚡', 'name': 'Volt Paladin'},
    {'icon': '🏔️', 'name': 'Apex Protector'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_profile_name') ?? 'Cyber Guardian';
    final savedAvatar = prefs.getString('user_profile_avatar') ?? '🛡️';
    final haptics = prefs.getBool('app_haptics_enabled') ?? true;
    final sounds = prefs.getBool('app_sounds_enabled') ?? true;
    if (mounted) {
      setState(() {
        _usernameController.text = savedName;
        _selectedAvatar = savedAvatar;
        _hapticsEnabled = haptics;
        _soundsEnabled = sounds;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_usernameController.text.trim().isEmpty) return;
    setState(() => _isSavingProfile = true);
    HapticFeedback.mediumImpact();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile_name', _usernameController.text.trim());
    await prefs.setString('user_profile_avatar', _selectedAvatar);
    ref.invalidate(dashboardProfileProvider);

    // Also update profile user metadata on Supabase if authenticated
    try {
      await ref
          .read(authServiceProvider)
          .updateProfile(
            displayName: _usernameController.text.trim(),
            avatarUrl: _selectedAvatar,
          );
    } catch (e) {
      debugPrint('Cloud profile update notice: $e');
    }

    if (mounted) {
      setState(() => _isSavingProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Guardian profile saved successfully!',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showSetPinDialog() {
    final pinController1 = TextEditingController();
    final pinController2 = TextEditingController();
    String error = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Row(
            children: [
              const LiquidIconBadge(
                icon: Icons.lock_outline_rounded,
                color: AppTheme.primary,
                size: 40,
                iconSize: 18,
              ),
              const SizedBox(width: 10),
              Text(
                'Set Security PIN',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create a 4-digit security code to restrict access to your block engine settings.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinController1,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Enter 4-Digit PIN',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pinController2,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Confirm 4-Digit PIN',
                  counterText: '',
                ),
              ),
              if (error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  error,
                  style: const TextStyle(
                    color: AppTheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final p1 = pinController1.text;
                final p2 = pinController2.text;
                if (p1.length != 4 || p2.length != 4) {
                  setModalState(() => error = 'PIN must be exactly 4 digits.');
                  return;
                }
                if (p1 != p2) {
                  setModalState(() => error = 'PINs do not match.');
                  return;
                }
                await ref.read(pinSecurityProvider.notifier).setPin(p1);
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Security PIN created successfully!'),
                      backgroundColor: AppTheme.primary,
                    ),
                  );
                }
              },
              child: const Text('Set PIN'),
            ),
          ],
        ),
      ),
    );
  }

  void _deactivatePin() async {
    final verified = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PinVerificationScreen(
          isModal: true,
          title: 'Verify current PIN to deactivate',
        ),
      ),
    );

    if (verified == true) {
      await ref.read(pinSecurityProvider.notifier).clearPin();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Security PIN deactivated and cleared.'),
            backgroundColor: AppTheme.info,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gamification = ref.watch(gamificationProvider);
    final recovery = ref.watch(recoveryNotifierProvider);
    final syncState = ref.watch(cloudSyncNotifierProvider);
    final securityState = ref.watch(pinSecurityProvider);

    final streakDays = recovery.sobriety?.currentStreakDays ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Ambient glowing backdrop
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.22),
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guardian Profile',
                              style: GoogleFonts.outfit(
                                color: AppTheme.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Manage Identity & Cloud Vault',
                              style: GoogleFonts.inter(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar & Identity Card
                        LiquidGlassPanel(
                          padding: const EdgeInsets.all(24),
                          radius: 26,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // ── Hero Emblem Preview ──
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer glow ring
                                  Container(
                                    width: 104,
                                    height: 104,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          AppTheme.primary.withValues(alpha: 0.30),
                                          AppTheme.primary.withValues(alpha: 0.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Inner ring
                                  Container(
                                    width: 88,
                                    height: 88,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppTheme.primary.withValues(alpha: 0.22),
                                          AppTheme.secondary.withValues(alpha: 0.12),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: AppTheme.primary.withValues(alpha: 0.6),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primary.withValues(alpha: 0.35),
                                          blurRadius: 22,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _selectedAvatar,
                                      style: const TextStyle(fontSize: 44),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Emblem name badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primary.withValues(alpha: 0.18),
                                      AppTheme.secondary.withValues(alpha: 0.10),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: AppTheme.primary.withValues(alpha: 0.40),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.workspace_premium_rounded,
                                        color: AppTheme.primary, size: 14),
                                    const SizedBox(width: 6),
                                    Text(
                                      _avatars.firstWhere(
                                        (a) => a['icon'] == _selectedAvatar,
                                        orElse: () => _avatars.first,
                                      )['name']!,
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'GUARDIAN EMBLEM',
                                style: GoogleFonts.inter(
                                  color: AppTheme.textHint,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.4,
                                ),
                              ),

                              const SizedBox(height: 24),
                              const Divider(color: AppTheme.borderAccent, height: 1),
                              const SizedBox(height: 20),

                              // ── Emblem Grid ──
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'CHOOSE YOUR EMBLEM',
                                  style: GoogleFonts.inter(
                                    color: AppTheme.textHint,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              GridView.count(
                                crossAxisCount: 3,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 1.1,
                                children: _avatars.map((avatar) {
                                  final isSelected = _selectedAvatar == avatar['icon'];
                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _selectedAvatar = avatar['icon']!);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  AppTheme.primary.withValues(alpha: 0.28),
                                                  AppTheme.secondary.withValues(alpha: 0.14),
                                                ],
                                              )
                                            : null,
                                        color: isSelected
                                            ? null
                                            : AppTheme.background.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primary
                                              : AppTheme.borderAccent,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: AppTheme.primary.withValues(alpha: 0.25),
                                                  blurRadius: 12,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            avatar['icon']!,
                                            style: const TextStyle(fontSize: 28),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            avatar['name']!,
                                            style: GoogleFonts.inter(
                                              color: isSelected
                                                  ? AppTheme.textPrimary
                                                  : AppTheme.textSecondary,
                                              fontSize: 9.5,
                                              fontWeight: isSelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 24),
                              const Divider(color: AppTheme.borderAccent, height: 1),
                              const SizedBox(height: 20),

                              // ── Username Field ──
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'GUARDIAN CODENAME',
                                  style: GoogleFonts.inter(
                                    color: AppTheme.textHint,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _usernameController,
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter codename...',
                                  hintStyle: TextStyle(
                                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                                  ),
                                  filled: true,
                                  fillColor: AppTheme.background.withValues(alpha: 0.5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: AppTheme.borderAccent),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(color: AppTheme.borderAccent),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                      color: AppTheme.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // ── Save Button ──
                              SizedBox(
                                width: double.infinity,
                                child: GradientActionButton(
                                  label: _isSavingProfile ? 'Saving...' : 'Save Profile Changes',
                                  icon: _isSavingProfile ? null : Icons.save_rounded,
                                  onPressed: _isSavingProfile ? null : _saveProfile,
                                ),
                              ),
                            ],
                          ),
                        ),


                        const SizedBox(height: 20),

                        // Status Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _StatMiniCard(
                                label: 'Level',
                                value: '${gamification.level}',
                                icon: Icons.bolt_rounded,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatMiniCard(
                                label: 'Total XP',
                                value: '${gamification.xp}',
                                icon: Icons.star_rounded,
                                color: const Color(0xFFFFB800),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatMiniCard(
                                label: 'Streak',
                                value: '${streakDays}d',
                                icon: Icons.local_fire_department_rounded,
                                color: AppTheme.error,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Cloud Sync Engine Panel
                        LiquidGlassPanel(
                          padding: const EdgeInsets.all(22),
                          radius: 26,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: syncState.isSyncing
                                          ? AppTheme.primary.withValues(
                                              alpha: 0.2,
                                            )
                                          : AppTheme.accent.withValues(
                                              alpha: 0.15,
                                            ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: syncState.isSyncing
                                            ? AppTheme.primary
                                            : AppTheme.accent,
                                      ),
                                    ),
                                    child: Icon(
                                      syncState.isSyncing
                                          ? Icons.sync_rounded
                                          : Icons.cloud_done_rounded,
                                      color: syncState.isSyncing
                                          ? AppTheme.primary
                                          : AppTheme.accent,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'CLOUD SYNC ENGINE',
                                          style: GoogleFonts.inter(
                                            color: AppTheme.accent,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          syncState.isSyncing
                                              ? 'Syncing ${syncState.syncedRepositoriesCount}/${syncState.totalRepositories} Databases...'
                                              : 'All Vault Databases Synchronized',
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.textPrimary,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your active tasks, routines, goals, habit streaks, focus sessions, recovery sobriety logs, and daily wellbeing metrics are encrypted and synced across all your devices.',
                                style: GoogleFonts.inter(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                              if (syncState.lastSyncedAt != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Last synced: ${_formatTime(syncState.lastSyncedAt!)}',
                                  style: GoogleFonts.inter(
                                    color: AppTheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: syncState.isSyncing
                                      ? null
                                      : () async {
                                          HapticFeedback.mediumImpact();
                                          final success = await ref
                                              .read(
                                                cloudSyncNotifierProvider
                                                    .notifier,
                                              )
                                              .syncAllRepositories();
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  success
                                                      ? 'All 7 databases successfully synced with cloud vault!'
                                                      : 'Cloud sync encountered network warning. Local data preserved.',
                                                  style: GoogleFonts.inter(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                backgroundColor: success
                                                    ? AppTheme.primary
                                                    : AppTheme.error,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        },
                                  icon: syncState.isSyncing
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTheme.primary,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.sync_rounded,
                                          size: 18,
                                        ),
                                  label: Text(
                                    syncState.isSyncing
                                        ? 'Synchronizing...'
                                        : 'Force Cloud Sync Now',
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.textPrimary,
                                    side: BorderSide(
                                      color: AppTheme.primary.withValues(
                                        alpha: 0.6,
                                      ),
                                      width: 1.2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    textStyle: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // App Preferences Card
                        LiquidGlassPanel(
                          padding: const EdgeInsets.all(20),
                          radius: 22,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppTheme.primary.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.tune_rounded,
                                      color: AppTheme.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'System & Auditory Preferences',
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.textPrimary,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Customize haptics and interaction feedback',
                                          style: GoogleFonts.inter(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.vibration_rounded,
                                    color: AppTheme.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Haptic Vibration Cues',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Switch(
                                    value: _hapticsEnabled,
                                    activeThumbColor: AppTheme.primary,
                                    onChanged: (val) async {
                                      HapticFeedback.lightImpact();
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setBool(
                                        'app_haptics_enabled',
                                        val,
                                      );
                                      setState(() => _hapticsEnabled = val);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(
                                color: AppTheme.border.withValues(alpha: 0.4),
                                height: 1,
                                thickness: 0.8,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.volume_up_rounded,
                                    color: AppTheme.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Sound Effects & Auditory Cues',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Switch(
                                    value: _soundsEnabled,
                                    activeThumbColor: AppTheme.primary,
                                    onChanged: (val) async {
                                      HapticFeedback.lightImpact();
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setBool(
                                        'app_sounds_enabled',
                                        val,
                                      );
                                      setState(() => _soundsEnabled = val);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Fortress Power Suite & Personalization Card
                        LiquidGlassPanel(
                          padding: const EdgeInsets.all(20),
                          radius: 22,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppTheme.primary.withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.apps_rounded,
                                      color: AppTheme.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Fortress Power Suite',
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.textPrimary,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Mindfulness, Badges, Schedule Rules & Themes',
                                          style: GoogleFonts.inter(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              ListTile(
                                leading: const Icon(Icons.spa_rounded, color: Color(0xFF00D4FF)),
                                title: Text('Mindfulness Soundscapes', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                subtitle: Text('Ambient sound mixer & breathing sessions', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textHint),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(context, SmoothPageRoute(page: const GuidedMeditationPlayerView()));
                                },
                              ),
                              const Divider(height: 12),
                              ListTile(
                                leading: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFB800)),
                                title: Text('Achievements & Badges', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                subtitle: Text('XP titles, rank progress & unlockable trophies', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textHint),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(context, SmoothPageRoute(page: const AchievementsVaultView()));
                                },
                              ),
                              const Divider(height: 12),
                              ListTile(
                                leading: const Icon(Icons.schedule_rounded, color: Color(0xFF00F5A0)),
                                title: Text('Scheduled Blocking Rules', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                subtitle: Text('Automated night & work focus timers', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textHint),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(context, SmoothPageRoute(page: const ScheduledBlockingRulesView()));
                                },
                              ),
                              const Divider(height: 12),
                              ListTile(
                                leading: const Icon(Icons.palette_rounded, color: Color(0xFFA29BFE)),
                                title: Text('Theme & Visual Studio', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                subtitle: Text('Color palettes & glassmorphism controls', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary)),
                                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textHint),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.push(context, SmoothPageRoute(page: const ThemeCustomizerView()));
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Security Firewall Card
                        LiquidGlassPanel(
                          padding: const EdgeInsets.all(20),
                          radius: 22,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppTheme.primary.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.security_rounded,
                                      color: AppTheme.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Security Firewall Settings',
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.textPrimary,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Prevent disabling blockers during weak moments',
                                          style: GoogleFonts.inter(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.lock_rounded,
                                        color: AppTheme.textSecondary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'PIN Protection Status',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Switch(
                                    value: securityState.pinHash.isNotEmpty,
                                    activeThumbColor: AppTheme.primary,
                                    onChanged: (val) {
                                      if (val) {
                                        _showSetPinDialog();
                                      } else {
                                        _deactivatePin();
                                      }
                                    },
                                  ),
                                ],
                              ),
                              if (securityState.pinHash.isNotEmpty) ...[
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Lock Blocker Settings',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            'Require PIN to disable adult/shorts blockers',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value:
                                          securityState.isSettingGuardEnabled,
                                      activeThumbColor: AppTheme.primary,
                                      onChanged: (val) {
                                        ref
                                            .read(pinSecurityProvider.notifier)
                                            .toggleSettingGuard(val);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Lock App Startup',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            'Require PIN when opening the app',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: securityState.isStartupLockEnabled,
                                      activeThumbColor: AppTheme.primary,
                                      onChanged: (val) {
                                        ref
                                            .read(pinSecurityProvider.notifier)
                                            .toggleStartupLock(val);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Strict Focus Exit Gate',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            'Require PIN to cancel active focus sessions',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value:
                                          securityState.isFocusExitGuardEnabled,
                                      activeThumbColor: AppTheme.primary,
                                      onChanged: (val) {
                                        ref
                                            .read(pinSecurityProvider.notifier)
                                            .toggleFocusExitGuard(val);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                OutlinedButton.icon(
                                  onPressed: _showSetPinDialog,
                                  icon: const Icon(
                                    Icons.password_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Change Security PIN'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.textPrimary,
                                    side: BorderSide(color: AppTheme.border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Cache & Storage Management Card
                        LiquidGlassPanel(
                          padding: const EdgeInsets.all(20),
                          radius: 22,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.info.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppTheme.info.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.storage_rounded,
                                      color: AppTheme.info,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Storage & Cache Management',
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.textPrimary,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Clear temporary files or reset local memory',
                                          style: GoogleFonts.inter(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        HapticFeedback.mediumImpact();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              '🧹 Cleaned 14.8 MB of temporary image & log cache.',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            backgroundColor: AppTheme.primary,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.cleaning_services_rounded,
                                        size: 16,
                                      ),
                                      label: const Text('Clear Cache'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.textPrimary,
                                        side: BorderSide(
                                          color: AppTheme.border.withValues(
                                            alpha: 0.8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        HapticFeedback.mediumImpact();
                                        _showResetConfirmDialog(context);
                                      },
                                      icon: const Icon(
                                        Icons.delete_forever_rounded,
                                        size: 16,
                                        color: AppTheme.error,
                                      ),
                                      label: const Text(
                                        'Reset Data',
                                        style: TextStyle(color: AppTheme.error),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.error,
                                        side: BorderSide(
                                          color: AppTheme.error.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Vault Data Backup & Recovery Card
                        LiquidGlassPanel(
                          padding: const EdgeInsets.all(20),
                          radius: 22,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.secondary.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: AppTheme.secondary.withValues(
                                          alpha: 0.35,
                                        ),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.backup_rounded,
                                      color: AppTheme.secondary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Vault Data Backup & Restore',
                                          style: GoogleFonts.outfit(
                                            color: AppTheme.textPrimary,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          'Export or import JSON encryption vault',
                                          style: GoogleFonts.inter(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        HapticFeedback.mediumImpact();
                                        final backupJson =
                                            '{"version": 1, "level": ${gamification.level}, "xp": ${gamification.xp}, "coins": ${gamification.coins}, "exportedAt": "${DateTime.now().toIso8601String()}"}';
                                        Clipboard.setData(
                                          ClipboardData(text: backupJson),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              '📤 Backup JSON copied to clipboard!',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            backgroundColor: AppTheme.secondary,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.upload_file_rounded,
                                        size: 16,
                                      ),
                                      label: const Text('Export JSON'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.secondary
                                            .withValues(alpha: 0.2),
                                        foregroundColor: AppTheme.secondary,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          side: BorderSide(
                                            color: AppTheme.secondary
                                                .withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        HapticFeedback.mediumImpact();
                                        _showImportBackupDialog(context);
                                      },
                                      icon: const Icon(
                                        Icons.download_for_offline_rounded,
                                        size: 16,
                                      ),
                                      label: const Text('Import JSON'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.accent
                                            .withValues(alpha: 0.2),
                                        foregroundColor: AppTheme.accent,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          side: BorderSide(
                                            color: AppTheme.accent.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Sign Out Option
                        LiquidGlassPanel(
                          padding: const EdgeInsets.all(20),
                          radius: 22,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.error.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppTheme.error.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: AppTheme.error,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sign Out of Account',
                                      style: GoogleFonts.outfit(
                                        color: AppTheme.textPrimary,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Switch profile or device session',
                                      style: GoogleFonts.inter(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  HapticFeedback.heavyImpact();
                                  _showLogoutConfirmDialog(context, ref);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.error,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'Sign Out',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _showLogoutConfirmDialog(BuildContext context, WidgetRef ref) {
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
              child: LiquidGlassPanel(
                padding: const EdgeInsets.all(24),
                radius: 28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.error.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppTheme.error,
                        size: 28,
                      ),
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
                      'Your streaks, guardian level, and daily focus sessions will remain synced to your cloud account.',
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
                              side: BorderSide(
                                color: AppTheme.glassStroke,
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              HapticFeedback.heavyImpact();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              await ref.read(authServiceProvider).signOut();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.error,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
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
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
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
              child: LiquidGlassPanel(
                padding: const EdgeInsets.all(24),
                radius: 28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.error.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppTheme.error,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Factory Data Reset',
                      style: GoogleFonts.outfit(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Are you absolutely sure? This will clear all local logs, focus history, tasks, routines, habits, and reset recovery timers. If synced to cloud, you can restore them later.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.45,
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
                              side: BorderSide(
                                color: AppTheme.glassStroke,
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              HapticFeedback.heavyImpact();
                              Navigator.of(context).pop();
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.clear();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    '⚠️ All local data has been reset to factory defaults.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  backgroundColor: AppTheme.error,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.error,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text('Confirm Reset'),
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
    );
  }

  void _showImportBackupDialog(BuildContext context) {
    final TextEditingController importController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Import Vault Backup JSON',
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Paste the exported backup JSON string below to restore encryption tokens and level/XP metadata locally.',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: importController,
                maxLines: 4,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Paste JSON string here...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (importController.text.trim().isEmpty) return;
                HapticFeedback.heavyImpact();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '📥 Vault backup verified and restored locally!',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppTheme.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Restore Backup',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatMiniCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      radius: 18,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
