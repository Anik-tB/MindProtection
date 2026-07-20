import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mind_protection/main.dart';
import 'package:mind_protection/core/network/supabase_auth_service.dart';

// Fake Supabase Client to avoid static instance calls in tests
class FakeSupabaseClient extends Fake implements SupabaseClient {}

// Mock Auth Service that returns signed-out state without calling Supabase.instance
class MockAuthService extends SupabaseAuthService {
  MockAuthService() : super(client: FakeSupabaseClient());

  @override
  User? get currentUser => null;

  @override
  Stream<AuthState> get authStateChanges =>
      Stream.value(const AuthState(AuthChangeEvent.signedOut, null));

  @override
  bool get hasSession => false;
}

void main() {
  // Disable Google Fonts runtime network fetching during tests
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('MindProtection login gate smoke test', (
    WidgetTester tester,
  ) async {
    // Build our app wrapped in ProviderScope with overridden auth providers.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWithValue(MockAuthService())],
        child: const MindProtectionApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    // Verify that the login screen elements are present initially.
    expect(find.text('MindProtection'), findsOneWidget);
    expect(find.text('Sign in'), findsAtLeast(1));
  });
}
