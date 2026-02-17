import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Предопределенные стили и компоненты HobbyHub
abstract class AppStyles {
  // Тени
  static const BoxShadow shadowSmall = BoxShadow(
    color: Color(0x0D000000),
    offset: Offset(0, 2),
    blurRadius: 4,
    spreadRadius: 0,
  );

  static const BoxShadow shadowMedium = BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 4),
    blurRadius: 8,
    spreadRadius: 0,
  );

  static const BoxShadow shadowLarge = BoxShadow(
    color: Color(0x24000000),
    offset: Offset(0, 8),
    blurRadius: 16,
    spreadRadius: 0,
  );

  static List<BoxShadow> get shadowSmallList => [shadowSmall];
  static List<BoxShadow> get shadowMediumList => [shadowMedium];
  static List<BoxShadow> get shadowLargeList => [shadowLarge];

  // Декорация карточки
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
    boxShadow: shadowSmallList,
  );

  static BoxDecoration get darkCardDecoration => BoxDecoration(
    color: AppColors.surfaceDark,
    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
    boxShadow: shadowSmallList,
  );

  // Градиент
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: AppColors.primaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get secondaryGradient => const LinearGradient(
    colors: AppColors.secondaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Граница
  static Border get bottomBorder => Border(
    bottom: BorderSide(
      color: AppColors.divider,
      width: 1,
    ),
  );

  static Border get fullBorder => Border.all(
    color: AppColors.border,
    width: 1,
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    String? hintText,
    String? labelText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconPressed,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textHint,
      ),
      labelText: labelText,
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon != null
          ? IconButton(
        icon: Icon(suffixIcon),
        onPressed: onSuffixIconPressed,
      )
          : null,
      filled: true,
      fillColor: AppColors.lightPink,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
    );
  }

  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.lg,
    ),
  );

  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.lightPink,
    foregroundColor: AppColors.primary,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.lg,
    ),
  );

  static ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    elevation: 0,
    side: const BorderSide(
      color: AppColors.primary,
      width: 2,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.xl,
      vertical: AppSpacing.lg,
    ),
  );

  // Chip Styles
  static ChipThemeData get chipTheme => ChipThemeData(
    backgroundColor: AppColors.lightPink,
    selectedColor: AppColors.primary,
    deleteIconColor: AppColors.textSecondary,
    disabledColor: AppColors.surfaceSecondary,
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      side: const BorderSide(color: AppColors.border),
    ),
  );

  // Divider
  static Divider get divider => const Divider(
    color: AppColors.divider,
    thickness: 1,
    height: 16,
  );

  static SizedBox get spacingXs => const SizedBox(height: AppSpacing.xs);
  static SizedBox get spacingSm => const SizedBox(height: AppSpacing.sm);
  static SizedBox get spacingMd => const SizedBox(height: AppSpacing.md);
  static SizedBox get spacingLg => const SizedBox(height: AppSpacing.lg);
  static SizedBox get spacingXl => const SizedBox(height: AppSpacing.xl);
  static SizedBox get spacingXxl => const SizedBox(height: AppSpacing.xxl);

  static SizedBox spacingHorizontal(double width) => SizedBox(width: width);
  static SizedBox spacingVertical(double height) => SizedBox(height: height);
}
