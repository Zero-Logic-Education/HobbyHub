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
  static const Color surfaceVariant = Color(
    0xFFF5F5F5,
  ); // Исправлено с розового на серый

  // Текст
  static const Color textPrimary = Color(
    0xFF1E1E2D,
  ); // Почти черный с синим отливом
  static const Color textSecondary = Color(0xFF70708C); // Серо-синий текст
  static const Color textTertiary = Color(0xFFA0A0B4); // Светлый серо-синий
  static const Color textHint = Color(0xFFCBCBD9); // Подсказка

  // Границы и разделители
  static const Color border = Color(0xFFECECF2); // Более мягкая граница
  static const Color divider = Color(0xFFF1F1F8); // Разделитель

  // Специальные цвета
  static const Color shadow = Color(0x1A000000); // Мягкая тень (10% черного)
  static const Color overlay = Color(0x80000000); // Затемнение фона

  // Цвета социальных сетей
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleRed = Color(0xFFEA4335);
  static const Color googleYellow = Color(0xFFFBBC05);
  static const Color googleGreen = Color(0xFF34A853);
  static const Color facebookBlue = Color(0xFF1877F2);

  // Статусные цвета
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF2994A);
  static const Color error = Color(0xFFEB5757);
  static const Color info = Color(0xFF2D9CDB);

  // Дополнительные цвета
  static const Color pink = Color(0xFFE8A7B8); // Розовый для фона форм
  static const Color lightPink = Color(0xFFFFF0F3); // Светло-розовый фон
  static const Color lightCoral = Color(0xFFFFF5F2); // Очень светло-коралловый

  // Темная тема
  static const Color backgroundDark = Color(0xFF0F0F14);
  static const Color surfaceDark = Color(0xFF1A1A22);
  static const Color surfaceVariantDark = Color(0xFF23232D);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFBBBBBB);
  static const Color darkBorder = Color(0xFF333333);

  // Градиенты для специальных элементов
  static const List<Color> primaryGradient = [
    Color(0xFFF17A5D),
    Color(0xFFFF8B66),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFFF8A7B),
    Color(0xFFF17A5D),
  ];
}
