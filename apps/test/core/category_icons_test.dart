import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hobby_hub/core/utils/category_icons.dart';

void main() {
  test('returns expected icon for known categories', () {
    expect(categoryIcon('sports'), Icons.directions_run_rounded);
    expect(categoryIcon('tech'), Icons.computer_rounded);
    expect(categoryIcon('music'), Icons.music_note_rounded);
  });

  test('returns fallback icon for unknown category', () {
    expect(categoryIcon('unknown'), Icons.interests_rounded);
  });
}
