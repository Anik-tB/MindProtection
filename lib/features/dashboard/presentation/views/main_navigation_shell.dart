import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_view.dart';
import '../../../focus/presentation/views/focus_timer_view.dart';
import '../../../planner/presentation/views/planner_view.dart';
import '../../../recovery/presentation/views/recovery_view.dart';

// Tab selection state provider
final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationShell extends ConsumerWidget {
  const MainNavigationShell({super.key});

  final List<Widget> _screens = const [
    DashboardView(),
    FocusTimerView(),
    PlannerView(),
    RecoveryView(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            activeIcon: Icon(Icons.timer),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'Planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.security_outlined),
            activeIcon: Icon(Icons.security),
            label: 'Recovery',
          ),
        ],
      ),
    );
  }
}
