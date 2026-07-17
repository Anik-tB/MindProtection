import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../../data/services/android_blocking_service.dart';
import '../viewmodels/app_blocker_notifier.dart';

class AppBlockerView extends ConsumerStatefulWidget {
  const AppBlockerView({super.key});

  @override
  ConsumerState<AppBlockerView> createState() => _AppBlockerViewState();
}

class _AppBlockerViewState extends ConsumerState<AppBlockerView>
    with WidgetsBindingObserver {
  final _customPkgController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isAccessibilityGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _customPkgController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final granted = await AndroidBlockingService.checkAccessibilityPermission();
    if (mounted && _isAccessibilityGranted != granted) {
      setState(() {
        _isAccessibilityGranted = granted;
      });
    }
  }

  Color _getAvatarColor(String pkg) {
    final colors = [
      const Color(0xFF00F5A0),
      const Color(0xFF00D4FF),
      const Color(0xFFFFB800),
      const Color(0xFFFF3366),
      const Color(0xFF8A2BE2),
      const Color(0xFF00CEC9),
      const Color(0xFFFF7675),
      const Color(0xFFA29BFE),
    ];
    final hash = pkg.codeUnits.fold(0, (prev, el) => prev + el);
    return colors[hash % colors.length];
  }

  void _addCustomPackage() {
    final pkg = _customPkgController.text.trim();
    if (pkg.isEmpty) return;
    HapticFeedback.mediumImpact();
    ref.read(appBlockerProvider.notifier).addCustomApp(pkg);
    _customPkgController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final blockedAsync = ref.watch(appBlockerProvider);
    final blockedSet = blockedAsync.value ?? {};

    final filteredPopular = kPopularBlockableApps.where((app) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return app.name.toLowerCase().contains(q) ||
          app.pkg.toLowerCase().contains(q);
    }).toList();

    // Custom packages that are not in the popular list
    final popularPkgs = kPopularBlockableApps.map((e) => e.pkg).toSet();
    final customBlockedPkgs = blockedSet.difference(popularPkgs);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.secondary.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'App Blocker Engine',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${blockedSet.length} apps currently restricted',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Body Scroll ─────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Accessibility Service Banner or Active Shield Status
                        if (!_isAccessibilityGranted)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.warning.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.warning.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: AppTheme.warning,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Accessibility Service Inactive',
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'To intercept and overlay blocked apps when opened, you must enable the MindProtection Blocker Engine in Accessibility settings.',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.mediumImpact();
                                    AndroidBlockingService
                                        .requestAccessibilityPermission();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: AppTheme.primaryGlow,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Enable Blocker Engine',
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.primarySoft.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.primary.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.shield_rounded,
                                    color: AppTheme.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Blocker Shield Active & Armed',
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Restricted apps will be intercepted immediately during Focus & Emergency sessions.',
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

                        // Search Bar
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                color: AppTheme.textHint,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) {
                                    setState(() {
                                      _searchQuery = val;
                                    });
                                  },
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppTheme.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search popular apps or package...',
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppTheme.textHint,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: AppTheme.textHint,
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Quick Presets
                        Text(
                          'Quick Preset Rules',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _PresetActionChip(
                                label: '⚡ Social Media',
                                color: AppTheme.primary,
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  final socials = {
                                    'com.instagram.android',
                                    'com.zhiliaoapp.musically',
                                    'com.twitter.android',
                                    'com.facebook.katana',
                                    'com.snapchat.android',
                                    'com.reddit.frontpage',
                                    'com.pinterest',
                                    'com.linkedin.android',
                                  };
                                  ref.read(appBlockerProvider.notifier).bulkUpdate(
                                        blockedSet.union(socials),
                                      );
                                },
                              ),
                              const SizedBox(width: 8),
                              _PresetActionChip(
                                label: '▶️ Video & Chat',
                                color: AppTheme.secondary,
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  final videoChat = {
                                    'com.google.android.youtube',
                                    'com.whatsapp',
                                    'com.discord',
                                    'com.facebook.orca',
                                  };
                                  ref.read(appBlockerProvider.notifier).bulkUpdate(
                                        blockedSet.union(videoChat),
                                      );
                                },
                              ),
                              const SizedBox(width: 8),
                              _PresetActionChip(
                                label: '🛡️ Block All Popular',
                                color: AppTheme.accent,
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  ref.read(appBlockerProvider.notifier).bulkUpdate(
                                        popularPkgs,
                                      );
                                },
                              ),
                              const SizedBox(width: 8),
                              _PresetActionChip(
                                label: '🚫 Clear All',
                                color: AppTheme.error,
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  ref.read(appBlockerProvider.notifier).bulkUpdate({});
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Popular Apps Header
                        Text(
                          'Popular Apps to Restrict',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Popular Apps Grid / List
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredPopular.length,
                          itemBuilder: (context, index) {
                            final app = filteredPopular[index];
                            final isBlocked = blockedSet.contains(app.pkg);
                            final avatarColor = _getAvatarColor(app.pkg);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: LiquidGlassPanel(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                radius: 16,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(appBlockerProvider.notifier)
                                      .toggleApp(app.pkg);
                                },
                                child: Row(
                                  children: [
                                    // App Initial Avatar
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: avatarColor.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: avatarColor.withValues(
                                            alpha: 0.35,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          app.name[0].toUpperCase(),
                                          style: GoogleFonts.outfit(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: avatarColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            app.name,
                                            style: GoogleFonts.outfit(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            app.pkg,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Switch or Badge
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: isBlocked
                                            ? AppTheme.error
                                            : AppTheme.surfaceRaised,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isBlocked
                                              ? AppTheme.error
                                              : AppTheme.border,
                                        ),
                                        boxShadow: isBlocked
                                            ? [
                                                BoxShadow(
                                                  color: AppTheme.error
                                                      .withValues(alpha: 0.4),
                                                  blurRadius: 8,
                                                )
                                              ]
                                            : null,
                                      ),
                                      child: Icon(
                                        isBlocked
                                            ? Icons.lock_rounded
                                            : Icons.lock_open_rounded,
                                        size: 14,
                                        color: isBlocked
                                            ? Colors.white
                                            : AppTheme.textHint,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        if (customBlockedPkgs.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Custom Restrict Packages (${customBlockedPkgs.length})',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...customBlockedPkgs.map((pkg) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceCard,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.android_rounded,
                                    color: AppTheme.secondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      pkg,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      ref
                                          .read(appBlockerProvider.notifier)
                                          .removeApp(pkg);
                                    },
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppTheme.error,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],

                        const SizedBox(height: 28),
                        Text(
                          'Add Custom Package Name',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Input any Android package name (e.g., com.supercell.clashofclans) to restrict during focus sessions.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceCard,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: TextField(
                                  controller: _customPkgController,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppTheme.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'com.example.app',
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppTheme.textHint,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: _addCustomPackage,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: AppTheme.primaryGlow,
                                ),
                                child: Text(
                                  'Add App',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
}

class _PresetActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PresetActionChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.45)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
