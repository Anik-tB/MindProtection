import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../../data/services/android_blocking_service.dart';

class ScheduledBlockingRulesView extends ConsumerStatefulWidget {
  const ScheduledBlockingRulesView({super.key});

  @override
  ConsumerState<ScheduledBlockingRulesView> createState() =>
      _ScheduledBlockingRulesViewState();
}

class _ScheduledBlockingRulesViewState
    extends ConsumerState<ScheduledBlockingRulesView> {
  final List<Map<String, dynamic>> _rules = [
    {
      'id': 'rule_sleep_guard',
      'title': 'Night Sleep Guard',
      'subtitle': 'Blocks all social apps & web browsers overnight',
      'startTime': '22:00',
      'endTime': '06:00',
      'days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      'isActive': true,
      'color': const Color(0xFF8A2BE2),
      'icon': Icons.bedtime_rounded,
    },
    {
      'id': 'rule_work_focus',
      'title': 'Deep Work Gate',
      'subtitle': 'Auto-hides YouTube, Instagram & Short video feeds',
      'startTime': '09:00',
      'endTime': '17:00',
      'days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      'isActive': true,
      'color': const Color(0xFF00D4FF),
      'icon': Icons.work_history_rounded,
    },
    {
      'id': 'rule_weekend_detox',
      'title': 'Weekend Mind Reset',
      'subtitle': 'Restricts infinite scroll apps to 15 mins total',
      'startTime': '08:00',
      'endTime': '20:00',
      'days': ['Sat', 'Sun'],
      'isActive': false,
      'color': const Color(0xFFFFB800),
      'icon': Icons.wb_sunny_rounded,
    },
  ];

  void _toggleRule(int index, bool active) {
    HapticFeedback.mediumImpact();
    setState(() {
      _rules[index]['isActive'] = active;
    });

    // Sync active state to Android Blocking Service
    AndroidBlockingService.setFocusActive(active);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          active
              ? '${_rules[index]['title']} Activated! Accessibility Blocker Synced.'
              : '${_rules[index]['title']} Deactivated.',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: active ? AppTheme.primary : AppTheme.surfaceCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _addNewRuleDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Create Custom Schedule Rule',
          style: GoogleFonts.outfit(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Rule Title (e.g. Study Lock)',
                labelStyle: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Default window: 14:00 - 18:00 (Daily)',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _rules.add({
                    'id': 'rule_${DateTime.now().millisecondsSinceEpoch}',
                    'title': titleController.text,
                    'subtitle': 'Custom timed app restriction rule',
                    'startTime': '14:00',
                    'endTime': '18:00',
                    'days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
                    'isActive': true,
                    'color': const Color(0xFF00F5A0),
                    'icon': Icons.schedule_rounded,
                  });
                });
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('Create Rule', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Scheduled Blocking Rules',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewRuleDialog,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Schedule Rule',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
        ),
      ),
      body: LiquidBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Info Header ──
                LiquidGlassPanel(
                  padding: const EdgeInsets.all(20),
                  radius: 24,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule_rounded,
                          color: AppTheme.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Automated Guard Timers',
                              style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Rules automatically lock distracting apps and adult content during set time windows.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Active Schedule Rules (${_rules.where((r) => r['isActive'] == true).length}/${_rules.length})',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                ...List.generate(_rules.length, (idx) {
                  final rule = _rules[idx];
                  final bool active = rule['isActive'] as bool;
                  final ruleColor = rule['color'] as Color;
                  final days = (rule['days'] as List<String>).join(' • ');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: LiquidGlassPanel(
                      padding: const EdgeInsets.all(18),
                      radius: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: ruleColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  rule['icon'] as IconData,
                                  color: ruleColor,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rule['title'] as String,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      rule['subtitle'] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: active,
                                activeThumbColor: ruleColor,
                                onChanged: (v) => _toggleRule(idx, v),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${rule['startTime']} - ${rule['endTime']}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: ruleColor,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                days,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
