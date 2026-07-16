import 'package:flutter/material.dart';

class RecoveryView extends StatelessWidget {
  const RecoveryView({super.key});

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
              Text('Recovery Hub', style: theme.textTheme.displayMedium),
              const SizedBox(height: 4),
              Text(
                'Break free from digital addictions',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 25),

              // Sobriety Card (Porn / Adult Block / DNS Filter Status)
              _buildSobrietyCard(context),
              const SizedBox(height: 20),

              // Emergency Shield Block
              _buildEmergencyCard(context),
              const SizedBox(height: 25),

              // Section: Blockers & Guards
              Text('Blocking Guards', style: theme.textTheme.titleLarge),
              const SizedBox(height: 15),
              _buildGuardSwitch(
                context,
                title: 'Adult Website Blocker',
                subtitle: 'Strict local DNS filter + SafeSearch enforcement',
                icon: Icons.vpn_lock,
                color: theme.colorScheme.error,
                isActive: true,
              ),
              const SizedBox(height: 12),
              _buildGuardSwitch(
                context,
                title: 'Shorts & Reels Blocker',
                subtitle: 'Auto-hides TikTok, FB/IG Reels, and YT Shorts',
                icon: Icons.visibility_off_outlined,
                color: theme.colorScheme.secondary,
                isActive: true,
              ),
              const SizedBox(height: 12),
              _buildGuardSwitch(
                context,
                title: 'App Limiters',
                subtitle: 'Restricts social apps after 30 mins daily usage',
                icon: Icons.app_blocking_outlined,
                color: theme.colorScheme.primary,
                isActive: false,
              ),
              const SizedBox(height: 25),

              // Addiction Relapse Analytics
              Text('Relapse Prevention log', style: theme.textTheme.titleLarge),
              const SizedBox(height: 15),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.history_toggle_off,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Relapse Check',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No triggers or relapses reported this week.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(onPressed: () {}, child: const Text('Log')),
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

  Widget _buildSobrietyCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.error.withValues(alpha: 0.12),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shield,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Porn & Adult site block',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.white30,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '12 Days Sobriety',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Streak Active • Level 2',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.4),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.flash_on,
                          color: theme.colorScheme.error,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '12 Days',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.1),
              theme.colorScheme.secondary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Shield',
                      style: theme.textTheme.titleLarge?.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Intense urge? Activate absolute device lock for 15 minutes immediately.',
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  shadowColor: theme.colorScheme.error.withValues(alpha: 0.4),
                ),
                child: const Text(
                  'LOCK NOW',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuardSwitch(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: (val) {},
              activeThumbColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
