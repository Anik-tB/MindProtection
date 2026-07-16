import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_protection/main.dart';

void main() {
  // Disable Google Fonts runtime network fetching during tests
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('MindProtection smoke test', (WidgetTester tester) async {
    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MindProtectionApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the dashboard header is present.
    expect(find.text('MindProtection'), findsOneWidget);
    expect(find.text('Your digital wellbeing companion'), findsOneWidget);
  });
}
