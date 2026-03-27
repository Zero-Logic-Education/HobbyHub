import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_hub/models/event.dart';
import 'package:hobby_hub/providers/event_provider.dart';

void main() {
  group('Event Search Tests', () {
    test('eventSearchQueryProvider initial state is empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(eventSearchQueryProvider), '');
    });

    test('eventSearchQueryProvider state updates correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(eventSearchQueryProvider.notifier).state = 'Football';
      expect(container.read(eventSearchQueryProvider), 'Football');
    });

    test('searchedEventsProvider filters events based on query', () {
      final now = DateTime.now();
      final testEvents = [
        Event(
          id: '1',
          organizerId: 'user1',
          title: 'Football Match',
          description: 'Local football match',
          startTime: now,
          latitude: 0,
          longitude: 0,
          createdAt: now,
        ),
        Event(
          id: '2',
          organizerId: 'user2',
          title: 'Chess Tournament',
          description: 'Amateur chess',
          startTime: now,
          latitude: 0,
          longitude: 0,
          createdAt: now,
        ),
        Event(
          id: '3',
          organizerId: 'user3',
          title: 'Football Training',
          description: 'Training session',
          startTime: now,
          latitude: 0,
          longitude: 0,
          createdAt: now,
        ),
      ];

      final container = ProviderContainer(
        overrides: [filteredEventsListProvider.overrideWithValue(testEvents)],
      );
      addTearDown(container.dispose);

      // Verify initial state (all events)
      expect(container.read(searchedEventsProvider).length, 3);

      // Update query and verify filtered results
      container.read(eventSearchQueryProvider.notifier).state = 'FOOTBALL';

      final filteredEvents = container.read(searchedEventsProvider);

      expect(filteredEvents.length, 2);
      expect(
        filteredEvents.map((e) => e.title),
        containsAll(['Football Match', 'Football Training']),
      );
      expect(
        filteredEvents.map((e) => e.title),
        isNot(contains('Chess Tournament')),
      );
    });

    test('searchedEventsProvider filters by description as well', () {
      final now = DateTime.now();
      final testEvents = [
        Event(
          id: '1',
          organizerId: 'user1',
          title: 'Morning Run',
          description: 'Running session in the park',
          startTime: now,
          latitude: 0,
          longitude: 0,
          createdAt: now,
        ),
        Event(
          id: '2',
          organizerId: 'user2',
          title: 'Yoga Class',
          description: 'Relaxing yoga in the park',
          startTime: now,
          latitude: 0,
          longitude: 0,
          createdAt: now,
        ),
      ];

      final container = ProviderContainer(
        overrides: [filteredEventsListProvider.overrideWithValue(testEvents)],
      );
      addTearDown(container.dispose);

      container.read(eventSearchQueryProvider.notifier).state = 'park';

      final filteredEvents = container.read(searchedEventsProvider);

      expect(filteredEvents.length, 2);
      expect(
        filteredEvents.map((e) => e.title),
        containsAll(['Morning Run', 'Yoga Class']),
      );
    });
  });
}
