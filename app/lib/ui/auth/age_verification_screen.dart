import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/user_provider.dart';
import '../../core/router/app_router.dart';
import '../shared/app_button.dart';

class AgeVerificationScreen extends ConsumerStatefulWidget {
  const AgeVerificationScreen({super.key});

  @override
  ConsumerState<AgeVerificationScreen> createState() => _AgeVerificationScreenState();
}

class _AgeVerificationScreenState extends ConsumerState<AgeVerificationScreen> {
  DateTime? _birthDate;
  bool _confirmAge = false;

  int? get _calculatedAge {
    final birthDate = _birthDate;
    if (birthDate == null) return null;
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  bool get _isValidAge {
    final age = _calculatedAge;
    return age != null && age >= AppConstants.minAge;
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initialDate = _birthDate ?? DateTime(now.year - 18, now.month, now.day);
    final firstDate = DateTime(now.year - 100, 1, 1);
    final lastDate = now;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Выберите дату рождения',
      cancelText: 'Отмена',
      confirmText: 'Готово',
    );

    if (selectedDate != null) {
      setState(() {
        _birthDate = selectedDate;
      });
    }
  }

  Future<void> _submit() async {
    final age = _calculatedAge;
    if (age == null) return;

    final notifier = ref.read(ageVerificationNotifierProvider.notifier);
    await notifier.verifyAge(age: age);

    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final verificationState = ref.watch(ageVerificationNotifierProvider);
    final isLoading = verificationState.isLoading;
    final age = _calculatedAge;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Верификация возраста'),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPaddingHorizontal,
            vertical: AppSpacing.screenPaddingVertical,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Подтвердите ваш возраст',
                style: AppTypography.headingMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Мы используем возраст для доступа к событиям и сообществам. '
                'Минимальный возраст — ${AppConstants.minAge}+.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildDatePickerCard(age),
              const SizedBox(height: AppSpacing.lg),
              _buildAgeStatus(age),
              const Spacer(),
              _buildAgreement(),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: isLoading ? 'Проверяем...' : 'Продолжить',
                onPressed: _isValidAge && _confirmAge && !isLoading ? _submit : () {},
                isEnabled: _isValidAge && _confirmAge && !isLoading,
                isLoading: isLoading,
              ),
              if (verificationState.hasError) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  verificationState.error.toString(),
                  style: AppTypography.error,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerCard(int? age) {
    final dateText = _birthDate == null
      ? 'Выбрать дату рождения'
      : '${_birthDate!.day.toString().padLeft(2, '0')}.${_birthDate!.month.toString().padLeft(2, '0')}.${_birthDate!.year}';

    return InkWell(
      onTap: _pickBirthDate,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.divider,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.border.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.cake_outlined, color: AppColors.primary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Дата рождения',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    dateText,
                    style: AppTypography.subheadingMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (age != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _isValidAge ? AppColors.success : AppColors.error,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCircle),
                ),
                child: Text(
                  '$age+ ',
                  style: AppTypography.labelSmall.copyWith(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeStatus(int? age) {
    if (age == null) {
      return Text(
        'Выберите дату рождения, чтобы продолжить.',
        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
      );
    }

    if (_isValidAge) {
      return Text(
        'Возраст подтвержден: $age лет.',
        style: AppTypography.bodyMedium.copyWith(color: AppColors.success),
      );
    }

    return Text(
      'Извините, сервис доступен только с ${AppConstants.minAge} лет.',
      style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
    );
  }

  Widget _buildAgreement() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _confirmAge,
          onChanged: (value) => setState(() => _confirmAge = value ?? false),
          activeColor: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Я подтверждаю, что мне ${AppConstants.minAge}+ лет и согласен '
            'с обработкой данных профиля.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
