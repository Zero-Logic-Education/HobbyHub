import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hobby_hub/providers/auth_provider.dart';
import 'package:hobby_hub/services/firebase/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockAuthService extends Mock implements AuthService {}
class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AuthNotifier Tests', () {
    test('initial state is AsyncData', () {
      final container = makeContainer();
      final state = container.read(authNotifierProvider);
      expect(state, const AsyncValue<void>.data(null));
    });

    test('signInWithEmail success sets loading then data', () async {
      final mockCredential = MockUserCredential();
      when(() => mockAuthService.signInWithEmail(
            email: 'test@test.com',
            password: 'password123',
          )).thenAnswer((_) async => mockCredential);

      final container = makeContainer();
      final notifier = container.read(authNotifierProvider.notifier);

      final future = notifier.signInWithEmail('test@test.com', 'password123');

      expect(container.read(authNotifierProvider).isLoading, true);

      await future;

      final stateAfter = container.read(authNotifierProvider);
      expect(stateAfter, isA<AsyncData<void>>());
      verify(() => mockAuthService.signInWithEmail(
            email: 'test@test.com',
            password: 'password123',
          )).called(1);
    });

    test('signInWithEmail failure sets error state', () async {
      final exception = Exception('Auth failed');
      when(() => mockAuthService.signInWithEmail(
            email: 'test@test.com',
            password: 'wrong',
          )).thenThrow(exception);

      final container = makeContainer();
      final notifier = container.read(authNotifierProvider.notifier);

      await notifier.signInWithEmail('test@test.com', 'wrong');

      final state = container.read(authNotifierProvider);
      expect(state.hasError, true);
      expect(state.error, exception);
    });
  });
}
