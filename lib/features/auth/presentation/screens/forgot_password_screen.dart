import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:savvy/core/design/tokens/app_colors.dart';
import 'package:savvy/core/design/tokens/app_spacing.dart';
import 'package:savvy/core/design/tokens/app_typography.dart';
import 'package:savvy/core/design/tokens/app_icons.dart';
import 'package:savvy/features/auth/presentation/providers/auth_provider.dart';
import 'package:savvy/shared/widgets/savvy_snackbar.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).resetPassword(
          email: _emailController.text,
        );
    if (mounted && !ref.read(authProvider).hasError) {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      if (next.hasError) {
        SavvySnackbar.error(
          context,
          ref.read(authProvider.notifier).mapFirebaseError(next.error!),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Şifre Sıfırla'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.cardLg,
          child: _sent ? _buildSuccess() : _buildForm(authState),
        ),
      ),
    );
  }

  Widget _buildForm(AsyncValue<void> authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(
            'E-posta adresini gir, sıfırlama bağlantısı gönderelim.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.of(context).textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: const InputDecoration(
              hintText: 'E-posta adresiniz',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'E-posta giriniz';
              if (!v.contains('@')) return 'Geçerli bir e-posta giriniz';
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: authState.isLoading ? null : _submit,
            child: authState.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.of(context).textInverse,
                    ),
                  )
                : const Text('Sıfırlama Bağlantısı Gönder'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          AppIcons.check,
          size: 64,
          color: AppColors.of(context).success,
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'E-posta gönderildi!',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.of(context).textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Gelen kutunu kontrol et ve şifreni sıfırla.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.of(context).textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl2),
        ElevatedButton(
          onPressed: () => context.pop(),
          child: const Text('Giriş Sayfasına Dön'),
        ),
      ],
    );
  }
}
