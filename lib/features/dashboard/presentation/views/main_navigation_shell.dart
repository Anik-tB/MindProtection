import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../../../focus/presentation/views/focus_timer_view.dart';
import '../../../habits/presentation/views/habit_tracker_view.dart';
import '../../../planner/presentation/views/planner_view.dart';
import '../../../recovery/presentation/views/recovery_view.dart';
import '../../../wellbeing/presentation/views/wellbeing_view.dart';
import 'dashboard_view.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationShell extends ConsumerWidget {
  const MainNavigationShell({super.key});

  static const List<Widget> _screens = [
    DashboardView(),
    FocusTimerView(),
    PlannerView(),
    HabitTrackerView(),
    WellbeingView(),
    RecoveryView(),
  ];

  static const _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Home'),
    _NavItem(icon: Icons.timer_outlined, activeIcon: Icons.timer_rounded, label: 'Focus'),
    _NavItem(icon: Icons.event_note_outlined, activeIcon: Icons.event_note_rounded, label: 'Plan'),
    _NavItem(icon: Icons.spa_outlined, activeIcon: Icons.spa_rounded, label: 'Habits'),
    _NavItem(icon: Icons.favorite_border_rounded, activeIcon: Icons.favorite_rounded, label: 'Health'),
    _NavItem(icon: Icons.shield_outlined, activeIcon: Icons.shield_rounded, label: 'Guard'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: LiquidBackground(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutQuart,
          switchOutCurve: Curves.easeInQuart,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(selectedIndex),
            child: _screens[selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: _GlassNavigationDock(
        selectedIndex: selectedIndex,
        items: _navItems,
        onTap: (i) => ref.read(navigationIndexProvider.notifier).state = i,
      ),
    );
  }
}

class _GlassNavigationDock extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _GlassNavigationDock({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.surfaceRaised.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.glassStroke, width: 1.2),
                boxShadow: AppTheme.navShadow,
              ),
              child: Row(
                children: List.generate(items.length, (index) {
                  return _NavButton(
                    item: items[index],
                    isActive: selectedIndex == index,
                    onTap: () => onTap(index),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 160),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive ? AppTheme.primary : AppTheme.textHint;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          _controller.forward();
        },
        onTapUp: (_) {
          HapticFeedback.mediumImpact();
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutQuart,
                width: 42,
                height: 34,
                decoration: BoxDecoration(
                  gradient: widget.isActive ? AppTheme.primaryGradient : null,
                  color: widget.isActive ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: widget.isActive ? AppTheme.primaryGlow : null,
                ),
                child: Icon(
                  widget.isActive ? widget.item.activeIcon : widget.item.icon,
                  size: 21,
                  color: widget.isActive ? AppTheme.onPrimary : color,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: widget.isActive ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0,
                ),
                child: Text(
                  widget.item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
