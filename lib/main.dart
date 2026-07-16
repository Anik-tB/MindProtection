import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/views/main_navigation_shell.dart';

void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: MindProtectionApp(),
    ),
  );
}

class MindProtectionApp extends StatelessWidget {
  const MindProtectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindProtection',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationShell(),
    );
  }
}
