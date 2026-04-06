import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AppSnackType { info, success, warning, error }

void showAppSnackBar(
  BuildContext context,
  String message, {
  AppSnackType type = AppSnackType.info,
  Duration duration = const Duration(seconds: 4),
  SnackBarAction? action,
}) {
  final color = switch (type) {
    AppSnackType.info => AppColors.info,
    AppSnackType.success => AppColors.success,
    AppSnackType.warning => AppColors.warning,
    AppSnackType.error => AppColors.error,
  };

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      action: action,
    ),
  );
}