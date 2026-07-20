import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../../core/db/isar_service.dart';
import '../../../focus/data/models/focus_session_model.dart';
import '../../../recovery/data/models/sobriety_model.dart';
import '../../../wellbeing/data/models/wellbeing_model.dart';

class InsightCardModel {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final double progress;
  final String valueText;

  const InsightCardModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.progress = 0.0,
    required this.valueText,
  });
}

final smartInsightsProvider = FutureProvider<List<InsightCardModel>>((
  ref,
) async {
  final isar = IsarService.instance;

  final now = DateTime.now();
  final sevenDaysAgo = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 7));

  // 1. Fetch last 7 days of Focus Sessions
  final sessions = await isar.focusSessionModels
      .filter()
      .startTimeGreaterThan(sevenDaysAgo)
      .and()
      .isCompletedEqualTo(true)
      .findAll();

  // 2. Fetch last 7 days of Wellbeing Logs
  final logs = await isar.wellbeingLogModels
      .filter()
      .dateGreaterThan(sevenDaysAgo)
      .findAll();

  // 3. Fetch Sobriety Details
  final sobriety = await isar.sobrietyModels.where().findFirst();

  final insightsList = <InsightCardModel>[];

  // ──── A. Peak Focus Hotspot Calculation ────
  if (sessions.isNotEmpty) {
    final Map<String, int> timeSlots = {
      'Morning (6 AM - 12 PM)': 0,
      'Afternoon (12 PM - 6 PM)': 0,
      'Evening (6 PM - 12 AM)': 0,
      'Night (12 AM - 6 AM)': 0,
    };

    for (final s in sessions) {
      final hour = s.startTime.hour;
      if (hour >= 6 && hour < 12) {
        timeSlots['Morning (6 AM - 12 PM)'] =
            (timeSlots['Morning (6 AM - 12 PM)'] ?? 0) + s.durationMinutes;
      } else if (hour >= 12 && hour < 18) {
        timeSlots['Afternoon (12 PM - 6 PM)'] =
            (timeSlots['Afternoon (12 PM - 6 PM)'] ?? 0) + s.durationMinutes;
      } else if (hour >= 18 && hour < 24) {
        timeSlots['Evening (6 PM - 12 AM)'] =
            (timeSlots['Evening (6 PM - 12 AM)'] ?? 0) + s.durationMinutes;
      } else {
        timeSlots['Night (12 AM - 6 AM)'] =
            (timeSlots['Night (12 AM - 6 AM)'] ?? 0) + s.durationMinutes;
      }
    }

    var peakSlot = 'Morning (6 AM - 12 PM)';
    var maxMin = 0;
    timeSlots.forEach((key, val) {
      if (val > maxMin) {
        maxMin = val;
        peakSlot = key;
      }
    });

    if (maxMin > 0) {
      insightsList.add(
        InsightCardModel(
          title: 'Peak Focus Window',
          description:
              'Your mind operates at peak efficiency during the $peakSlot. Consider scheduling your most complex tasks in this block.',
          icon: Icons.wb_twilight_rounded,
          color: const Color(0xFF00F5A0),
          valueText: '${maxMin}m focus',
        ),
      );
    }
  }

  // ──── B. Sleep-Focus Correlation ────
  if (logs.isNotEmpty && sessions.isNotEmpty) {
    double focusHighSleepSum = 0;
    int daysHighSleep = 0;
    double focusLowSleepSum = 0;
    int daysLowSleep = 0;

    for (final log in logs) {
      final daySessions = sessions.where(
        (s) =>
            s.startTime.year == log.date.year &&
            s.startTime.month == log.date.month &&
            s.startTime.day == log.date.day,
      );
      final totalFocusMinutes = daySessions.fold<int>(
        0,
        (sum, s) => sum + s.durationMinutes,
      );

      if (log.sleepDurationHours >= 7.0) {
        focusHighSleepSum += totalFocusMinutes;
        daysHighSleep++;
      } else if (log.sleepDurationHours > 0.0) {
        focusLowSleepSum += totalFocusMinutes;
        daysLowSleep++;
      }
    }

    final avgFocusHigh = daysHighSleep > 0
        ? focusHighSleepSum / daysHighSleep
        : 0.0;
    final avgFocusLow = daysLowSleep > 0
        ? focusLowSleepSum / daysLowSleep
        : 0.0;

    if (daysHighSleep > 0 && daysLowSleep > 0 && avgFocusHigh > avgFocusLow) {
      final percentDiff =
          (((avgFocusHigh - avgFocusLow) /
                      (avgFocusLow > 0 ? avgFocusLow : 1)) *
                  100)
              .toInt();
      insightsList.add(
        InsightCardModel(
          title: 'Sleep Impact detected',
          description:
              'You focused $percentDiff% longer on days with over 7 hours of rest. Sleep directly fuels the prefrontal cortex for self-discipline.',
          icon: Icons.nightlight_round,
          color: const Color(0xFF00D4FF),
          valueText: '+$percentDiff% focus',
        ),
      );
    }
  }

  // ──── C. Hydration Analysis ────
  final avgWater = logs.isEmpty
      ? 0.0
      : logs.fold<double>(0.0, (sum, l) => sum + l.waterIntakeLiters) /
            logs.length;
  if (avgWater > 0.0) {
    final status = avgWater >= 1.8 ? 'Excellent hydration' : 'Need more fluids';
    insightsList.add(
      InsightCardModel(
        title: 'Hydration Consistency',
        description: avgWater >= 1.8
            ? 'Great job! Your average water intake is ${avgWater.toStringAsFixed(1)}L. A hydrated brain maintains attention 15% longer.'
            : 'Your daily average is ${avgWater.toStringAsFixed(1)}L. Mild dehydration drops focus. Aim for 2.0L to steady your brain.',
        icon: Icons.water_drop_rounded,
        color: const Color(0xFF3399FF),
        progress: (avgWater / 2.0).clamp(0.0, 1.0),
        valueText: '${avgWater.toStringAsFixed(1)}L avg',
      ),
    );
  }

  // ──── D. Sobriety Streak Milestone ────
  final streak = sobriety?.currentStreakDays ?? 0;
  final nextMilestone = _getNextMilestone(streak);
  final milestoneProgress = nextMilestone > 0 ? streak / nextMilestone : 1.0;

  insightsList.add(
    InsightCardModel(
      title: 'Milestone Progress',
      description: streak >= nextMilestone
          ? 'You have secured all recovery milestones! Outstanding discipline.'
          : 'You are $streak days into your $nextMilestone-day sobriety milestone. Secure today\'s shield to progress.',
      icon: Icons.emoji_events_rounded,
      color: const Color(0xFFFFB800),
      progress: milestoneProgress.clamp(0.0, 1.0),
      valueText: '$streak / $nextMilestone days',
    ),
  );

  // Fallback: If no analytical insights yet
  if (insightsList.length < 2) {
    insightsList.add(
      const InsightCardModel(
        title: 'Daily Reflection Tip',
        description:
            'Take 2 minutes every night to log sleep, water, and mood. This helps Antigravity run correlation analytics for your digital wellbeing.',
        icon: Icons.lightbulb_outline_rounded,
        color: Colors.pinkAccent,
        valueText: 'Insights ready',
      ),
    );
  }

  return insightsList;
});

int _getNextMilestone(int streak) {
  if (streak < 3) return 3;
  if (streak < 7) return 7;
  if (streak < 14) return 14;
  if (streak < 30) return 30;
  if (streak < 90) return 90;
  return 365;
}
