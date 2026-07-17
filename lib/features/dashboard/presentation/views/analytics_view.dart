import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../../../focus/presentation/viewmodels/focus_timer_notifier.dart';

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
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InsightsHeader(minutes: minutes),
          const SizedBox(height: 14),
          _BarChartCard(minutes: minutes, weekdays: weekdays),
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
            onPressed: () => _showExportDialog(context),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Export report', style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ExportOption(
                icon: Icons.picture_as_pdf_rounded,
                label: 'Export to PDF',
                color: AppTheme.error,
                onTap: () {
                  Navigator.pop(context);
                  _showMessage(context, 'PDF exported to downloads folder.');
                },
              ),
              const SizedBox(height: 10),
              _ExportOption(
                icon: Icons.email_outlined,
                label: 'Email detailed report',
                color: AppTheme.primary,
                onTap: () {
                  Navigator.pop(context);
                  _showMessage(context, 'Detailed report email has been sent.');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
