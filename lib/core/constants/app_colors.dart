import 'package:flutter/material.dart';

/// Цветовая палитра приложения HobbyHub
class AppColors {
  AppColors._();

  // Primary Colors - Coral/Salmon (из дизайна)
  static const Color primary = Color(0xFFFF7B6D); // Coral
  static const Color primaryLight = Color(0xFFFF9B8F);
  static const Color primaryDark = Color(0xFFE66B5D);

  // Secondary Colors - Neutral
  static const Color secondary = Color(0xFF4A5568);
  static const Color secondaryLight = Color(0xFF718096);
  static const Color secondaryDark = Color(0xFF2D3748);

  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textTertiary = Color(0xFFA0AEC0);
  
  // Status Colors
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFF6AD55);
  static const Color error = Color(0xFFFC8181);
  static const Color info = Color(0xFF4299E1);
  
  // Category Colors (для разных типов хобби)
  static const Color sports = Color(0xFFFF7B6D); // Coral - как primary
  static const Color art = Color(0xFFFBD38D); // Amber
  static const Color music = Color(0xFF9F7AEA); // Purple
  static const Color education = Color(0xFF4299E1); // Blue
  static const Color technology = Color(0xFF4FD1C5); // Teal
  static const Color food = Color(0xFFF687B3); // Pink
  static const Color travel = Color(0xFF48BB78); // Green
  static const Color gaming = Color(0xFF667EEA); // Indigo
  
  // Badge Colors
  static const Color badgeFree = Color(0xFFFF7B6D); // Coral для "Free"
  static const Color badgePaid = Color(0xFFFF7B6D); // Coral для "$15", "$2+" и т.д.
  
  // Button Colors
  static const Color buttonPrimary = Color(0xFFFF7B6D); // Coral
  static const Color buttonSecondary = Color(0xFFE2E8F0);
  static const Color buttonText = Color(0xFFFFFFFF);
  
  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF1A202C);
  static const Color surfaceDark = Color(0xFF2D3748);
  static const Color surfaceVariantDark = Color(0xFF4A5568);
  
  // Others
  static const Color divider = Color(0xFFE2E8F0);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
  static const Color iconInactive = Color(0xFFCBD5E0);
  static const Color cardShadow = Color(0x0A000000);
}
