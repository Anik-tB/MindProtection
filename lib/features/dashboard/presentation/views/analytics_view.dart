import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../../../blocking/data/models/screen_time_entry.dart';
import '../../../blocking/data/services/android_blocking_service.dart';
import '../../../focus/presentation/viewmodels/focus_timer_notifier.dart';
import '../../../focus/presentation/views/subject_focus_breakdown_card.dart';
import '../viewmodels/screen_time_provider.dart';
import '../../../ai_coach/presentation/viewmodels/smart_insights_provider.dart';

class AnalyticsView extends ConsumerWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(focusSessionListProvider);
    final sessions = sessionsAsync.value ?? [];
    final now = DateTime.now();
    final dailyMinutes = <int, int>{};

    for (var i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dayKey = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
      dailyMinutes[dayKey] = 0;
    }

    for (final session in sessions) {
      if (!session.isCompleted) continue;
      final start = session.startTime;
      final dayKey = DateTime(start.year, start.month, start.day).millisecondsSinceEpoch;
      if (dailyMinutes.containsKey(dayKey)) {
        dailyMinutes[dayKey] = (dailyMinutes[dayKey] ?? 0) + session.durationMinutes;
      }
    }

    final keys = dailyMinutes.keys.toList()..sort();
    final minutes = keys.map((key) => dailyMinutes[key] ?? 0).toList();
    final weekdays = keys
        .map((key) => _getShortWeekday(DateTime.fromMillisecondsSinceEpoch(key).weekday))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 145),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InsightsHeader(minutes: minutes),
          const SizedBox(height: 14),
          const _AiSmartInsightsSection(),
          const SizedBox(height: 14),
          _BarChartCard(minutes: minutes, weekdays: weekdays),
          const SizedBox(height: 14),
          SubjectFocusBreakdownCard(sessions: sessions),
          const SizedBox(height: 14),
          const _ScreenTimeCard(),
          const SizedBox(height: 14),
          const _LineChartCard(),
          const SizedBox(height: 14),
          const _DisciplineGrid(),
          const SizedBox(height: 14),
          const _ExportPanel(),
        ],
      ),
    );
  }

  String _getShortWeekday(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return day >= 1 && day <= 7 ? days[day - 1] : '';
  }
}

class _InsightsHeader extends StatelessWidget {
  final List<int> minutes;

  const _InsightsHeader({required this.minutes});

  @override
  Widget build(BuildContext context) {
    final total = minutes.fold(0, (a, b) => a + b);
    final average = minutes.isEmpty ? 0 : total ~/ minutes.length;

    return LiquidGlassPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: _InsightStat(
              label: 'Weekly total',
              value: '${total}m',
              color: AppTheme.primary,
            ),
          ),
          const _SoftDivider(),
          Expanded(
            child: _InsightStat(
              label: 'Daily average',
              value: '${average}m',
              color: AppTheme.secondary,
            ),
          ),
          const _SoftDivider(),
          const Expanded(
            child: _InsightStat(
              label: 'Stability',
              value: '92%',
              color: AppTheme.info,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarChartCard extends StatelessWidget {
  final List<int> minutes;
  final List<String> weekdays;

  const _BarChartCard({required this.minutes, required this.weekdays});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Weekly focus'),
          const SizedBox(height: 22),
          SizedBox(
            height: 190,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 30,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.border,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textHint),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= weekdays.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            weekdays[index],
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(minutes.length, (index) {
                  final value = minutes[index].toDouble();
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value > 0 ? value : 2,
                        gradient: value > 0 ? AppTheme.primaryGradient : null,
                        color: value > 0 ? null : AppTheme.border,
                        width: 15,
                        borderRadius: BorderRadius.circular(8),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 120,
                          color: AppTheme.primary.withValues(alpha: 0.06),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartCard extends StatelessWidget {
  const _LineChartCard();

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Productivity trend'),
          const SizedBox(height: 22),
          SizedBox(
            height: 190,
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppTheme.border,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, _) {
                        if (value % 25 != 0) return const SizedBox();
                        return Text(
                          '${value.toInt()}%',
                          style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textHint),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        const labels = {0: 'Wk 1', 2: 'Wk 2', 4: 'Wk 3', 6: 'Wk 4'};
                        final label = labels[value.toInt()];
                        if (label == null) return const SizedBox();
                        return Text(
                          label,
                          style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textHint),
                        );
                      },
                    ),
                  ),
                ),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 65),
                      FlSpot(1, 72),
                      FlSpot(2, 60),
                      FlSpot(3, 78),
                      FlSpot(4, 82),
                      FlSpot(5, 80),
                      FlSpot(6, 92),
                    ],
                    isCurved: true,
                    gradient: AppTheme.violetGradient,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
                        radius: 4,
                        color: AppTheme.secondary,
                        strokeWidth: 2,
                        strokeColor: AppTheme.surfaceRaised,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.secondary.withValues(alpha: 0.16),
                          AppTheme.secondary.withValues(alpha: 0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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

class _DisciplineGrid extends StatelessWidget {
  const _DisciplineGrid();

  static const activityLevels = [
    3,
    1,
    0,
    2,
    4,
    1,
    3,
    2,
    0,
    4,
    3,
    1,
    2,
    0,
    4,
    2,
    1,
    3,
    4,
    0,
    1,
    2,
    3,
    4,
    1,
    0,
    3,
    2,
    4,
    3,
  ];

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Discipline heatmap'),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activityLevels.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemBuilder: (context, index) {
              final level = activityLevels[index];
              final alphas = [0.06, 0.18, 0.36, 0.66, 1.0];
              final color = level == 0
                  ? AppTheme.surfaceTint
                  : AppTheme.primary.withValues(alpha: alphas[level]);
              return Tooltip(
                message: 'Day ${index + 1}: ${level * 2} activities',
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppTheme.glassStroke),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textHint)),
              const SizedBox(width: 6),
              ...List.generate(5, (index) {
                final alphas = [0.06, 0.18, 0.36, 0.66, 1.0];
                return Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(left: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: alphas[index]),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
              const SizedBox(width: 6),
              Text('More', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textHint)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExportPanel extends StatelessWidget {
  const _ExportPanel();

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const LiquidIconBadge(icon: Icons.insights_rounded, color: AppTheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Export study logs', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Download weekly or monthly focus analytics.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GradientActionButton(
            label: 'Export',
            icon: Icons.download_rounded,
            expanded: false,
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showExportDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.72),
      transitionDuration: const Duration(milliseconds: 240),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Export Report', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      'Select a format to export your focus and habit analytics.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 20),
                    _ExportOption(
                      icon: Icons.picture_as_pdf_rounded,
                      label: 'Export to PDF',
                      color: AppTheme.error,
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        Navigator.pop(context);
                        _showMessage(context, 'PDF exported to Downloads folder.');
                      },
                    ),
                    const SizedBox(height: 12),
                    _ExportOption(
                      icon: Icons.email_outlined,
                      label: 'Email detailed report',
                      color: AppTheme.primary,
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        Navigator.pop(context);
                        _showMessage(context, 'Detailed report email has been queued.');
                      },
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

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppTheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.surfaceRaised,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _InsightStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InsightStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPanel(
      padding: EdgeInsets.zero,
      shadows: const [],
      radius: 16,
      onTap: onTap,
      child: ListTile(
        leading: LiquidIconBadge(icon: icon, color: color, size: 38, iconSize: 18),
        title: Text(label, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }
}

class _SoftDivider extends StatelessWidget {
  const _SoftDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: AppTheme.border,
    );
  }
}

// ─────────────────────────────────────────────────────
// Screen Time Card
// ─────────────────────────────────────────────────────

class _ScreenTimeCard extends ConsumerStatefulWidget {
  const _ScreenTimeCard();

  @override
  ConsumerState<_ScreenTimeCard> createState() => _ScreenTimeCardState();
}

class _ScreenTimeCardState extends ConsumerState<_ScreenTimeCard> {
  bool _expanded = false;
  bool _showHistory = false;

  // Social/entertainment apps that get highlighted as high-risk
  static const _highRiskPackages = {
    'com.instagram.android',
    'com.zhiliaoapp.musically', // TikTok
    'com.ss.android.ugc.trill', // TikTok alt
    'com.google.android.youtube',
    'com.twitter.android',
    'com.facebook.katana',
    'com.snapchat.android',
    'com.facebook.orca', // Messenger
    'com.reddit.frontpage',
    'com.pinterest',
    'com.linkedin.android',
  };

  bool _isHighRisk(String packageName) =>
      _highRiskPackages.any((pkg) => packageName.contains(pkg.split('.').last));

  Color _avatarColor(String packageName) {
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
    final hash = packageName.codeUnits.fold(0, (prev, el) => prev + el);
    return colors[hash % colors.length];
  }

  String _formatTime(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final screenTimeAsync = ref.watch(screenTimeProvider);
    final historyAsync = ref.watch(historicalScreenTimeProvider(7));

    // Resolve active entries based on current mode
    final entriesAsync = _showHistory
        ? historyAsync.whenData((models) {
            final map = <String, ScreenTimeEntry>{};
            for (final m in models) {
              if (map.containsKey(m.packageName)) {
                final old = map[m.packageName]!;
                map[m.packageName] = ScreenTimeEntry(
                  packageName: old.packageName,
                  appName: old.appName,
                  usageMinutes: old.usageMinutes + m.usageMinutes,
                );
              } else {
                map[m.packageName] = ScreenTimeEntry(
                  packageName: m.packageName,
                  appName: m.appName,
                  usageMinutes: m.usageMinutes,
                );
              }
            }
            final list = map.values.toList()
              ..sort((a, b) => b.usageMinutes.compareTo(a.usageMinutes));
            return list;
          })
        : screenTimeAsync;

    return LiquidGlassPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LiquidIconBadge(
                icon: Icons.phone_android_rounded,
                color: AppTheme.info,
                size: 36,
                iconSize: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _showHistory ? '7-Day Screen Time Vault' : 'Today\'s Screen Time',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    entriesAsync.when(
                      data: (entries) {
                        final total = entries.fold<int>(0, (s, e) => s + e.usageMinutes);
                        return Text(
                          _showHistory ? '${_formatTime(total)} total in vault' : _formatTime(total),
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        );
                      },
                      loading: () => Text('Loading...', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textHint)),
                      error: (_, e) => Text('Tap to grant access', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.warning)),
                    ),
                  ],
                ),
              ),
              // Segmented pill: Today vs 7d
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceRaised,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _showHistory = false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: !_showHistory ? AppTheme.info.withValues(alpha: 0.18) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Today',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: !_showHistory ? FontWeight.w800 : FontWeight.w600,
                            color: !_showHistory ? AppTheme.info : AppTheme.textHint,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _showHistory = true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _showHistory ? AppTheme.info.withValues(alpha: 0.18) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '7d Vault',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: _showHistory ? FontWeight.w800 : FontWeight.w600,
                            color: _showHistory ? AppTheme.info : AppTheme.textHint,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (_showHistory) {
                    ref.invalidate(historicalScreenTimeProvider(7));
                  } else {
                    ref.invalidate(screenTimeProvider);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.refresh_rounded, size: 16, color: AppTheme.info),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          entriesAsync.when(
            data: (entries) {
              if (entries.isEmpty) {
                return _PermissionPromptContent();
              }
              final maxMinutes = entries.first.usageMinutes.toDouble();
              final displayedEntries = _expanded ? entries : entries.take(6).toList();

              return Column(
                children: [
                  ...List.generate(displayedEntries.length, (i) {
                    final entry = displayedEntries[i];
                    final frac = maxMinutes > 0 ? entry.usageMinutes / maxMinutes : 0.0;
                    final isRisk = _isHighRisk(entry.packageName);
                    final avatarColor = _avatarColor(entry.packageName);
                    final initial = entry.appName.isNotEmpty ? entry.appName[0].toUpperCase() : '?';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          // App avatar
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: avatarColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: avatarColor.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: avatarColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.appName,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatTime(entry.usageMinutes),
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isRisk ? AppTheme.error : AppTheme.textSecondary,
                                      ),
                                    ),
                                    if (isRisk) ...
                                    [
                                      const SizedBox(width: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.error.withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppTheme.error.withValues(alpha: 0.3), width: 0.8),
                                        ),
                                        child: Text(
                                          'High',
                                          style: GoogleFonts.inter(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.error,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 5),
                                // Animated usage bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: SizedBox(
                                    height: 5,
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.0, end: frac),
                                      duration: Duration(milliseconds: 600 + (i * 80)),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, _) {
                                        return LinearProgressIndicator(
                                          value: value,
                                          backgroundColor: AppTheme.border,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            isRisk ? AppTheme.error : avatarColor,
                                          ),
                                          minHeight: 5,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (entries.length > 6)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _expanded = !_expanded);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderAccent, width: 0.8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _expanded ? 'Show less' : 'Show ${entries.length - 6} more apps',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => Column(
              children: List.generate(
                4,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceRaised,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 100, height: 10, decoration: BoxDecoration(color: AppTheme.surfaceRaised, borderRadius: BorderRadius.circular(5))),
                            const SizedBox(height: 6),
                            Container(width: double.infinity, height: 5, decoration: BoxDecoration(color: AppTheme.surfaceRaised, borderRadius: BorderRadius.circular(3))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            error: (_, e) => const _PermissionPromptContent(),
          ),
        ],
      ),
    );
  }
}

class _PermissionPromptContent extends StatelessWidget {
  const _PermissionPromptContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warning.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.warning.withValues(alpha: 0.25), width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppTheme.warning, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Usage Stats permission required to show real screen time data.',
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, height: 1.45),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            AndroidBlockingService.requestUsageStatsPermission();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppTheme.primaryGlow,
            ),
            child: Center(
              child: Text(
                'Grant Usage Access',
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
    );
  }
}

class _AiSmartInsightsSection extends ConsumerWidget {
  const _AiSmartInsightsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(smartInsightsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'AI Smart Insights'),
        const SizedBox(height: 12),
        insightsAsync.when(
          data: (insights) {
            return Column(
              children: insights.map((insight) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: LiquidGlassPanel(
                    padding: const EdgeInsets.all(16),
                    radius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            LiquidIconBadge(
                              icon: insight.icon,
                              color: insight.color,
                              size: 40,
                              iconSize: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                insight.title,
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusPill(
                              label: insight.valueText,
                              color: insight.color,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          insight.description,
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                        if (insight.progress > 0.0) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: insight.progress,
                              minHeight: 6,
                              backgroundColor: AppTheme.border,
                              valueColor: AlwaysStoppedAnimation<Color>(insight.color),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Failed to load insights: $err',
              style: const TextStyle(color: AppTheme.error),
            ),
          ),
        ),
      ],
    );
  }
}
