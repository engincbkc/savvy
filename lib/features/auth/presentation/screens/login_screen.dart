import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_radius.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/features/auth/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.mediumImpact();
    ref.read(authProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    ref.listen(authProvider, (prev, next) {
      if (next.hasError && prev?.isLoading == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.alertCircle,
                    color: Colors.white, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    ref
                        .read(authProvider.notifier)
                        .mapFirebaseError(next.error!),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
            margin: const EdgeInsets.all(AppSpacing.base),
          ),
        );
      }
      if (prev?.isLoading == true && !next.isLoading && !next.hasError) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F4FF),
              Color(0xFFFAFBFF),
              Colors.white,
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SlideTransition(
              position: _slideUp,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Column(
                        children: [
                          const Spacer(flex: 2),

                          // ─── Logo & Branding ─────────────────────
                          _buildLogo(),

                          const Spacer(flex: 2),

                          // ─── Social Buttons First (Modern Pattern) ───
                          _buildSocialButtons(authState),

                          const SizedBox(height: AppSpacing.xl),

                          // ─── Divider ─────────────────────────────
                          _buildDivider(),

                          const SizedBox(height: AppSpacing.xl),

                          // ─── Email/Password Form ─────────────────
                          _buildForm(authState),

                          const SizedBox(height: AppSpacing.xl),

                          // ─── Register Link ───────────────────────
                          _buildRegisterLink(),

                          SizedBox(
                            height: bottomInset > 0
                                ? AppSpacing.base
                                : AppSpacing.xl,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Logo ──────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Column(
      children: [
        // App icon
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A56DB), Color(0xFF3F83F8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.cardLg,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A56DB).withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(LucideIcons.wallet, color: Colors.white, size: 36),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Savvy',
          style: AppTypography.numericHero.copyWith(
            color: AppColors.brandPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Finansal geleceğini kontrol et',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ─── Social Buttons ────────────────────────────────────────────────────

  Widget _buildSocialButtons(AsyncValue<void> authState) {
    return Column(
      children: [
        // Google
        _SocialButton(
          onPressed: authState.isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  ref.read(authProvider.notifier).signInWithGoogle();
                },
          icon: SizedBox(
            width: 20,
            height: 20,
            child: CustomPaint(painter: _GoogleLogoPainter()),
          ),
          label: 'Google ile devam et',
        ),

        const SizedBox(height: AppSpacing.md),

        // Apple (iOS only)
        if (Platform.isIOS)
          _SocialButton(
            onPressed: authState.isLoading
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    ref.read(authProvider.notifier).signInWithApple();
                  },
            icon: const Icon(Icons.apple, size: 22, color: Colors.white),
            label: 'Apple ile devam et',
            isDark: true,
          ),
      ],
    );
  }

  // ─── Divider ───────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.borderDefault.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'veya e-posta ile',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.borderDefault.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Form ──────────────────────────────────────────────────────────────

  Widget _buildForm(AsyncValue<void> authState) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email
          _ModernInput(
            controller: _emailController,
            hint: 'E-posta adresiniz',
            icon: LucideIcons.mail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'E-posta giriniz';
              if (!v.contains('@')) return 'Geçerli bir e-posta giriniz';
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // Password
          _ModernInput(
            controller: _passwordController,
            hint: 'Şifreniz',
            icon: AppIcons.lock,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            suffixIcon: GestureDetector(
              onTap: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword
                    ? LucideIcons.eyeOff
                    : LucideIcons.eye,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Şifre giriniz';
              if (v.length < 6) return 'En az 6 karakter';
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.sm),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => context.push('/forgot-password'),
              child: Text(
                'Şifremi Unuttum?',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.brandPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Login button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.input,
                ),
                shadowColor: AppColors.brandPrimary.withValues(alpha: 0.3),
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Giriş Yap',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Register Link ─────────────────────────────────────────────────────

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Hesabın yok mu? ',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            context.push('/register');
          },
          child: Text(
            'Kayıt Ol',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.brandPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Modern Input Field ──────────────────────────────────────────────────────

class _ModernInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  const _ModernInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.suffixIcon,
    this.validator,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: AppTypography.bodyMedium.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary.withValues(alpha: 0.6),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(icon, size: 18, color: AppColors.textTertiary),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 16),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.borderDefault.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(
            color: AppColors.borderDefault.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(
            color: AppColors.brandPrimary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(
            color: AppColors.expense,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(
            color: AppColors.expense,
            width: 1.5,
          ),
        ),
      ),
      validator: validator,
    );
  }
}

// ─── Social Button ──────────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final bool isDark;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? const Color(0xFF1D1D1F) : Colors.white,
          side: BorderSide(
            color: isDark
                ? Colors.transparent
                : AppColors.borderDefault.withValues(alpha: 0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.input,
          ),
          elevation: isDark ? 0 : 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Google Logo Painter ────────────────────────────────────────────────────

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawArc(
        Rect.fromLTWH(0, 0, w, h), -0.5, 1.8, true, bluePaint);

    final greenPaint = Paint()..color = const Color(0xFF34A853);
    canvas.drawArc(
        Rect.fromLTWH(0, 0, w, h), 1.3, 1.2, true, greenPaint);

    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    canvas.drawArc(
        Rect.fromLTWH(0, 0, w, h), 2.5, 1.0, true, yellowPaint);

    final redPaint = Paint()..color = const Color(0xFFEA4335);
    canvas.drawArc(
        Rect.fromLTWH(0, 0, w, h), 3.5, 1.3, true, redPaint);

    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.32, whitePaint);

    canvas.drawRect(
        Rect.fromLTWH(w * 0.48, h * 0.38, w * 0.52, h * 0.24), bluePaint);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.48, h * 0.38, w * 0.34, h * 0.24), whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
