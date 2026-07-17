import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../../data/models/habit_model.dart';

class HabitAnnualHeatmapModal extends StatelessWidget {
  final List<HabitModel> habits;

  const HabitAnnualHeatmapModal({super.key, required this.habits});

  static Future<void> show(BuildContext context, List<HabitModel> habits) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HabitAnnualHeatmapModal(habits: habits),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final frequencyMap = <int, int>{};
    int totalYearCompletions = 0;
    int maxDailyCompletions = 0;

    // Build 365-day map
    final startDate = today.subtract(const Duration(days: 364));
    for (final habit in habits) {
      final history = habit.completionHistory ?? [];
      for (final dt in history) {
        final cleanDate = DateTime(dt.year, dt.month, dt.day);
        if (cleanDate.isBefore(startDate) || cleanDate.isAfter(today)) continue;
        final key = cleanDate.millisecondsSinceEpoch;
        final count = (frequencyMap[key] ?? 0) + 1;
        frequencyMap[key] = count;
        totalYearCompletions++;
        if (count > maxDailyCompletions) maxDailyCompletions = count;
      }
    }

    // Sort habits by total historical completions
    final sortedHabits = List<HabitModel>.from(habits)
      ..sort((a, b) => (b.completionHistory?.length ?? 0).compareTo(a.completionHistory?.length ?? 0));

    // Calculate longest current and all-time streak across all habits
    int bestLongest = 0;
    int bestCurrent = 0;
    for (final h in habits) {
      if (h.longestStreak > bestLongest) bestLongest = h.longestStreak;
      if (h.currentStreak > bestCurrent) bestCurrent = h.currentStreak;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft.withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppTheme.borderAccent, width: 1),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppTheme.textHint.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const LiquidIconBadge(
                  icon: Icons.grid_view_rounded,
                  color: AppTheme.primary,
                  size: 42,
                  iconSize: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Annual Discipline Grid',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Past 365 Days • $totalYearCompletions total completions',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stat cards row
                  Row(
                    children: [
                      Expanded(
                        child: _StatPillCard(
                          title: 'Current Best Streak',
                          value: '$bestCurrent days',
                          icon: Icons.local_fire_department_rounded,
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatPillCard(
                          title: 'All-Time Record',
                          value: '$bestLongest days',
                          icon: Icons.emoji_events_rounded,
                          color: AppTheme.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '52-Week Contribution Grid',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scroll horizontally to review full yearly consistency.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textHint,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Full 52-week horizontal grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceRaised,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border, width: 0.8),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _buildAnnualGrid(startDate, 365, today, frequencyMap),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Habit Completion Leaderboard',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (sortedHabits.isEmpty)
                    Text('No habits found.', style: GoogleFonts.inter(color: AppTheme.textHint))
                  else
                    ...sortedHabits.map((h) {
                      final count = h.completionHistory?.length ?? 0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceRaised,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.border, width: 0.8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: count > 0 ? AppTheme.primary : AppTheme.textHint,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                h.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$count completions',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAnnualGrid(
      DateTime startDate, int totalDays, DateTime today, Map<int, int> frequencyMap) {
    // We align columns by week
    final weeks = (totalDays + 6) ~/ 7;
    final columns = <Widget>[];

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
                ? 'Future'
                : '${_formatDate(day)}: $count completion${count == 1 ? '' : 's'}',
            child: Container(
              width: 13,
              height: 13,
              margin: const EdgeInsets.all(1.2),
              decoration: BoxDecoration(
                color: isFuture
                    ? AppTheme.surfaceTint.withValues(alpha: 0.2)
                    : _getColorForLevel(level),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: isToday
                      ? AppTheme.accent
                      : (level <= 0
                          ? AppTheme.glassStroke
                          : _getColorForLevel(level).withValues(alpha: 0.8)),
                  width: isToday ? 1.5 : 0.6,
                ),
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
        return AppTheme.surfaceTint.withValues(alpha: 0.2);
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _StatPillCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatPillCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textHint, fontWeight: FontWeight.w600),
                ),
                Text(
                  value,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
