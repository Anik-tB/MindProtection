import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../../data/models/habit_model.dart';
import 'habit_annual_heatmap_modal.dart';

class HabitContributionHeatmapCard extends StatelessWidget {
  final List<HabitModel> habits;

  const HabitContributionHeatmapCard({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    // 1. Build a frequency map for the last 126 days (18 weeks)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final frequencyMap = <int, int>{};

    for (final habit in habits) {
      final history = habit.completionHistory ?? [];
      for (final dt in history) {
        final cleanDate = DateTime(dt.year, dt.month, dt.day);
        final key = cleanDate.millisecondsSinceEpoch;
        frequencyMap[key] = (frequencyMap[key] ?? 0) + 1;
      }
    }

    // 2. Determine grid dimensions (18 columns x 7 rows)
    const weeks = 18;
    const totalDays = weeks * 7;
    // Align so that the bottom-right cell corresponds to the end of this current week or today
    final currentWeekday = today.weekday; // 1 = Mon, 7 = Sun
    final endDate = today.add(Duration(days: 7 - currentWeekday));
    final startDate = endDate.subtract(const Duration(days: totalDays - 1));

    // Calculate total completions in this 18-week window
    int totalCompletions = 0;
    for (int i = 0; i < totalDays; i++) {
      final day = startDate.add(Duration(days: i));
      if (day.isAfter(today)) continue;
      final key = day.millisecondsSinceEpoch;
      totalCompletions += frequencyMap[key] ?? 0;
    }

    return LiquidGlassPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LiquidIconBadge(
                icon: Icons.calendar_month_rounded,
                color: AppTheme.primary,
                size: 38,
                iconSize: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Discipline Heatmap',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$totalCompletions rituals completed in 18 weeks',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  HabitAnnualHeatmapModal.show(context, habits);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '365d Grid',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: AppTheme.primaryLight,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Month labels
          Row(
            children: [
              const SizedBox(width: 26), // offset for weekday labels
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: _buildGridContent(startDate, totalDays, today, frequencyMap),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Less', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textHint)),
              const SizedBox(width: 6),
              ...List.generate(5, (level) {
                final color = _getColorForLevel(level);
                return Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: level == 0 ? AppTheme.glassStroke : color.withValues(alpha: 0.6),
                      width: 0.8,
                    ),
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

  List<Widget> _buildGridContent(
      DateTime startDate, int totalDays, DateTime today, Map<int, int> frequencyMap) {
    final weeks = totalDays ~/ 7;
    final columns = <Widget>[];

    // Day of week labels on left
    const weekdayLabels = ['M', '', 'W', '', 'F', '', 'S'];
    final labelColumn = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (row) {
        return SizedBox(
          height: 14,
          child: Center(
            child: Text(
              weekdayLabels[row],
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppTheme.textHint,
              ),
            ),
          ),
        );
      }),
    );

    columns.add(Padding(
      padding: const EdgeInsets.only(right: 8),
      child: labelColumn,
    ));

    // Columns per week
    for (int col = 0; col < weeks; col++) {
      final cells = <Widget>[];
      for (int row = 0; row < 7; row++) {
        final dayIndex = col * 7 + row;
        final day = startDate.add(Duration(days: dayIndex));
        final isFuture = day.isAfter(today);
        final count = isFuture ? 0 : (frequencyMap[day.millisecondsSinceEpoch] ?? 0);
        final level = isFuture ? -1 : _getLevel(count);
        final isToday = day.year == today.year && day.month == today.month && day.day == today.day;

        cells.add(
          Tooltip(
            message: isFuture
                ? 'Future date'
                : '${_formatDate(day)}: $count habit${count == 1 ? '' : 's'} completed',
            child: Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: isFuture ? AppTheme.surfaceTint.withValues(alpha: 0.3) : _getColorForLevel(level),
                borderRadius: BorderRadius.circular(3.5),
                border: Border.all(
                  color: isToday
                      ? AppTheme.accent
                      : (level <= 0 ? AppTheme.glassStroke : _getColorForLevel(level).withValues(alpha: 0.8)),
                  width: isToday ? 1.5 : 0.8,
                ),
                boxShadow: level == 4 ? AppTheme.primaryGlow : null,
              ),
            ),
          ),
        );
      }
      columns.add(Column(children: cells));
    }

    return columns;
  }

  int _getLevel(int count) {
    if (count <= 0) return 0;
    if (count == 1) return 1;
    if (count == 2) return 2;
    if (count == 3) return 3;
    return 4;
  }

  Color _getColorForLevel(int level) {
    switch (level) {
      case 0:
        return AppTheme.surfaceTint;
      case 1:
        return AppTheme.primary.withValues(alpha: 0.22);
      case 2:
        return AppTheme.primary.withValues(alpha: 0.45);
      case 3:
        return AppTheme.primary.withValues(alpha: 0.75);
      case 4:
        return AppTheme.primary;
      default:
        return AppTheme.surfaceTint.withValues(alpha: 0.3);
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
