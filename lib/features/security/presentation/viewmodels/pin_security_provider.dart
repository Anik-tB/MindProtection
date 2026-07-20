import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinSecurityState {
  final String pinHash;
  final bool isStartupLockEnabled;
  final bool isSettingGuardEnabled;
  final bool isFocusExitGuardEnabled;
  final int incorrectAttempts;
  final DateTime? lockoutUntil;

  const PinSecurityState({
    required this.pinHash,
    required this.isStartupLockEnabled,
    required this.isSettingGuardEnabled,
    required this.isFocusExitGuardEnabled,
    this.incorrectAttempts = 0,
    this.lockoutUntil,
  });

  bool get isLockedOut =>
      lockoutUntil != null && lockoutUntil!.isAfter(DateTime.now());

  int get lockoutSecondsRemaining {
    if (!isLockedOut) return 0;
    final diff = lockoutUntil!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  PinSecurityState copyWith({
    String? pinHash,
    bool? isStartupLockEnabled,
    bool? isSettingGuardEnabled,
    bool? isFocusExitGuardEnabled,
    int? incorrectAttempts,
    DateTime? lockoutUntil,
  }) {
    return PinSecurityState(
      pinHash: pinHash ?? this.pinHash,
      isStartupLockEnabled: isStartupLockEnabled ?? this.isStartupLockEnabled,
      isSettingGuardEnabled: isSettingGuardEnabled ?? this.isSettingGuardEnabled,
      isFocusExitGuardEnabled: isFocusExitGuardEnabled ?? this.isFocusExitGuardEnabled,
      incorrectAttempts: incorrectAttempts ?? this.incorrectAttempts,
      lockoutUntil: lockoutUntil ?? this.lockoutUntil,
    );
  }
}

class PinSecurityNotifier extends StateNotifier<PinSecurityState> {
  static const _pinKey = 'security_pin_hash';
  static const _startupKey = 'security_startup_lock';
  static const _settingKey = 'security_setting_guard';
  static const _focusExitKey = 'security_focus_exit_guard';

  PinSecurityNotifier()
      : super(const PinSecurityState(
          pinHash: '',
          isStartupLockEnabled: false,
          isSettingGuardEnabled: false,
          isFocusExitGuardEnabled: false,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final hash = prefs.getString(_pinKey) ?? '';
    final startup = prefs.getBool(_startupKey) ?? false;
    final setting = prefs.getBool(_settingKey) ?? false;
    final focusExit = prefs.getBool(_focusExitKey) ?? false;

    state = PinSecurityState(
      pinHash: hash,
      isStartupLockEnabled: startup,
      isSettingGuardEnabled: setting,
      isFocusExitGuardEnabled: focusExit,
    );
  }

  String _hashPin(String pin) {
    if (pin.isEmpty) return '';
    int hash = 5381;
    for (int i = 0; i < pin.length; i++) {
      hash = ((hash << 5) + hash) + pin.codeUnitAt(i);
    }
    return hash.toRadixString(16);
  }

  Future<bool> setPin(String newPin) async {
    if (newPin.length != 4) return false;
    final hash = _hashPin(newPin);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, hash);
    state = state.copyWith(pinHash: hash);
    return true;
  }

  Future<void> clearPin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinKey);
    await prefs.remove(_startupKey);
    await prefs.remove(_settingKey);
    await prefs.remove(_focusExitKey);
    state = const PinSecurityState(
      pinHash: '',
      isStartupLockEnabled: false,
      isSettingGuardEnabled: false,
      isFocusExitGuardEnabled: false,
    );
  }

  Future<bool> verifyPin(String pin) async {
    if (state.isLockedOut) return false;

    final inputHash = _hashPin(pin);
    if (state.pinHash == inputHash) {
      state = state.copyWith(incorrectAttempts: 0, lockoutUntil: null);
      return true;
    } else {
      final newAttempts = state.incorrectAttempts + 1;
      DateTime? lockout;
      if (newAttempts >= 5) {
        lockout = DateTime.now().add(const Duration(seconds: 30));
      }
      state = state.copyWith(incorrectAttempts: newAttempts, lockoutUntil: lockout);
      return false;
    }
  }

  Future<void> toggleStartupLock(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_startupKey, enabled);
    state = state.copyWith(isStartupLockEnabled: enabled);
  }

  Future<void> toggleSettingGuard(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_settingKey, enabled);
    state = state.copyWith(isSettingGuardEnabled: enabled);
  }

  Future<void> toggleFocusExitGuard(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_focusExitKey, enabled);
    state = state.copyWith(isFocusExitGuardEnabled: enabled);
  }
}

final pinSecurityProvider =
    StateNotifierProvider<PinSecurityNotifier, PinSecurityState>((ref) {
  return PinSecurityNotifier();
});
