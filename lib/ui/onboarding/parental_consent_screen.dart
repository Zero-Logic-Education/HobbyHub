import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/router/app_router.dart';
import '../../providers/user_provider.dart';
import '../shared/app_button.dart';
import '../shared/app_text_field.dart';

class ParentalConsentScreen extends ConsumerStatefulWidget {
  const ParentalConsentScreen({super.key});

  @override
  ConsumerState<ParentalConsentScreen> createState() =>
      _ParentalConsentScreenState();
}

class _ParentalConsentScreenState extends ConsumerState<ParentalConsentScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final parentEmail = _emailController.text.trim();
    final notifier = ref.read(currentUserProfileNotifierProvider.notifier);

    await notifier.updateProfile(parentEmail: parentEmail);

    if (mounted) {
      context.push(AppRoutes.interestsSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Родительское согласие'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.family_restroom_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Нам нужно разрешение', style: AppTypography.headingLarge),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Согласно вашей возрастной группе, нам необходимо получить подтверждение от родителя или опекуна.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl * 2),
                AppTextField(
                  label: 'Email родителя',
                  controller: _emailController,
                  hint: 'parent@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Введите email';
                    if (!value.contains('@')) return 'Некорректный email';
                    return null;
                  },
                ),
                const Spacer(),
                PrimaryButton(label: 'Отправить запрос', onPressed: _submit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
