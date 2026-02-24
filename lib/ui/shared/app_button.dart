import 'package:flutter/material.dart';
import 'package:hobby_hub/core/theme/app_colors.dart';
import 'package:hobby_hub/core/theme/app_spacing.dart';
import 'package:hobby_hub/core/theme/app_typography.dart';

/// Основная кнопка с градиентом или заливкой
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final EdgeInsets? padding;
  final Widget? leftIcon;

  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.padding,
    this.leftIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: AppSpacing.buttonHeightLarge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled && !isLoading
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.textHint.withValues(alpha: 0.3),
          disabledForegroundColor: AppColors.textHint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0, // Тень реализована через Container для большей мягкости
          padding: padding ?? EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leftIcon != null) ...[leftIcon!, SizedBox(width: AppSpacing.sm)],
        Text(
          label,
          style: AppTypography.buttonLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Вторичная кнопка с контуром (Outline)
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isEnabled;
  final double? width;
  final EdgeInsets? padding;
  final Widget? leftIcon;

  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.width,
    this.padding,
    this.leftIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: AppSpacing.buttonHeightLarge,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(
            color: isEnabled ? AppColors.border : AppColors.textHint,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: padding ?? EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leftIcon != null) ...[
              leftIcon!,
              SizedBox(width: AppSpacing.sm),
            ],
            Text(
              label,
              style: AppTypography.buttonLarge.copyWith(
                color: isEnabled ? AppColors.textPrimary : AppColors.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Кнопка для входа через социальные сети
class SocialAuthButton extends StatelessWidget {
  final String label;
  final String iconAsset; // Или использование Image.network если нет ассетов
  final VoidCallback onPressed;
  final bool isGoogle;
  final bool isFacebook;

  const SocialAuthButton({
    required this.label,
    required this.onPressed,
    this.iconAsset = '',
    this.isGoogle = false,
    this.isFacebook = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isFacebook ? AppColors.facebookBlue : Colors.white;
    final textColor = isFacebook ? Colors.white : AppColors.textPrimary;
    final borderColor = isGoogle ? AppColors.border : Colors.transparent;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isGoogle ? 1 : 0,
          shadowColor: Colors.black.withValues(alpha: 0.05),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoogle)
              Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/512px-Google_%22G%22_Logo.svg.png',
                height: 24,
                width: 24,
              )
            else if (isFacebook)
              const Icon(Icons.facebook, color: Colors.white, size: 24)
            else if (iconAsset.isNotEmpty)
              Image.asset(iconAsset, height: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.subheadingMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Текстовая кнопка (ghost button)
class TextButtonWidget extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isEnabled;
  final double? width;
  final Color? textColor;

  const TextButtonWidget({
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.width,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: AppSpacing.buttonHeightMedium,
      child: TextButton(
        onPressed: isEnabled ? onPressed : null,
        style: TextButton.styleFrom(
          foregroundColor: textColor ?? AppColors.primary,
        ),
        child: Text(
          label,
          style: AppTypography.buttonMedium.copyWith(
            color: textColor ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}

/// Компактная кнопка действия
class SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double? width;

  const SmallButton({
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: AppSpacing.buttonHeightSmall,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        ),
        child: Text(
          label,
          style: AppTypography.buttonSmall.copyWith(color: textColor),
        ),
      ),
    );
  }
}
