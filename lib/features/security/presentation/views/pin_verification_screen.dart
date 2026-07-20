import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/liquid_glass.dart';
import '../viewmodels/pin_security_provider.dart';

class PinVerificationScreen extends ConsumerStatefulWidget {
  final bool isModal;
  final String title;
  final VoidCallback? onVerified;

  const PinVerificationScreen({
    super.key,
    this.isModal = false,
    this.title = 'Enter Guardian PIN',
    this.onVerified,
  });

  @override
  ConsumerState<PinVerificationScreen> createState() => _PinVerificationScreenState();
}

class _PinVerificationScreenState extends ConsumerState<PinVerificationScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  String _errorMessage = '';
  Timer? _cooldownTimer;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 12.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);

    _startLockoutTimerIfNeeded();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startLockoutTimerIfNeeded() {
    _cooldownTimer?.cancel();
    final sec = ref.read(pinSecurityProvider).lockoutSecondsRemaining;
    if (sec > 0) {
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            if (ref.read(pinSecurityProvider).lockoutSecondsRemaining <= 0) {
              timer.cancel();
              _errorMessage = '';
            }
          });
        }
      });
    }
  }

  void _handleNumberPress(int number) async {
    final securityState = ref.read(pinSecurityProvider);
    if (securityState.isLockedOut || _enteredPin.length >= 4) return;

    HapticFeedback.lightImpact();
    setState(() {
      _enteredPin += number.toString();
      _errorMessage = '';
    });

    if (_enteredPin.length == 4) {
      final success = await ref.read(pinSecurityProvider.notifier).verifyPin(_enteredPin);
      if (success) {
        HapticFeedback.mediumImpact();
        if (widget.onVerified != null) {
          widget.onVerified!();
        } else if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        HapticFeedback.vibrate();
        _shakeController.forward(from: 0.0);
        setState(() {
          _enteredPin = '';
          final sec = ref.read(pinSecurityProvider).lockoutSecondsRemaining;
          if (sec > 0) {
            _errorMessage = 'Too many attempts. Locked for $sec seconds.';
            _startLockoutTimerIfNeeded();
          } else {
            _errorMessage = 'Incorrect PIN. Try again.';
          }
        });
      }
    }
  }

  void _handleDeletePress() {
    if (_enteredPin.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final securityState = ref.watch(pinSecurityProvider);
    final isLocked = securityState.isLockedOut;
    final secondsRemaining = securityState.lockoutSecondsRemaining;

    if (isLocked && _cooldownTimer == null) {
      _startLockoutTimerIfNeeded();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LiquidBackground(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cancel Button for Modals
              if (widget.isModal)
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 12),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 28),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ),
                )
              else
                const Spacer(flex: 1),

              // Shield Icon & Title
              const Icon(
                Icons.shield_outlined,
                color: AppTheme.primary,
                size: 58,
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLocked
                    ? 'Security Lock Active'
                    : 'Enter verification code to proceed.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),

              const Spacer(flex: 1),

              // Code dots (with shake animation)
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _shakeController.isAnimating
                          ? (2 * (0.5 - _shakeController.value).abs() * _shakeAnimation.value * (1 - 2 * (_enteredPin.length % 2)))
                          : 0,
                      0,
                    ),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isActive = index < _enteredPin.length;
                    return Container(
                      width: 18,
                      height: 18,
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive ? AppTheme.primary : Colors.transparent,
                        border: Border.all(
                          color: isActive ? AppTheme.primary : AppTheme.textHint,
                          width: 2.0,
                        ),
                        boxShadow: isActive ? AppTheme.primaryGlow : null,
                      ),
                    );
                  }),
                ),
              ),

              // Error or Lockout Message
              Container(
                height: 38,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  isLocked ? 'Locked out. Try again in $secondsRemaining seconds.' : _errorMessage,
                  style: GoogleFonts.inter(
                    color: AppTheme.error,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Keypad numeric panel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKey(1, isLocked),
                        _buildKey(2, isLocked),
                        _buildKey(3, isLocked),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKey(4, isLocked),
                        _buildKey(5, isLocked),
                        _buildKey(6, isLocked),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKey(7, isLocked),
                        _buildKey(8, isLocked),
                        _buildKey(9, isLocked),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Empty spacer or close button
                        const SizedBox(width: 72, height: 72),
                        _buildKey(0, isLocked),
                        _buildDeleteKey(isLocked),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(int value, bool disabled) {
    return Opacity(
      opacity: disabled ? 0.35 : 1.0,
      child: GestureDetector(
        onTap: disabled ? null : () => _handleNumberPress(value),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surfaceCard,
            border: Border.all(color: AppTheme.borderAccent.withValues(alpha: 0.12), width: 1.2),
          ),
          alignment: Alignment.center,
          child: Text(
            value.toString(),
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey(bool disabled) {
    return Opacity(
      opacity: disabled ? 0.35 : 1.0,
      child: GestureDetector(
        onTap: disabled ? null : _handleDeletePress,
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: const Icon(
            Icons.backspace_rounded,
            color: AppTheme.textSecondary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
