import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

const Map<String, Color> _categoryColorMap = {
  'sports': Color(0xFF81C784),
  'tech': Color(0xFF64B5F6),
  'arts': Color(0xFFBA68C8),
  'music': Color(0xFFFFB74D),
  'health': Color(0xFF66BB6A),
  'gaming': Color(0xFF90A4AE),
  'cooking': Color(0xFFA1887F),
  'travel': Color(0xFF4DD0E1),
  'other': AppColors.primary,
};

const Map<String, String> _categoryAliases = {
  'спорт': 'sports',
  'sports': 'sports',
  'технологии': 'tech',
  'тех': 'tech',
  'tech': 'tech',
  'творчество': 'arts',
  'искусство': 'arts',
  'arts': 'arts',
  'art': 'arts',
  'музыка': 'music',
  'music': 'music',
  'здоровье': 'health',
  'health': 'health',
  'игры': 'gaming',
  'гейминг': 'gaming',
  'gaming': 'gaming',
  'кулинария': 'cooking',
  'еда': 'cooking',
  'cooking': 'cooking',
  'путешествия': 'travel',
  'travel': 'travel',
};

const Map<String, String> _displayLabels = {
  'sports': 'Спорт',
  'tech': 'Технологии',
  'arts': 'Творчество',
  'music': 'Музыка',
  'health': 'Здоровье',
  'gaming': 'Игры',
  'cooking': 'Кулинария',
  'travel': 'Путешествия',
  'other': 'Разное',
};

String normalizeCategoryKey(String category) {
  final normalized = category.trim().toLowerCase();
  if (normalized.isEmpty) {
    return 'other';
  }
  return _categoryAliases[normalized] ?? 'other';
}

Color getCategoryColor(String category) {
  final key = normalizeCategoryKey(category);
  return _categoryColorMap[key] ?? AppColors.primary;
}

String getCategoryDisplayLabel(String category) {
  final key = normalizeCategoryKey(category);
  return _displayLabels[key] ?? _displayLabels['other']!;
}

String getCategoryDisplayLabelByKey(String key) {
  return _displayLabels[key] ?? _displayLabels['other']!;
}