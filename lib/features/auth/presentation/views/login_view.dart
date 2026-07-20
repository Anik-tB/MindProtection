import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mind_protection/core/network/supabase_auth_service.dart';
import 'package:mind_protection/core/theme/app_theme.dart';
import 'package:mind_protection/core/ui/liquid_glass.dart';
import 'package:mind_protection/features/auth/presentation/views/auth_shared_widgets.dart';
import 'package:mind_protection/features/auth/presentation/views/register_view.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

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
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      HapticFeedback.heavyImpact();
    } catch (e) {
      HapticFeedback.vibrate();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
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
                    top: -size.height * 0.08,
                    right: -size.width * 0.22,
                    child: Opacity(
                      opacity: _orb1Anim.value * 0.55,
                      child: Container(
                        width: size.width * 0.82,
                        height: size.width * 0.82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.primary.withValues(alpha: 0.22),
                              AppTheme.primary.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: size.height * 0.05,
                    left: -size.width * 0.30,
                    child: Opacity(
                      opacity: _orb2Anim.value * 0.40,
                      child: Container(
                        width: size.width * 0.75,
                        height: size.width * 0.75,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.secondary.withValues(alpha: 0.20),
                              AppTheme.secondary.withValues(alpha: 0.0),
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
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
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
                                // ── Brand Hero ──
                                const AuthBrandHero(),
                                const SizedBox(height: 26),

                                // ── Trust badges ──
                                const AuthTrustBadgeRow(),
                                const SizedBox(height: 28),

                                // ── Form card ──
                                AuthCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const AuthSectionLabel(
                                        label: 'SIGN IN TO YOUR VAULT',
                                        icon: Icons.lock_open_rounded,
                                      ),
                                      const SizedBox(height: 20),
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
                                          if (val == null || val.isEmpty) return 'Enter your password';
                                          if (val.length < 6) return 'At least 6 characters';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      GradientActionButton(
                                        label: _isLoading
                                            ? 'Signing in...'
                                            : 'Sign in to MindProtection',
                                        icon: _isLoading ? null : Icons.shield_rounded,
                                        onPressed: _isLoading ? null : _handleLogin,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // ── Register link ──
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'New Guardian? ',
                                      style: GoogleFonts.inter(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const RegisterView(),
                                          ),
                                        );
                                      },
                                      child: ShaderMask(
                                        shaderCallback: (bounds) =>
                                            AppTheme.primaryGradient.createShader(bounds),
                                        child: Text(
                                          'Create your account →',
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
          ],
        ),
      ),
    );
  }
}
