import 'package:flutter/material.dart';

class FocusTimerView extends StatelessWidget {
  const FocusTimerView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Focus Arena', style: theme.textTheme.displayMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Unleash your potential, eliminate distractions',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // Visual Timer Circle (Glassmorphism / Glow)
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow/ring
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.02,
                        ),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          width: 2,
                        ),
                      ),
                    ),
                    // Main progress indicator ring
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: 0.75, // Placeholder for 75% remaining
                        strokeWidth: 10,
                        backgroundColor: Colors.white10,
                        color: theme.colorScheme.primary,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    // Inner content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '18:45',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'POMODORO',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Session Mode Selector Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildModeButton(context, label: 'Pomodoro', isActive: true),
                  const SizedBox(width: 10),
                  _buildModeButton(
                    context,
                    label: 'Short Break',
                    isActive: false,
                  ),
                  const SizedBox(width: 10),
                  _buildModeButton(
                    context,
                    label: 'Long Break',
                    isActive: false,
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset Button
                  IconButton(
                    onPressed: () {},
                    iconSize: 32,
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.5,
                    ),
                    icon: const Icon(Icons.replay),
                  ),
                  const SizedBox(width: 25),
                  // Start/Pause Button (Primary Action)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.4,
                          ),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(width: 25),
                  // Deep Focus Toggle Button
                  IconButton(
                    onPressed: () {},
                    iconSize: 28,
                    color: theme.colorScheme.error.withValues(alpha: 0.8),
                    icon: const Icon(Icons.security_sharp),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Analytics Summary / History
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                        context,
                        label: 'Sessions Completed',
                        value: '3/4',
                      ),
                      Container(width: 1, height: 40, color: Colors.white12),
                      _buildStatColumn(
                        context,
                        label: 'Total Focus',
                        value: '75 min',
                      ),
                      Container(width: 1, height: 40, color: Colors.white12),
                      _buildStatColumn(
                        context,
                        label: 'Subject',
                        value: 'Chemistry',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required String label,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isActive ? theme.colorScheme.primary : Colors.white12,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isActive
              ? theme.colorScheme.primary
              : theme.textTheme.bodyMedium?.color,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
      ],
    );
  }
}
