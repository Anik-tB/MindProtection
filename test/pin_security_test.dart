import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mind_protection/features/security/presentation/viewmodels/pin_security_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PIN Security Logic Tests', () {
    late PinSecurityNotifier notifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      notifier = PinSecurityNotifier();
      // Wait briefly for asynchronous SharedPreferences loading
      await Future.delayed(const Duration(milliseconds: 10));
    });

    test('Initial state is unconfigured and unlocked', () {
      expect(notifier.state.pinHash, isEmpty);
      expect(notifier.state.isStartupLockEnabled, isFalse);
      expect(notifier.state.isSettingGuardEnabled, isFalse);
      expect(notifier.state.isFocusExitGuardEnabled, isFalse);
      expect(notifier.state.incorrectAttempts, equals(0));
      expect(notifier.state.isLockedOut, isFalse);
    });

    test('Setting PIN successfully updates state and hashes the PIN', () async {
      final success = await notifier.setPin('1234');
      expect(success, isTrue);
      expect(notifier.state.pinHash, isNotEmpty);
      expect(notifier.state.pinHash, isNot(equals('1234'))); // should be hashed
    });

    test('Verifying correct PIN yields true, incorrect yields false', () async {
      await notifier.setPin('4321');
      
      final correctResult = await notifier.verifyPin('4321');
      expect(correctResult, isTrue);
      expect(notifier.state.incorrectAttempts, equals(0));

      final incorrectResult = await notifier.verifyPin('1111');
      expect(incorrectResult, isFalse);
      expect(notifier.state.incorrectAttempts, equals(1));
    });

    test('Five incorrect attempts triggers lockout of 30 seconds', () async {
      await notifier.setPin('9999');

      for (int i = 0; i < 4; i++) {
        final verified = await notifier.verifyPin('1111');
        expect(verified, isFalse);
        expect(notifier.state.isLockedOut, isFalse);
      }

      // 5th attempt should lock out
      final lastVerified = await notifier.verifyPin('1111');
      expect(lastVerified, isFalse);
      expect(notifier.state.isLockedOut, isTrue);
      expect(notifier.state.lockoutSecondsRemaining, greaterThan(0));

      // Correct PIN should fail while locked out
      final testCorrectDuringLock = await notifier.verifyPin('9999');
      expect(testCorrectDuringLock, isFalse);
    });

    test('Toggling settings correctly updates preferences state', () async {
      await notifier.toggleStartupLock(true);
      expect(notifier.state.isStartupLockEnabled, isTrue);

      await notifier.toggleSettingGuard(true);
      expect(notifier.state.isSettingGuardEnabled, isTrue);

      await notifier.toggleFocusExitGuard(true);
      expect(notifier.state.isFocusExitGuardEnabled, isTrue);
    });

    test('Clearing PIN resets all settings to default', () async {
      await notifier.setPin('5555');
      await notifier.toggleStartupLock(true);
      await notifier.toggleSettingGuard(true);

      await notifier.clearPin();

      expect(notifier.state.pinHash, isEmpty);
      expect(notifier.state.isStartupLockEnabled, isFalse);
      expect(notifier.state.isSettingGuardEnabled, isFalse);
    });
  });
}
