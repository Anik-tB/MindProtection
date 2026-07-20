import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_protection/core/network/supabase_auth_service.dart';
import 'package:mind_protection/core/theme/app_theme.dart';
import 'package:mind_protection/core/ui/liquid_glass.dart';
import 'package:mind_protection/features/auth/presentation/views/auth_shared_widgets.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _orb1Anim;
  late final Animation<double> _orb2Anim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _scaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _orb1Anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _orb2Anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }
    if (!_agreedToTerms) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms to continue.'),
          backgroundColor: AppTheme.warning,
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            username: _usernameController.text.trim(),
          );
      HapticFeedback.heavyImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created! Please verify your email.'),
            backgroundColor: AppTheme.primary,
            duration: const Duration(seconds: 5),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      HapticFeedback.vibrate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LiquidBackground(
        child: Stack(
          children: [
            // ── Decorative ambient orbs ──
            AnimatedBuilder(
              animation: _animController,
              builder: (context, _) => Stack(
                children: [
                  Positioned(
                    top: -size.height * 0.05,
                    left: -size.width * 0.25,
                    child: Opacity(
                      opacity: _orb1Anim.value * 0.50,
                      child: Container(
                        width: size.width * 0.80,
                        height: size.width * 0.80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.secondary.withValues(alpha: 0.22),
                              AppTheme.secondary.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: size.height * 0.08,
                    right: -size.width * 0.28,
                    child: Opacity(
                      opacity: _orb2Anim.value * 0.38,
                      child: Container(
                        width: size.width * 0.72,
                        height: size.width * 0.72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.primary.withValues(alpha: 0.20),
                              AppTheme.primary.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Main content ──
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: ScaleTransition(
                        scale: _scaleAnim,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 430),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ── Enlist Header ──
                                const _EnlistHeader(),
                                const SizedBox(height: 28),

                                // ── Form card ──
                                AuthCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const AuthSectionLabel(
                                        label: 'CREATE YOUR GUARDIAN ACCOUNT',
                                        icon: Icons.shield_rounded,
                                      ),
                                      const SizedBox(height: 20),

                                      AuthPremiumField(
                                        controller: _usernameController,
                                        label: 'Guardian Codename',
                                        hint: 'e.g. Cyber Sentinel',
                                        icon: Icons.person_outline_rounded,
                                        validator: (val) {
                                          if (val == null || val.trim().isEmpty) {
                                            return 'Enter a display name';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 14),

                                      AuthPremiumField(
                                        controller: _emailController,
                                        label: 'Email Address',
                                        hint: 'name@example.com',
                                        icon: Icons.alternate_email_rounded,
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (val) {
                                          if (val == null || val.isEmpty) return 'Enter your email';
                                          if (!val.contains('@')) return 'Enter a valid email';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 14),

                                      AuthPremiumField(
                                        controller: _passwordController,
                                        label: 'Password',
                                        hint: '••••••••',
                                        icon: Icons.lock_outline_rounded,
                                        obscureText: _obscurePassword,
                                        onToggleObscure: () => setState(
                                          () => _obscurePassword = !_obscurePassword,
                                        ),
                                        validator: (val) {
                                          if (val == null || val.isEmpty) return 'Enter a password';
                                          if (val.length < 6) return 'At least 6 characters';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 14),

                                      AuthPremiumField(
                                        controller: _confirmPasswordController,
                                        label: 'Confirm Password',
                                        hint: '••••••••',
                                        icon: Icons.lock_reset_rounded,
                                        obscureText: _obscureConfirm,
                                        onToggleObscure: () => setState(
                                          () => _obscureConfirm = !_obscureConfirm,
                                        ),
                                        validator: (val) {
                                          if (val == null || val.isEmpty) return 'Confirm your password';
                                          if (val != _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 18),

                                      // Terms toggle
                                      _TermsRow(
                                        agreed: _agreedToTerms,
                                        onChanged: (v) => setState(() => _agreedToTerms = v),
                                      ),
                                      const SizedBox(height: 22),

                                      GradientActionButton(
                                        label: _isLoading
                                            ? 'Enlisting...'
                                            : 'Enlist as Guardian',
                                        icon: _isLoading ? null : Icons.verified_user_rounded,
                                        onPressed: _isLoading ? null : _handleRegister,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // ── Sign-in link ──
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Already a Guardian? ',
                                      style: GoogleFonts.inter(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.of(context).pop();
                                      },
                                      child: ShaderMask(
                                        shaderCallback: (bounds) =>
                                            AppTheme.primaryGradient.createShader(bounds),
                                        child: Text(
                                          'Sign in →',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Protected by end-to-end encryption',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: AppTheme.textHint,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Back button (must be last = topmost layer) ──
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, left: 16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: _GlassBackButton(onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Register-specific widgets
// ─────────────────────────────────────────────

class _EnlistHeader extends StatelessWidget {
  const _EnlistHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon hero badge
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.secondary.withValues(alpha: 0.28),
                    AppTheme.secondary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2A1810), Color(0xFF1D120F)],
                ),
                border: Border.all(
                  color: AppTheme.secondary.withValues(alpha: 0.55),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.secondary.withValues(alpha: 0.28),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: AppTheme.primary,
                size: 32,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Title
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFF5C842), Color(0xFFF39C12), Color(0xFFE67E22)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'Join the Guardians',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              height: 1.05,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Secure your mind. Protect your data.\nBegin your guardian journey today.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
            fontSize: 13.5,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 18),

        // Feature badges
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            AuthBadge(icon: Icons.verified_user_rounded, label: 'Encrypted'),
            AuthBadge(icon: Icons.workspace_premium_rounded, label: 'Gamified'),
            AuthBadge(icon: Icons.cloud_done_rounded, label: 'Cloud Sync'),
          ],
        ),
      ],
    );
  }
}

class _TermsRow extends StatelessWidget {
  final bool agreed;
  final ValueChanged<bool> onChanged;

  const _TermsRow({required this.agreed, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!agreed),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              gradient: agreed ? AppTheme.primaryGradient : null,
              color: agreed ? null : Colors.transparent,
              border: Border.all(
                color: agreed ? AppTheme.primary : AppTheme.borderAccent,
                width: 1.5,
              ),
            ),
            child: agreed
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.black)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 12.5,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: GoogleFonts.inter(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: GoogleFonts.inter(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GlassBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xCC261915), Color(0xBB160E0B)],
          ),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.40),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: AppTheme.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}
