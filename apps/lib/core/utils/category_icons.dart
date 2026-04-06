import 'package:flutter/material.dart';

IconData categoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'sports':
      return Icons.directions_run_rounded;
    case 'tech':
      return Icons.computer_rounded;
    case 'art':
      return Icons.palette_outlined;
    case 'music':
      return Icons.music_note_rounded;
    case 'food':
      return Icons.restaurant_rounded;
    case 'wellness':
      return Icons.self_improvement_rounded;
    case 'photo':
      return Icons.camera_alt_rounded;
    case 'books':
      return Icons.menu_book_rounded;
    default:
      return Icons.interests_rounded;
  }
}
