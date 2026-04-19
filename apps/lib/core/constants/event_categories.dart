import 'package:flutter/material.dart';

/// Категории событий
enum EventCategory {
  sports('sports', 'Спорт', Icons.directions_run_rounded),
  tech('tech', 'Технологии', Icons.computer_rounded),
  art('art', 'Творчество', Icons.palette_outlined),
  music('music', 'Музыка', Icons.music_note_rounded),
  wellness('wellness', 'Здоровье', Icons.self_improvement_rounded),
  food('food', 'Еда и напитки', Icons.restaurant_rounded),
  photo('photo', 'Фотография', Icons.camera_alt_rounded),
  books('books', 'Книги', Icons.menu_book_rounded);

  const EventCategory(this.id, this.label, this.icon);

  final String id;
  final String label;
  final IconData icon;

  static EventCategory? fromId(String id) {
    try {
      return EventCategory.values.firstWhere((cat) => cat.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Map<String, dynamic>> toMapList() {
    return EventCategory.values
        .map((cat) => {
              'id': cat.id,
              'label': cat.label,
              'icon': cat.icon,
            })
        .toList();
  }
}

/// Типы событий
enum EventType {
  oneTime('One-time', 'Разовое', Icons.event_outlined),
  recurring('Recurring', 'Повторяющееся', Icons.cached_rounded),
  series('Series', 'Серия', Icons.assignment_outlined);

  const EventType(this.id, this.label, this.icon);

  final String id;
  final String label;
  final IconData icon;

  String toFirestoreValue() {
    switch (this) {
      case EventType.recurring:
        return 'recurring';
      case EventType.series:
        return 'series';
      case EventType.oneTime:
        return 'one-time';
    }
  }

  static EventType? fromId(String id) {
    try {
      return EventType.values.firstWhere((type) => type.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Map<String, dynamic>> toMapList() {
    return EventType.values
        .map((type) => {
              'id': type.id,
              'label': type.label,
              'icon': type.icon,
            })
        .toList();
  }
}
