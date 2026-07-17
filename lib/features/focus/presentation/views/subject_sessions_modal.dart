import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/focus_session_model.dart';

class SubjectSessionsModal extends StatefulWidget {
  final List<FocusSessionModel> sessions;
  final String? initialSubjectFilter;

  const SubjectSessionsModal({
    super.key,
    required this.sessions,
    this.initialSubjectFilter,
  });

  static Future<void> show(
    BuildContext context,
    List<FocusSessionModel> sessions, {
    String? subjectFilter,
  }) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SubjectSessionsModal(
        sessions: sessions,
        initialSubjectFilter: subjectFilter,
      ),
    );
  }

  @override
  State<SubjectSessionsModal> createState() => _SubjectSessionsModalState();
}

class _SubjectSessionsModalState extends State<SubjectSessionsModal> {
  late String _selectedSubject;

  @override
  void initState() {
    super.initState();
    final allSubjects = widget.sessions
        .where((s) => s.isCompleted)
        .map((s) => s.subject.trim().isEmpty ? 'General' : s.subject.trim())
        .toSet()
        .toList();
    if (widget.initialSubjectFilter != null && allSubjects.contains(widget.initialSubjectFilter)) {
      _selectedSubject = widget.initialSubjectFilter!;
    } else {
      _selectedSubject = 'All';
    }
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${minutes}m';
  }

  String _formatDateTime(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} • $hour:$minute $amPm';
  }

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

  @override
  Widget build(BuildContext context) {
    final completedSessions = widget.sessions.where((s) => s.isCompleted).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    final subjects = completedSessions
        .map((s) => s.subject.trim().isEmpty ? 'General' : s.subject.trim())
        .toSet()
        .toList()
      ..sort();

    final filteredSessions = _selectedSubject == 'All'
        ? completedSessions
        : completedSessions.where((s) {
            final sub = s.subject.trim().isEmpty ? 'General' : s.subject.trim();
            return sub == _selectedSubject;
          }).toList();

    final totalMinutes = filteredSessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.folder_special_rounded, color: AppTheme.secondary, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Focus Subject Vault',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '${filteredSessions.length} sessions • ${_formatDuration(totalMinutes)} total focus',
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
          const SizedBox(height: 16),
          // Subject Tag Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All Tags',
                  isSelected: _selectedSubject == 'All',
                  color: AppTheme.primary,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedSubject = 'All');
                  },
                ),
                ...List.generate(subjects.length, (index) {
                  final sub = subjects[index];
                  final color = _getColorForIndex(index);
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _FilterChip(
                      label: sub,
                      isSelected: _selectedSubject == sub,
                      color: color,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedSubject = sub);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: AppTheme.border.withValues(alpha: 0.8), height: 1),
          // Session list
          Expanded(
            child: filteredSessions.isEmpty
                ? Center(
                    child: Text(
                      'No focus sessions found for this subject.',
                      style: GoogleFonts.inter(color: AppTheme.textHint, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredSessions.length,
                    itemBuilder: (context, index) {
                      final session = filteredSessions[index];
                      final sub = session.subject.trim().isEmpty ? 'General' : session.subject.trim();
                      final colorIndex = subjects.indexOf(sub);
                      final tagColor = colorIndex >= 0 ? _getColorForIndex(colorIndex) : AppTheme.primary;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceRaised,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: tagColor.withValues(alpha: 0.3), width: 0.8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: tagColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: tagColor.withValues(alpha: 0.5), blurRadius: 6),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sub,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDateTime(session.startTime),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppTheme.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (session.isDeepFocus) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppTheme.accent.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  'Deep Focus',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.accent,
                                  ),
                                ),
                              ),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: tagColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _formatDuration(session.durationMinutes),
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: tagColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
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
          color: isSelected ? color.withValues(alpha: 0.22) : AppTheme.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppTheme.border.withValues(alpha: 0.8),
            width: isSelected ? 1.5 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? color : AppTheme.textHint,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
