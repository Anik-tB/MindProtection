import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../../data/models/focus_session_model.dart';
import 'subject_sessions_modal.dart';

class SubjectFocusBreakdownCard extends StatelessWidget {
  final List<FocusSessionModel> sessions;

  const SubjectFocusBreakdownCard({super.key, required this.sessions});

  Color _getColorForIndex(int index) {
    final colors = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.accent,
      AppTheme.info,
      AppTheme.warning,
      const Color(0xFF8A2BE2),
      const Color(0xFFFF7675),
      const Color(0xFF00CEC9),
    ];
    return colors[index % colors.length];
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final completedSessions = sessions.where((s) => s.isCompleted).toList();
    final subjectMinutes = <String, int>{};

    for (final session in completedSessions) {
      final sub = session.subject.trim().isEmpty ? 'General' : session.subject.trim();
      subjectMinutes[sub] = (subjectMinutes[sub] ?? 0) + session.durationMinutes;
    }

    final totalFocusMinutes = subjectMinutes.values.fold<int>(0, (sum, val) => sum + val);

    final sortedSubjects = subjectMinutes.keys.toList()
      ..sort((a, b) => (subjectMinutes[b] ?? 0).compareTo(subjectMinutes[a] ?? 0));

    return LiquidGlassPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const LiquidIconBadge(
                icon: Icons.pie_chart_outline_rounded,
                color: AppTheme.secondary,
                size: 38,
                iconSize: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subject Focus Breakdown',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${sortedSubjects.length} subjects • ${_formatDuration(totalFocusMinutes)} total',
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
                  SubjectSessionsModal.show(context, sessions);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Filter Vault',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: AppTheme.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (sortedSubjects.isEmpty || totalFocusMinutes <= 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No completed focus sessions yet. Start a timer tagged with a subject!',
                  style: GoogleFonts.inter(color: AppTheme.textHint, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else ...[
            // Multi-color horizontal breakdown bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 8,
                child: Row(
                  children: List.generate(sortedSubjects.length, (index) {
                    final sub = sortedSubjects[index];
                    final min = subjectMinutes[sub] ?? 0;
                    final flex = (min * 100 ~/ totalFocusMinutes).clamp(1, 100);
                    final color = _getColorForIndex(index);
                    return Expanded(
                      flex: flex,
                      child: Container(color: color),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Subject Tag rows
            ...List.generate(sortedSubjects.length, (index) {
              final sub = sortedSubjects[index];
              final min = subjectMinutes[sub] ?? 0;
              final percent = totalFocusMinutes > 0 ? (min * 100 / totalFocusMinutes).round() : 0;
              final color = _getColorForIndex(index);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  SubjectSessionsModal.show(context, sessions, subjectFilter: sub);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceRaised,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          sub,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _formatDuration(min),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 42,
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$percent%',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textHint,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.textHint.withValues(alpha: 0.6)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
