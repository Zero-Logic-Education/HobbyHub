import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/event.dart';
import '../../models/interest.dart';
import 'user_provider.dart';

/// Провайдер для списка всех интересов
final interestsProvider = FutureProvider<List<Interest>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final querySnapshot = await firestoreService.getInterests();
  return querySnapshot.docs
      .map((doc) => Interest.fromJson(doc.data() as Map<String, dynamic>))
      .toList();
});

/// Провайдер для интересов по категории
final interestsByCategoryProvider =
    FutureProvider.family<List<Interest>, String>((ref, category) async {
      final firestoreService = ref.watch(firestoreServiceProvider);
      final querySnapshot = await firestoreService.getInterestsByCategory(
        category,
      );
      return querySnapshot.docs
          .map((doc) => Interest.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });

/// Stream провайдер для популярных интересов
final popularInterestsStreamProvider = StreamProvider<List<Interest>>((
  ref,
) async* {
  final firestoreService = ref.watch(firestoreServiceProvider);
  yield* firestoreService.popularInterestsStream().map((querySnapshot) {
    return querySnapshot.docs
        .map((doc) => Interest.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  });
});

/// State notifier для фильтрации интересов
class InterestFilterNotifier extends StateNotifier<List<String>> {
  InterestFilterNotifier() : super([]);

  /// Добавить интерес в фильтр
  void addFilter(String interestId) {
    state = [...state, interestId];
  }

  /// Удалить интерес из фильтра
  void removeFilter(String interestId) {
    state = state.where((id) => id != interestId).toList();
  }

  /// Очистить все фильтры
  void clearFilters() {
    state = [];
  }

  /// Установить фильтры
  void setFilters(List<String> filters) {
    state = filters;
  }
}

/// Провайдер для управления фильтрами интересов
final interestFilterProvider =
    StateNotifierProvider<InterestFilterNotifier, List<String>>((ref) {
      return InterestFilterNotifier();
    });

/// Провайдер для событий, отфильтрованных по интересам
final filteredEventsProvider = FutureProvider<List<Event>>((ref) async {
  final filters = ref.watch(interestFilterProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  if (filters.isEmpty) {
    // Если нет фильтров, получить все события
    final querySnapshot = await firestoreService.getEvents();
    return querySnapshot.docs
        .map(
          (doc) => Event.fromJson({
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id,
          }),
        )
        .toList();
  }

  // Получить события по категориям
  final querySnapshot = await firestoreService.searchEventsByCategories(
    filters,
  );
  return querySnapshot.docs
      .map(
        (doc) => Event.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        }),
      )
      .toList();
});

/// State notifier для поиска интересов
class InterestSearchNotifier extends StateNotifier<String> {
  InterestSearchNotifier() : super('');

  /// Установить поисковый запрос
  void setSearchQuery(String query) {
    state = query;
  }

  /// Очистить поиск
  void clearSearch() {
    state = '';
  }
}

/// Провайдер для управления поиском интересов
final interestSearchProvider =
    StateNotifierProvider<InterestSearchNotifier, String>((ref) {
      return InterestSearchNotifier();
    });

/// Провайдер для поиска интересов
final searchedInterestsProvider = FutureProvider<List<Interest>>((ref) async {
  final searchQuery = ref.watch(interestSearchProvider);
  final allInterests = await ref.watch(interestsProvider.future);

  if (searchQuery.isEmpty) {
    return allInterests;
  }

  final lowerQuery = searchQuery.toLowerCase();
  return allInterests
      .where((interest) => interest.name.toLowerCase().contains(lowerQuery))
      .toList();
});
