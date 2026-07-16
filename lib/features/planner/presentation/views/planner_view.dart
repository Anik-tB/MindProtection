import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/task_notifier.dart';
import '../../data/models/task_model.dart';

class PlannerView extends ConsumerStatefulWidget {
  const PlannerView({super.key});

  @override
  ConsumerState<PlannerView> createState() => _PlannerViewState();
}

class _PlannerViewState extends ConsumerState<PlannerView> {
  // Show Bottom Sheet to Add Task
  void _showAddTaskSheet(BuildContext context) {
    final theme = Theme.of(context);
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedPriority = 'Medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add New Task',
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Task Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Priority Select
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Priority Level:', style: theme.textTheme.bodyLarge),
                      Row(
                        children: ['Low', 'Medium', 'High'].map((priority) {
                          final isSelected = selectedPriority == priority;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ChoiceChip(
                              label: Text(priority),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setModalState(() {
                                    selectedPriority = priority;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  ElevatedButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;

                      await ref
                          .read(taskListProvider.notifier)
                          .addTask(
                            title,
                            description: descController.text.trim().isEmpty
                                ? null
                                : descController.text.trim(),
                            scheduleTime: DateTime.now(),
                            priority: selectedPriority,
                          );

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'SAVE TASK',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
    final theme = Theme.of(context);
    final tasksAsync = ref.watch(taskListProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Planner & Routines', style: theme.textTheme.displayMedium),
              const SizedBox(height: 4),
              Text(
                'Organize your day for peak discipline',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 25),

              // Calendar mini-strip
              _buildCalendarStrip(context),
              const SizedBox(height: 25),

              // Section Header: Daily Tasks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Daily Tasks', style: theme.textTheme.titleLarge),
                  TextButton.icon(
                    onPressed: () => _showAddTaskSheet(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Task'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Tasks Content Area
              tasksAsync.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.assignment_turned_in_outlined,
                              size: 48,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No tasks planned for today.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Dismissible(
                        key: Key('task_${task.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) async {
                          await ref
                              .read(taskListProvider.notifier)
                              .deleteTask(task.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Task deleted')),
                            );
                          }
                        },
                        child: _buildTaskCard(context, task),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Error loading tasks: $err',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Section: Routines
              Text('Habitual Routines', style: theme.textTheme.titleLarge),
              const SizedBox(height: 15),
              _buildRoutineCard(
                context,
                title: 'Morning Routine',
                time: '06:00 AM - 07:30 AM',
                items: [
                  'Drink water',
                  '15 mins stretching',
                  'Morning Prayer',
                  'No Phone for 1 hour',
                ],
                icon: Icons.wb_sunny_outlined,
                iconColor: Colors.amber,
              ),
              const SizedBox(height: 15),
              _buildRoutineCard(
                context,
                title: 'Night Routine',
                time: '10:00 PM - 11:00 PM',
                items: [
                  'Plan next day',
                  'Review streaks',
                  'Eye Care (20-20-20)',
                  'Read a book',
                ],
                icon: Icons.nights_stay_outlined,
                iconColor: Colors.indigoAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task) {
    final theme = Theme.of(context);

    Color priorityColor;
    switch (task.priority.toLowerCase()) {
      case 'high':
        priorityColor = theme.colorScheme.error;
        break;
      case 'low':
        priorityColor = theme.colorScheme.secondary;
        break;
      default:
        priorityColor = theme.colorScheme.primary;
    }

    final formattedTime =
        '${task.scheduleTime.hour.toString().padLeft(2, '0')}:${task.scheduleTime.minute.toString().padLeft(2, '0')}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (val) async {
                await ref.read(taskListProvider.notifier).toggleTask(task.id);
              },
              activeColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 14,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isCompleted
                          ? theme.textTheme.bodyMedium?.color?.withValues(
                              alpha: 0.5,
                            )
                          : null,
                    ),
                  ),
                  if (task.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formattedTime,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          task.priority,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 10,
                            color: priorityColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarStrip(BuildContext context) {
    final theme = Theme.of(context);
    final days = [
      {'day': 'Mon', 'date': '13'},
      {'day': 'Tue', 'date': '14'},
      {'day': 'Wed', 'date': '15'},
      {'day': 'Thu', 'date': '16', 'active': true},
      {'day': 'Fri', 'date': '17'},
      {'day': 'Sat', 'date': '18'},
      {'day': 'Sun', 'date': '19'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.map((d) {
          final isActive = d['active'] == true;
          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? theme.colorScheme.primary : Colors.white10,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  d['day'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: isActive
                        ? Colors.white70
                        : theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  d['date'] as String,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? Colors.white
                        : theme.textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRoutineCard(
    BuildContext context, {
    required String title,
    required String time,
    required List<String> items,
    required IconData icon,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.arrow_forward_ios, size: 14),
                ),
              ],
            ),
            const Divider(height: 24, color: Colors.white10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 12,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        item,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
