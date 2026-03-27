import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event.dart';
import '../../services/firebase/firestore_service.dart';
import 'user_provider.dart';

/// State notifier для управления списком событий
class EventsNotifier extends StateNotifier<AsyncValue<List<Event>>> {
  final FirestoreService _firestoreService;

  EventsNotifier(this._firestoreService)
      : super(const AsyncValue.loading());

  /// Загрузить события
  Future<void> fetchEvents({int limit = 20}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final querySnapshot = await _firestoreService.getEvents(limit: limit);
      return querySnapshot.docs
          .map((doc) =>
              Event.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    });
  }

  /// Добавить новое событие
  Future<void> createEvent(Event event) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _firestoreService.createEvent(event.toJson());
      // Перезагрузить список событий
      final querySnapshot = await _firestoreService.getEvents(limit: 20);
      return querySnapshot.docs
          .map((doc) =>
              Event.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    });
  }

  /// Обновить событие
  Future<void> updateEvent(String eventId, Event event) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _firestoreService.updateEvent(eventId, event.toJson());
      // Перезагрузить список событий
      final querySnapshot = await _firestoreService.getEvents(limit: 20);
      return querySnapshot.docs
          .map((doc) =>
              Event.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    });
  }

  /// Удалить событие
  Future<void> deleteEvent(String eventId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _firestoreService.deleteEvent(eventId);
      // Перезагрузить список событий
      final querySnapshot = await _firestoreService.getEvents(limit: 20);
      return querySnapshot.docs
          .map((doc) =>
              Event.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    });
  }
}

/// Провайдер для списка событий
final eventsProvider =
    StateNotifierProvider<EventsNotifier, AsyncValue<List<Event>>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final notifier = EventsNotifier(firestoreService);
  // Загружаем события при инициализации
  Future.microtask(() => notifier.fetchEvents());
  return notifier;
});

/// Stream провайдер для отслеживания событий в реальном времени
final eventsStreamProvider = StreamProvider<List<Event>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.eventsStream().map((querySnapshot) {
    return querySnapshot.docs
        .map((doc) =>
            Event.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
        .toList();
  });
});

/// State notifier для фильтрации событий
class EventFilterNotifier extends StateNotifier<EventFilters> {
  EventFilterNotifier()
      : super(const EventFilters());

  void setDateFilter(DateTime? date) {
    state = state.copyWith(date: date, weekendOnly: false);
  }

  void setCategoryFilter(List<String> categories) {
    state = state.copyWith(categories: categories);
  }

  void setAgeFilter(int? minAge) {
    state = state.copyWith(minAge: minAge);
  }

  void setFreeFilter(bool? isFree) {
    state = state.copyWith(isFree: isFree);
  }

  void setWeekendOnly(bool enabled) {
    state = state.copyWith(
      weekendOnly: enabled,
      date: enabled ? null : state.date,
    );
  }

  void clearFilters() {
    state = const EventFilters();
  }
}

/// Класс для фильтров событий
class EventFilters {
  final DateTime? date;
  final List<String> categories;
  final int? minAge;
  final bool? isFree;
  final bool weekendOnly;

  static const Object _unset = Object();

  const EventFilters({
    this.date,
    this.categories = const [],
    this.minAge,
    this.isFree,
    this.weekendOnly = false,
  });

  EventFilters copyWith({
    Object? date = _unset,
    List<String>? categories,
    Object? minAge = _unset,
    Object? isFree = _unset,
    Object? weekendOnly = _unset,
  }) {
    return EventFilters(
      date: identical(date, _unset) ? this.date : date as DateTime?,
      categories: categories ?? this.categories,
      minAge: identical(minAge, _unset) ? this.minAge : minAge as int?,
      isFree: identical(isFree, _unset) ? this.isFree : isFree as bool?,
      weekendOnly: identical(weekendOnly, _unset)
          ? this.weekendOnly
          : weekendOnly as bool,
    );
  }
}

/// Провайдер для фильтров событий
final eventFilterProvider =
    StateNotifierProvider<EventFilterNotifier, EventFilters>((ref) {
  return EventFilterNotifier();
});

/// Провайдер для отфильтрованных событий
final filteredEventsListProvider = Provider<List<Event>>((ref) {
  final eventsAsync = ref.watch(eventsStreamProvider);
  final filters = ref.watch(eventFilterProvider);

  return eventsAsync.maybeWhen(
    data: (events) {
      var filtered = events;

      // Фильтр только на выходных
      if (filters.weekendOnly) {
        filtered = filtered.where((event) {
          final weekday = event.startTime.weekday;
          return weekday == DateTime.saturday || weekday == DateTime.sunday;
        }).toList();
      }

      // Фильтр по дате
      if (filters.date != null) {
        filtered = filtered
            .where((event) =>
                event.startTime.year == filters.date!.year &&
                event.startTime.month == filters.date!.month &&
                event.startTime.day == filters.date!.day)
            .toList();
      }

      // Фильтр по категориям
      if (filters.categories.isNotEmpty) {
        filtered = filtered
            .where((event) =>
                event.categories.any((cat) => filters.categories.contains(cat)))
            .toList();
      }

      // Фильтр по возрасту
      if (filters.minAge != null) {
        filtered = filtered
            .where((event) => event.minAge >= filters.minAge!)
            .toList();
      }

      // Фильтр по цене
      if (filters.isFree != null) {
        filtered = filtered.where((event) => event.isFree == filters.isFree).toList();
      }

      return filtered;
    },
    orElse: () => [],
  );
});

/// State notifier для выбранного события
class SelectedEventNotifier extends StateNotifier<Event?> {
  SelectedEventNotifier() : super(null);

  void selectEvent(Event event) {
    state = event;
  }

  void deselectEvent() {
    state = null;
  }
}

/// Провайдер для выбранного события
final selectedEventProvider =
    StateNotifierProvider<SelectedEventNotifier, Event?>((ref) {
  return SelectedEventNotifier();
});

/// Провайдер для строки поиска
final eventSearchQueryProvider = StateProvider<String>((ref) => '');

/// Провайдер для поиска событий
final searchedEventsProvider = Provider<List<Event>>((ref) {
  final query = ref.watch(eventSearchQueryProvider).toLowerCase();
  final events = ref.watch(filteredEventsListProvider);

  if (query.isEmpty) return events;

  return events.where((event) {
    return event.title.toLowerCase().contains(query) ||
           event.description.toLowerCase().contains(query);
  }).toList();
});
