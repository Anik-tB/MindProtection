import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';

class ThemeCustomizerView extends ConsumerStatefulWidget {
  const ThemeCustomizerView({super.key});

  @override
  ConsumerState<ThemeCustomizerView> createState() =>
      _ThemeCustomizerViewState();
}

class _ThemeCustomizerViewState extends ConsumerState<ThemeCustomizerView> {
  int _selectedThemeIndex = 0;
  double _blurIntensity = 16.0;
  double _glassOpacity = 0.15;

  static const List<Map<String, dynamic>> _themes = [
    {
      'name': 'Cyberpunk Cyan',
      'primary': Color(0xFF00D4FF),
      'secondary': Color(0xFF00F5A0),
      'description': 'Electric neon cyan & mint green accents',
    },
    {
      'name': 'Emerald Sovereign',
      'primary': Color(0xFF00F5A0),
      'secondary': Color(0xFF00D4FF),
      'description': 'Pure emerald aura with focus highlight',
    },
    {
      'name': 'Solar Gold',
      'primary': Color(0xFFFFB800),
      'secondary': Color(0xFFFF8C00),
      'description': 'Warm radiant golden glow and amber accents',
    },
    {
      'name': 'Midnight Obsidian',
      'primary': Color(0xFFA29BFE),
      'secondary': Color(0xFF8A2BE2),
      'description': 'Deep violet cosmos & purple glass theme',
    },
    {
      'name': 'Ruby Flame',
      'primary': Color(0xFFFF3366),
      'secondary': Color(0xFFFF7675),
      'description': 'Vibrant ruby red & warm coral highlights',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedThemeIndex = prefs.getInt('theme_accent_index') ?? 0;
      _blurIntensity = prefs.getDouble('theme_blur_intensity') ?? 16.0;
      _glassOpacity = prefs.getDouble('theme_glass_opacity') ?? 0.15;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_accent_index', _selectedThemeIndex);
    await prefs.setDouble('theme_blur_intensity', _blurIntensity);
    await prefs.setDouble('theme_glass_opacity', _glassOpacity);

    HapticFeedback.heavyImpact();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.palette_rounded, color: AppTheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_themes[_selectedThemeIndex]['name']} theme applied across MindProtection!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.surfaceCard,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTheme = _themes[_selectedThemeIndex];
    final primaryColor = activeTheme['primary'] as Color;
    final secondaryColor = activeTheme['secondary'] as Color;

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
          'Theme & Visual Studio',
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
                // ── Live Preview Card ──
                LiquidGlassPanel(
                  padding: const EdgeInsets.all(22),
                  radius: 26,
                  child: Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [primaryColor, secondaryColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.4),
                              blurRadius: 24,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.black,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        activeTheme['name'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeTheme['description'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Color Schemes Picker ──
                Text(
                  'Curated Color Accents',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                ...List.generate(_themes.length, (idx) {
                  final t = _themes[idx];
                  final isSel = idx == _selectedThemeIndex;
                  final pColor = t['primary'] as Color;
                  final sColor = t['secondary'] as Color;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: LiquidGlassPanel(
                      padding: const EdgeInsets.all(16),
                      radius: 20,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedThemeIndex = idx;
                        });
                        _savePrefs();
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [pColor, sColor],
                              ),
                              border: Border.all(
                                color: isSel ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: isSel
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.black, size: 20)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t['name'] as String,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  t['description'] as String,
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
                  );
                }),

                const SizedBox(height: 20),

                // ── Glassmorphism Controls ──
                Text(
                  'Glassmorphic UI Controls',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                LiquidGlassPanel(
                  padding: const EdgeInsets.all(18),
                  radius: 22,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Backdrop Blur Intensity',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '${_blurIntensity.toInt()}px',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _blurIntensity,
                        min: 4.0,
                        max: 32.0,
                        activeColor: primaryColor,
                        inactiveColor: AppTheme.surfaceRaised,
                        onChanged: (v) {
                          setState(() => _blurIntensity = v);
                        },
                        onChangeEnd: (v) => _savePrefs(),
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Glass Panel Opacity',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            '${(_glassOpacity * 100).toInt()}%',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: _glassOpacity,
                        min: 0.05,
                        max: 0.40,
                        activeColor: primaryColor,
                        inactiveColor: AppTheme.surfaceRaised,
                        onChanged: (v) {
                          setState(() => _glassOpacity = v);
                        },
                        onChangeEnd: (v) => _savePrefs(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
