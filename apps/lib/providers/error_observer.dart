import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../core/theme/app_colors.dart';

class GlobalErrorObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (newValue is AsyncError) {
      final error = newValue.error.toString();

      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            error.startsWith('Exception: ') ? error.substring(11) : error,
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
