import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mind_protection/core/network/supabase_auth_service.dart';
import 'package:mind_protection/features/dashboard/presentation/views/main_navigation_shell.dart';
import 'package:mind_protection/features/auth/presentation/views/login_view.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Sync check for initial render to avoid white flash
    final hasSession = ref.watch(authServiceProvider).hasSession;
    if (hasSession) {
      return const MainNavigationShell();
    }

    return authState.when(
      data: (state) {
        if (state.session != null) {
          return const MainNavigationShell();
        } else {
          return const LoginView();
        }
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Authentication Error: $err'),
        ),
      ),
    );
  }
}
