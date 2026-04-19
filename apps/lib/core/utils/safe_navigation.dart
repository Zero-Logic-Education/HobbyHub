import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

/// Безопасная навигация назад с fallback на home
void safeGoBack(BuildContext context, {String? fallbackRoute}) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallbackRoute ?? AppRoutes.home);
  }
}

/// Безопасная навигация назад для кнопок
VoidCallback safeBackButton(BuildContext context, {String? fallbackRoute}) {
  return () => safeGoBack(context, fallbackRoute: fallbackRoute);
}
