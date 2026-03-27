import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../shared/app_button.dart';
import '../shared/app_text_field.dart';

class RegisterPasswordScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> userData;

  const RegisterPasswordScreen({super.key, required this.userData});

  @override
  ConsumerState<RegisterPasswordScreen> createState() =>
      _RegisterPasswordScreenState();
}

class _RegisterPasswordScreenState
    extends ConsumerState<RegisterPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onFinish() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authNotifierProvider.notifier);
    await authNotifier.signUpWithEmail(
      widget.userData['email'] as String,
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    final result = ref.read(authNotifierProvider);
    if (!result.hasError) {
      // Верифицируем возраст, что также создает документ пользователя в Firestore
      final verifyAgeNotifier = ref.read(ageVerificationNotifierProvider.notifier);
      await verifyAgeNotifier.verifyAge(age: widget.userData['age'] as int);

      // Сохраняем профиль: имя, активности, интересы, родительский email
      final profileNotifier = ref.read(
        currentUserProfileNotifierProvider.notifier,
      );
      await profileNotifier.updateProfile(
        displayName: widget.userData['name'] as String?,
        interests: (widget.userData['interests'] as List?)?.cast<String>(),
        parentEmail: widget.userData['parentEmail'] as String?,
      );

      if (!mounted) return;
      // После успешной регистрации переходим на запрос геолокации
      context.go(AppRoutes.locationPermission);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen(authNotifierProvider, (previous, next) {
      if (next.hasError) {
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
                            onTap: () => context.pop(),
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

                        // Progress Bar (3 steps, 2 active)
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: AppColors.border,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Header
                        Text(
                          'Установите пароль',
                          style: AppTypography.headingLarge.copyWith(
                            fontSize: 32,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Последний шаг, чтобы защитить ваш аккаунт',
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Password Field
                        AppTextField(
                          label: 'Пароль',
                          controller: _passwordController,
                          hint: '••••••••',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите пароль';
                            }
                            if (value.length < 6) {
                              return 'Пароль слишком короткий';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Confirm Password Field
                        AppTextField(
                          label: 'Повторите пароль',
                          controller: _confirmPasswordController,
                          hint: '••••••••',
                          obscureText: true,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Пароли не совпадают';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Finish Button
                        PrimaryButton(
                          label: 'Создать аккаунт',
                          onPressed: _onFinish,
                          isLoading: authState is AsyncLoading,
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
