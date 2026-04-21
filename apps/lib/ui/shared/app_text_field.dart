import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Кастомное текстовое поле с поддержкой валидации
class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    required this.label,
    required this.controller,
    this.hint,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    super.key,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Text(
            widget.label,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Input field
        Container(
          height: AppSpacing.inputHeight, // Фиксированная высота 48.0
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : _isFocused
                  ? AppColors.primary
                  : AppColors.border,
              width: _isFocused ? 1.5 : 1,
            ),
            color: hasError
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surfaceVariant,
          ),
          alignment: Alignment.center, // Центрирование контента
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            validator: widget.validator,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.textHint,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              isDense: true, // Более компактное поле
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical:
                    0, // Убираем вертикальные отступы внутри, так как высота фиксирована
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: IconTheme(
                        data: const IconThemeData(
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        child: widget.prefixIcon!,
                      ),
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: IconTheme(
                        data: const IconThemeData(
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        child: widget.suffixIcon!,
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 0,
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 0,
              ),
            ),
            textAlignVertical: TextAlignVertical.center, // Центрирование текста
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),

        // Error text
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              widget.errorText!,
              style: AppTypography.labelSmall.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

/// Поле пароля с переключением видимости
class PasswordField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const PasswordField({
    required this.label,
    required this.controller,
    this.hint,
    this.errorText,
    this.onChanged,
    this.validator,
    super.key,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      hint: widget.hint,
      errorText: widget.errorText,
      keyboardType: TextInputType.visiblePassword,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      validator: widget.validator,
      suffixIcon: GestureDetector(
        onTap: () => setState(() => _obscureText = !_obscureText),
        child: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}

/// Поле email с валидацией
class EmailField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const EmailField({
    required this.label,
    required this.controller,
    this.hint,
    this.errorText,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      controller: controller,
      hint: hint ?? 'example@email.com',
      errorText: errorText,
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
      prefixIcon: const Icon(
        Icons.email_outlined,
        color: AppColors.textSecondary,
        size: 20,
      ),
    );
  }
}
