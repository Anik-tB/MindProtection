import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/db/isar_service.dart';
import 'core/network/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/views/auth_gate.dart';
import 'features/security/presentation/viewmodels/pin_security_provider.dart';
import 'features/security/presentation/views/pin_verification_screen.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Isar Local Database
  await IsarService.init();

  // Initialize Supabase Cloud Backend
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
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
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const StartupGate(),
    );
  }
}

class StartupGate extends ConsumerStatefulWidget {
  const StartupGate({super.key});

  @override
  ConsumerState<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends ConsumerState<StartupGate> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(pinSecurityProvider);

    if (securityState.pinHash.isNotEmpty &&
        securityState.isStartupLockEnabled &&
        !_unlocked) {
      return PinVerificationScreen(
        isModal: false,
        title: 'Unlock MindProtection',
        onVerified: () {
          setState(() {
            _unlocked = true;
          });
        },
      );
    }

    return const AuthGate();
  }
}
