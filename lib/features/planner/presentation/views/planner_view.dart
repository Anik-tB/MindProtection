import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../../data/models/goal_model.dart';
import '../../data/models/routine_model.dart';
import '../../data/models/task_model.dart';
import '../viewmodels/goal_notifier.dart';
import '../viewmodels/routine_notifier.dart';
import '../viewmodels/task_notifier.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class PlannerView extends ConsumerStatefulWidget {
  const PlannerView({super.key});

  @override
  ConsumerState<PlannerView> createState() => _PlannerViewState();
}

class _PlannerViewState extends ConsumerState<PlannerView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddTaskSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    var selectedPriority = 'Medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return _SheetFrame(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SheetTitle(
                    icon: Icons.add_task_rounded,
                    title: 'Add task',
                    subtitle: 'Attach this task to the selected day.',
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _QuickPill(
                          label: '🧠 60m Deep Work Block',
                          onTap: () {
                            titleController.text = 'Deep Work Focus Block';
                            descController.text = 'Unbroken 60m focus on priority task.';
                            HapticFeedback.lightImpact();
                          },
                        ),
                        const SizedBox(width: 8),
                        _QuickPill(
                          label: '📵 Digital Detox Evening',
                          onTap: () {
                            titleController.text = 'Digital Detox Evening';
                            descController.text = 'Put phone in lockbox at 9:00 PM.';
                            HapticFeedback.lightImpact();
                          },
                        ),
                        const SizedBox(width: 8),
                        _QuickPill(
                          label: '📝 Weekly Review',
                          onTap: () {
                            titleController.text = 'Weekly Goal Review';
                            descController.text = 'Review streaks and plan upcoming anchors.';
                            HapticFeedback.lightImpact();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Task title',
                      prefixIcon: Icon(Icons.task_alt_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: ['Low', 'Medium', 'High'].map((priority) {
                      final isSelected = selectedPriority == priority;
                      return ChoiceChip(
                        label: Text(priority),
                        selected: isSelected,
                        onSelected: (_) => setModalState(() {
                          selectedPriority = priority;
                        }),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  GradientActionButton(
                    label: 'Save task',
                    icon: Icons.check_rounded,
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;

                      final selectedDay = ref.read(selectedDateProvider);
                      final now = DateTime.now();
                      final scheduleTime = DateTime(
                        selectedDay.year,
                        selectedDay.month,
                        selectedDay.day,
                        now.hour,
                        now.minute,
                      );

                      await ref.read(taskListProvider.notifier).addTask(
                            title,
                            description: descController.text.trim().isEmpty
                                ? null
                                : descController.text.trim(),
                            scheduleTime: scheduleTime,
                            priority: selectedPriority,
                          );

                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddRoutineSheet(BuildContext context) {
    final titleController = TextEditingController();
    var selectedTimeOfDay = 'Morning';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return _SheetFrame(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SheetTitle(
                    icon: Icons.repeat_rounded,
                    title: 'Add routine',
                    subtitle: 'Create a repeatable part of your day.',
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _QuickPill(
                          label: '🌅 Sunlight 15m',
                          onTap: () {
                            titleController.text = 'Outdoor Sunlight & Stretch';
                            selectedTimeOfDay = 'Morning';
                            setModalState(() {});
                            HapticFeedback.lightImpact();
                          },
                        ),
                        const SizedBox(width: 8),
                        _QuickPill(
                          label: '📚 25m Pomodoro Study',
                          onTap: () {
                            titleController.text = '25m Focused Study Session';
                            selectedTimeOfDay = 'Study';
                            setModalState(() {});
                            HapticFeedback.lightImpact();
                          },
                        ),
                        const SizedBox(width: 8),
                        _QuickPill(
                          label: '📵 Phone outside bedroom',
                          onTap: () {
                            titleController.text = 'Charge phone outside bedroom';
                            selectedTimeOfDay = 'Night';
                            setModalState(() {});
                            HapticFeedback.lightImpact();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Routine action',
                      prefixIcon: Icon(Icons.auto_awesome_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedTimeOfDay,
                    decoration: const InputDecoration(
                      labelText: 'Time of day',
                      prefixIcon: Icon(Icons.schedule_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Morning', child: Text('Morning')),
                      DropdownMenuItem(value: 'Study', child: Text('Study session')),
                      DropdownMenuItem(value: 'Night', child: Text('Night')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => selectedTimeOfDay = value);
                    },
                  ),
                  const SizedBox(height: 22),
                  GradientActionButton(
                    label: 'Save routine',
                    icon: Icons.check_rounded,
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;

                      await ref.read(routineListProvider.notifier).addRoutine(
                            title,
                            selectedTimeOfDay,
                          );

                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    final titleController = TextEditingController();
    var isLongTerm = false;
    var selectedDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return _SheetFrame(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SheetTitle(
                    icon: Icons.track_changes_rounded,
                    title: 'Add goal',
                    subtitle: 'Give your week a clear target.',
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Goal title',
                      prefixIcon: Icon(Icons.flag_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Long-term goal'),
                    subtitle: const Text('Rewards higher XP upon completion'),
                    value: isLongTerm,
                    onChanged: (value) => setModalState(() => isLongTerm = value),
                  ),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_month_rounded),
                    label: Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setModalState(() => selectedDate = date);
                    },
                  ),
                  const SizedBox(height: 22),
                  GradientActionButton(
                    label: 'Save goal',
                    icon: Icons.check_rounded,
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;

                      await ref.read(goalListProvider.notifier).addGoal(
                            title,
                            isLongTerm,
                            selectedDate,
                          );

                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Column(
                children: [
                  const AppPageHeader(
                    title: 'Planner',
                    subtitle: 'Plan the day before distractions do.',
                    icon: Icons.event_note_rounded,
                  ),
                  const SizedBox(height: 18),
                  const _CalendarStrip(),
                  const SizedBox(height: 14),
                  LiquidGlassPanel(
                    padding: const EdgeInsets.all(4),
                    radius: 18,
                    shadows: const [],
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(text: 'Tasks'),
                        Tab(text: 'Routines'),
                        Tab(text: 'Goals'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TasksTab(onAddTask: () => _showAddTaskSheet(context)),
                  _RoutinesTab(onAddRoutine: () => _showAddRoutineSheet(context)),
                  _GoalsTab(onAddGoal: () => _showAddGoalSheet(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarStrip extends ConsumerWidget {
  const _CalendarStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final daysOfWeek = List.generate(7, (index) => monday.add(Duration(days: index)));
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return LiquidGlassPanel(
      padding: const EdgeInsets.all(10),
      radius: 22,
      child: Row(
        children: List.generate(7, (index) {
          final day = daysOfWeek[index];
          final isSelected = _isSameDay(day, selectedDate);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == 6 ? 0 : 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => ref.read(selectedDateProvider.notifier).state = day,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.primaryGradient : null,
                    color: isSelected ? null : AppTheme.surfaceRaised.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary.withValues(alpha: 0.2) : AppTheme.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        dayNames[index],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isSelected ? AppTheme.onPrimary : AppTheme.textSecondary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isSelected ? AppTheme.onPrimary : AppTheme.textPrimary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _TasksTab extends ConsumerWidget {
  final VoidCallback onAddTask;

  const _TasksTab({required this.onAddTask});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final tasksAsync = ref.watch(taskListProvider);

    return Column(
      children: [
        _TabHeader(
          title: 'Daily tasks',
          buttonLabel: 'Add task',
          icon: Icons.add_rounded,
          onTap: onAddTask,
        ),
        Expanded(
          child: tasksAsync.when(
            data: (allTasks) {
              final filteredTasks = allTasks.where((task) {
                return task.scheduleTime.year == selectedDate.year &&
                    task.scheduleTime.month == selectedDate.month &&
                    task.scheduleTime.day == selectedDate.day;
              }).toList();

              if (filteredTasks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: EmptyState(
                    icon: Icons.assignment_turned_in_outlined,
                    title: 'No tasks scheduled',
                    message: 'Add one meaningful task for the selected day.',
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 145),
                itemCount: filteredTasks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return _TaskCard(task: task);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}

class _TaskCard extends ConsumerWidget {
  final TaskModel task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHigh = task.priority == 'High';
    final color = isHigh ? AppTheme.error : AppTheme.primary;

    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: AppTheme.onPrimary),
      ),
      onDismissed: (_) => ref.read(taskListProvider.notifier).deleteTask(task.id),
      child: LiquidGlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        radius: 20,
        child: Row(
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (_) async {
                HapticFeedback.mediumImpact();
                final completed = await ref.read(taskListProvider.notifier).toggleTask(task.id);
                if (completed && context.mounted) {
                  HapticFeedback.heavyImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Task completed! +20 XP & +5 Coins earned!'),
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.9),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted
                              ? AppTheme.textHint
                              : AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    task.description ?? 'No description',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            StatusPill(label: task.priority, color: color),
          ],
        ),
      ),
    );
  }
}

class _RoutinesTab extends ConsumerWidget {
  final VoidCallback onAddRoutine;

  const _RoutinesTab({required this.onAddRoutine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(routineListProvider);

    return Column(
      children: [
        _TabHeader(
          title: 'Habitual routines',
          buttonLabel: 'Add routine',
          icon: Icons.add_rounded,
          onTap: onAddRoutine,
        ),
        Expanded(
          child: routinesAsync.when(
            data: (routines) {
              if (routines.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: EmptyState(
                    icon: Icons.repeat_rounded,
                    title: 'No routines yet',
                    message: 'Create morning, study, or night anchors.',
                  ),
                );
              }

              final morning = routines.where((r) => r.timeOfDay == 'Morning').toList();
              final study = routines.where((r) => r.timeOfDay == 'Study').toList();
              final night = routines.where((r) => r.timeOfDay == 'Night').toList();

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 145),
                children: [
                  if (morning.isNotEmpty)
                    _RoutineCategory(
                      title: 'Morning routine',
                      items: morning,
                      icon: Icons.wb_sunny_rounded,
                      color: AppTheme.accent,
                    ),
                  if (study.isNotEmpty)
                    _RoutineCategory(
                      title: 'Study session',
                      items: study,
                      icon: Icons.school_rounded,
                      color: AppTheme.primary,
                    ),
                  if (night.isNotEmpty)
                    _RoutineCategory(
                      title: 'Night routine',
                      items: night,
                      icon: Icons.nights_stay_rounded,
                      color: AppTheme.secondary,
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}

class _RoutineCategory extends ConsumerWidget {
  final String title;
  final List<RoutineModel> items;
  final IconData icon;
  final Color color;

  const _RoutineCategory({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LiquidGlassPanel(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                LiquidIconBadge(icon: icon, color: color, size: 40, iconSize: 19),
                const SizedBox(width: 12),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return FilterChip(
                  label: Text(item.title),
                  selected: item.isCompleted,
                  onSelected: (_) {
                    HapticFeedback.lightImpact();
                    ref.read(routineListProvider.notifier).toggleRoutine(item.id);
                    if (!item.isCompleted && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Routine anchor completed! +10 XP & +2 Coins!'),
                          backgroundColor: color.withValues(alpha: 0.9),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  selectedColor: color.withValues(alpha: 0.16),
                  checkmarkColor: color,
                  side: BorderSide(color: color.withValues(alpha: 0.24)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalsTab extends ConsumerWidget {
  final VoidCallback onAddGoal;

  const _GoalsTab({required this.onAddGoal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalListProvider);

    return Column(
      children: [
        _TabHeader(
          title: 'Target goals',
          buttonLabel: 'Add goal',
          icon: Icons.add_rounded,
          onTap: onAddGoal,
        ),
        Expanded(
          child: goalsAsync.when(
            data: (goals) {
              if (goals.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: EmptyState(
                    icon: Icons.track_changes_rounded,
                    title: 'No active goals',
                    message: 'Set one measurable goal and give it a date.',
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 145),
                itemCount: goals.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _GoalCard(goal: goals[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends ConsumerWidget {
  final GoalModel goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDate =
        '${goal.targetDate.day}/${goal.targetDate.month}/${goal.targetDate.year}';
    final color = goal.isLongTerm ? AppTheme.secondary : AppTheme.primary;

    return LiquidGlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 20,
      child: Row(
        children: [
          Checkbox(
            value: goal.isCompleted,
            onChanged: (_) {
              HapticFeedback.mediumImpact();
              ref.read(goalListProvider.notifier).toggleGoal(goal.id);
              if (!goal.isCompleted && context.mounted) {
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Goal achieved! +${goal.isLongTerm ? 100 : 30} XP & +${goal.isLongTerm ? 50 : 10} Coins!'),
                    backgroundColor: color.withValues(alpha: 0.9),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                        color: goal.isCompleted ? AppTheme.textHint : AppTheme.textPrimary,
                      ),
                ),
                const SizedBox(height: 3),
                Text('Target date: $formattedDate',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 10),
          StatusPill(
            label: goal.isLongTerm ? 'Long term' : 'Short term',
            color: color,
          ),
        ],
      ),
    );
  }
}

class _TabHeader extends StatelessWidget {
  final String title;
  final String buttonLabel;
  final IconData icon;
  final VoidCallback onTap;

  const _TabHeader({
    required this.title,
    required this.buttonLabel,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
      child: SectionTitle(
        title: title,
        action: TextButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(buttonLabel),
        ),
      ),
    );
  }
}

class _SheetFrame extends StatelessWidget {
  final Widget child;

  const _SheetFrame({required this.child});

  @override
  Widget build(BuildContext context) {
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
        child: child,
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SheetTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LiquidIconBadge(icon: icon, color: AppTheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 3),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.primaryLight,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
