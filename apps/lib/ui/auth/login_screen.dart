import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/safe_navigation.dart';
import '../../providers/auth_provider.dart';
import '../shared/app_button.dart';
import '../shared/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authNotifierProvider.notifier);
    await notifier.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите корректный email для сброса пароля'),
        ),
      );
      return;
    }

    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Инструкции по сбросу пароля отправлены на email'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      if (previous?.isLoading == true && next.hasValue) {
        // Успешная авторизация
        context.go(AppRoutes.home);
      } else if (next.hasError) {
        // Ошибка авторизации
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Button
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: InkWell(
                            onTap: () => safeGoBack(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Назад',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Header
                        Text(
                          'С возвращением',
                          style: AppTypography.headingLarge.copyWith(
                            fontSize: 32,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Войдите, чтобы продолжить в HobbyHub',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Email Field
                        AppTextField(
                          label: 'Email',
                          controller: _emailController,
                          hint: 'your@email.com',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите email';
                            }
                            if (!value.contains('@')) {
                              return 'Некорректный формат email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Password Field
                        AppTextField(
                          label: 'Пароль',
                          controller: _passwordController,
                          hint: 'Введите ваш пароль',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Пожалуйста, введите пароль';
                            }
                            if (value.length < 6) {
                              return 'Пароль слишком короткий';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _forgotPassword,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Забыли пароль?',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Or continue with divider
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1.5,
                                color: AppColors.divider,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'или через',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textTertiary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1.5,
                                color: AppColors.divider,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Social Buttons
                        SocialAuthButton(
                          label: 'Продолжить через Google',
                          isGoogle: true,
                          onPressed: () => ref
                              .read(authNotifierProvider.notifier)
                              .signInWithGoogle(),
                        ),
                        const SizedBox(height: 16),
                        SocialAuthButton(
                          label: 'Продолжить через Facebook',
                          isFacebook: true,
                          onPressed: () => ref
                              .read(authNotifierProvider.notifier)
                              .signInWithFacebook(),
                        ),

                        const SizedBox(height: 32),
                        // Submit Button
                        PrimaryButton(
                          label: 'Войти',
                          onPressed: _login,
                          isLoading: authState is AsyncLoading,
                        ),

                        const SizedBox(height: 24),

                        // Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Нет аккаунта? ",
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            InkWell(
                              onTap: () => context.push(AppRoutes.register),
                              child: Text(
                                'Создать',
                                style: AppTypography.subheadingMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
