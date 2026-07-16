import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/db/isar_service.dart';
import 'core/network/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/views/auth_gate.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Isar Local Database
  await IsarService.init();

  // Initialize Supabase Cloud Backend
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  
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
      home: const AuthGate(),
    );
  }
}
