import 'package:flutter/material.dart';

/// Цветовая палитра приложения HobbyHub
abstract class AppColors {
  // Основные цвета
  static const Color primary = Color(0xFFF17A5D); // Коралловый красный
  static const Color secondary = Color(0xFFFF8A7B); // Светло-коралловый
  static const Color accent = Color(0xFFFF6B4A); // Ярко-коралловый

  // Фоны
  static const Color background = Color(0xFFFAFAFA); // Светло-серый фон
  static const Color surface = Color(0xFFFFFFFF); // Белая поверхность
  static const Color surfaceSecondary = Color(0xFFF5F5F5); // Серая поверхность
  static const Color surfaceVariant = Color(0xFFFAE8ED); // Светло-розовый (для формы)

  // Текст
  static const Color textPrimary = Color(0xFF1A1A1A); // Темный текст
  static const Color textSecondary = Color(0xFF666666); // Серый текст
  static const Color textTertiary = Color(0xFF999999); // Светло-серый текст
  static const Color textHint = Color(0xFFCCCCCC); // Подсказка

  // Границы и разделители
  static const Color border = Color(0xFFE5E5E5); // Легкая граница
  static const Color divider = Color(0xFFEEEEEE); // Разделитель

  // Статусные цвета
  static const Color success = Color(0xFF4CAF50); // Зеленый
  static const Color warning = Color(0xFFFFC107); // Оранжевый
  static const Color error = Color(0xFFE74C3C); // Красный
  static const Color info = Color(0xFF2196F3); // Синий

  // Дополнительные цвета
  static const Color pink = Color(0xFFE8A7B8); // Розовый для фона форм
  static const Color lightPink = Color(0xFFFAE8ED); // Светло-розовый фон
  static const Color lightCoral = Color(0xFFFDE8E3); // Очень светло-коралловый

  // Темная тема
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2A2A2A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFBBBBBB);
  static const Color darkBorder = Color(0xFF333333);

  // Градиенты для специальных элементов
  static const List<Color> primaryGradient = [
    Color(0xFFF17A5D),
    Color(0xFFFF6B4A),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFFF8A7B),
    Color(0xFFF17A5D),
  ];
}
