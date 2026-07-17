import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../../../gamification/presentation/viewmodels/gamification_notifier.dart';
import '../../data/models/habit_model.dart';
import '../viewmodels/habit_notifier.dart';

class HabitTrackerView extends ConsumerStatefulWidget {
  const HabitTrackerView({super.key});

  @override
  ConsumerState<HabitTrackerView> createState() => _HabitTrackerViewState();
}

class _HabitTrackerViewState extends ConsumerState<HabitTrackerView> {
  void _showAddHabitSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 10,
            left: 20,
            right: 20,
          ),
          child: LiquidGlassPanel(
            padding: const EdgeInsets.all(20),
            shadows: const [],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    LiquidIconBadge(icon: Icons.add_rounded, color: AppTheme.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'New habit',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Habit name',
                    prefixIcon: Icon(Icons.auto_awesome_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descController,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Purpose',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 22),
                GradientActionButton(
                  label: 'Start habit',
                  icon: Icons.check_rounded,
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    await ref.read(habitListNotifierProvider.notifier).addHabit(
                          title,
                          description: descController.text.trim().isEmpty
                              ? null
                              : descController.text.trim(),
                        );
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isCompletedToday(HabitModel habit) {
    if (habit.lastCompleted == null) return false;
    final now = DateTime.now();
    final last = habit.lastCompleted!;
    return last.year == now.year && last.month == now.month && last.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitListNotifierProvider);
    final stats = ref.watch(gamificationProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPageHeader(
                title: 'Habits',
                subtitle: 'Small daily rituals, quietly compounded.',
                icon: Icons.spa_rounded,
                trailing: StatusPill(
                  label: '${stats.coins} coins',
                  icon: Icons.monetization_on_rounded,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 18),
              _ProtectorCard(stats: stats),
              const SizedBox(height: 22),
              SectionTitle(
                title: 'Daily rituals',
                action: TextButton.icon(
                  onPressed: () => _showAddHabitSheet(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add'),
                ),
              ),
              const SizedBox(height: 12),
              habitsAsync.when(
                data: (habits) {
                  if (habits.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: EmptyState(
                        icon: Icons.spa_outlined,
                        title: 'No habits yet',
                        message: 'Start with one repeatable action for today.',
                      ),
                    );
                  }

                  return Column(
                    children: habits.map((habit) {
                      return _HabitCard(
                        habit: habit,
                        doneToday: _isCompletedToday(habit),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    'Error: $err',
                    style: const TextStyle(color: AppTheme.error),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProtectorCard extends StatelessWidget {
  final dynamic stats;

  const _ProtectorCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final targetXp = (stats.level * 100).clamp(100, 100000);
    final progress = (stats.xp / targetXp).clamp(0.0, 1.0);

    return LiquidGlassPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusPill(
                label: 'Level ${stats.level}',
                icon: Icons.workspace_premium_rounded,
                color: AppTheme.primary,
                filled: true,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Protector', style: Theme.of(context).textTheme.titleLarge),
              ),
              Text(
                '${stats.xp} / $targetXp XP',
                style: GoogleFonts.inter(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusPill(
                label: 'Focus ${stats.focusStreak}d',
                icon: Icons.timer_rounded,
                color: AppTheme.secondary,
              ),
              StatusPill(
                label: 'Habit ${stats.habitStreak}d',
                icon: Icons.spa_rounded,
                color: AppTheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HabitCard extends ConsumerWidget {
  final HabitModel habit;
  final bool doneToday;

  const _HabitCard({
    required this.habit,
    required this.doneToday,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LiquidGlassPanel(
        padding: const EdgeInsets.all(14),
        borderColor: doneToday ? AppTheme.borderAccent : null,
        tint: doneToday ? AppTheme.primaryLight : null,
        child: Row(
          children: [
            Tooltip(
              message: doneToday ? 'Completed today' : 'Complete habit',
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: doneToday
                    ? null
                    : () => ref
                        .read(habitListNotifierProvider.notifier)
                        .completeHabit(habit.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: doneToday ? AppTheme.primaryGradient : null,
                    color: doneToday ? null : AppTheme.surfaceRaised,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: doneToday ? AppTheme.primary : AppTheme.border,
                      width: 1.4,
                    ),
                    boxShadow: doneToday ? AppTheme.primaryGlow : null,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: doneToday ? AppTheme.onPrimary : AppTheme.textHint,
                    size: 25,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: doneToday ? TextDecoration.lineThrough : null,
                          color: doneToday ? AppTheme.textSecondary : AppTheme.textPrimary,
                        ),
                  ),
                  if (habit.description != null && habit.description!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      habit.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      StatusPill(
                        label: '${habit.currentStreak}d current',
                        icon: Icons.local_fire_department_rounded,
                        color: AppTheme.error,
                      ),
                      StatusPill(
                        label: '${habit.longestStreak}d best',
                        icon: Icons.emoji_events_rounded,
                        color: AppTheme.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Delete habit',
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppTheme.textHint,
              onPressed: () =>
                  ref.read(habitListNotifierProvider.notifier).deleteHabit(habit.id),
            ),
          ],
        ),
      ),
    );
  }
}
