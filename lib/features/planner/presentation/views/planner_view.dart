import 'package:flutter/material.dart';

class PlannerView extends StatelessWidget {
  const PlannerView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Planner & Routines',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Organize your day for peak discipline',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 25),

              // Calendar mini-strip (visual placeholder)
              _buildCalendarStrip(context),
              const SizedBox(height: 25),

              // Section: Daily Tasks
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Tasks',
                    style: theme.textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Task'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTaskItem(
                context,
                title: 'Solve Chemistry MCQ Past Papers',
                time: '10:00 AM - 11:30 AM',
                priority: 'High',
                priorityColor: theme.colorScheme.error,
                isCompleted: true,
              ),
              const SizedBox(height: 10),
              _buildTaskItem(
                context,
                title: 'Write Flutter Clean Architecture documentation',
                time: '02:00 PM - 03:30 PM',
                priority: 'Medium',
                priorityColor: theme.colorScheme.primary,
                isCompleted: false,
              ),
              const SizedBox(height: 10),
              _buildTaskItem(
                context,
                title: 'Read Biology Chapter 4 summary',
                time: '06:00 PM - 07:00 PM',
                priority: 'Low',
                priorityColor: theme.colorScheme.secondary,
                isCompleted: false,
              ),
              const SizedBox(height: 25),

              // Section: Routines
              Text(
                'Habitual Routines',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 15),
              _buildRoutineCard(
                context,
                title: 'Morning Routine',
                time: '06:00 AM - 07:30 AM',
                items: ['Drink water', '15 mins stretching', 'Morning Prayer', 'No Phone for 1 hour'],
                icon: Icons.wb_sunny_outlined,
                iconColor: Colors.amber,
              ),
              const SizedBox(height: 15),
              _buildRoutineCard(
                context,
                title: 'Night Routine',
                time: '10:00 PM - 11:00 PM',
                items: ['Plan next day', 'Review streaks', 'Eye Care (20-20-20)', 'Read a book'],
                icon: Icons.nights_stay_outlined,
                iconColor: Colors.indigoAccent,
              ),
            ],
          ),
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
              color: isActive ? theme.colorScheme.primary : theme.colorScheme.surface,
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
                    color: isActive ? Colors.white70 : theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  d['date'] as String,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : theme.textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskItem(
    BuildContext context, {
    required String title,
    required String time,
    required String priority,
    required Color priorityColor,
    required bool isCompleted,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Checkbox(
              value: isCompleted,
              onChanged: (val) {},
              activeColor: theme.colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 14,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? theme.textTheme.bodyMedium?.color?.withOpacity(0.5) : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: theme.textTheme.bodyMedium?.color),
                      const SizedBox(width: 4),
                      Text(time, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          priority,
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
                    Text(title, style: theme.textTheme.titleLarge?.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(time, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, size: 12, color: theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(item, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12)),
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
