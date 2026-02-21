import 'package:flutter/material.dart';
import 'package:hobby_hub/core/theme/app_colors.dart';
import 'package:hobby_hub/core/theme/app_spacing.dart';
import 'package:hobby_hub/core/theme/app_typography.dart';

/// Основная кнопка с коралловым фоном
class PrimaryButton extends StatefulWidget {
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
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: AppSpacing.buttonHeightLarge,
      child: ElevatedButton(
        onPressed: widget.isEnabled && !widget.isLoading
            ? widget.onPressed
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.textHint.withValues(alpha: 0.3),
          disabledForegroundColor: AppColors.textHint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          padding:
              widget.padding ?? EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (widget.leftIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.leftIcon!,
          SizedBox(width: AppSpacing.sm),
          Text(
            widget.label,
            style: AppTypography.buttonLarge.copyWith(color: Colors.white),
          ),
        ],
      );
    }

    return Text(
      widget.label,
      style: AppTypography.buttonLarge.copyWith(color: Colors.white),
    );
  }
}

/// Вторичная кнопка с контуром
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
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: isEnabled ? AppColors.primary : AppColors.textHint,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          padding: padding ?? EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (leftIcon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          leftIcon!,
          SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.buttonLarge.copyWith(color: AppColors.primary),
          ),
        ],
      );
    }

    return Text(
      label,
      style: AppTypography.buttonLarge.copyWith(color: AppColors.primary),
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
