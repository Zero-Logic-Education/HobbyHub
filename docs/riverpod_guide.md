# Управление состоянием с Riverpod

## Обзор

Проект использует **Riverpod** для управления состоянием приложения. Riverpod - это вертикальная переписывание Provider, которая решает его основные проблемы.

## Структура Providers

### 1. Auth Providers (`auth_provider.dart`)

Управление авторизацией пользователя:

```dart
// Текущее состояние авторизации
final authStateProvider = StreamProvider<User?>((ref) { ... });

// ID текущего пользователя
final currentUserIdProvider = Provider<String?>((ref) { ... });

// Проверка авторизации
final isLoggedInProvider = Provider<bool>((ref) { ... });

// Управление авторизацией
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) { ... });
```

**Использование:**
```dart
// В виджете
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isLoading = ref.watch(authNotifierProvider);
    
    return authState.when(
      data: (user) => user != null ? HomeScreen() : AuthScreen(),
      loading: () => LoadingWidget(),
      error: (error, stack) => ErrorWidget(),
    );
  }
}
```

### 2. User Providers (`user_provider.dart`)

Управление данными пользователя:

```dart
// Текущий пользователь (Future)
final currentUserProvider = FutureProvider<User?>((ref) { ... });

// Текущий пользователь (Stream - реальное время)
final currentUserStreamProvider = StreamProvider<User?>((ref) { ... });

// Управление профилем
final currentUserProfileNotifierProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<void>>((ref) { ... });
```

**Использование:**
```dart
// Обновить профиль
ref.read(currentUserProfileNotifierProvider.notifier).updateProfile(
  displayName: 'Новое имя',
  bio: 'Новая биография',
);

// Добавить интерес
ref.read(currentUserProfileNotifierProvider.notifier).addInterest('hobby_id');
```

### 3. Event Providers (`event_provider.dart`)

Управление событиями:

```dart
// Список всех событий
final eventsProvider = StateNotifierProvider<EventsNotifier, AsyncValue<List<Event>>>((ref) { ... });

// События в реальном времени (Stream)
final eventsStreamProvider = StreamProvider<List<Event>>((ref) { ... });

// Отфильтрованные события
final filteredEventsListProvider = Provider<List<Event>>((ref) { ... });

// Выбранное событие
final selectedEventProvider = StateNotifierProvider<SelectedEventNotifier, Event?>((ref) { ... });
```

**Использование:**
```dart
// Получить события
final events = ref.watch(eventsProvider);

// Создать событие
ref.read(eventsProvider.notifier).createEvent(event);

// Применить фильтры
ref.read(eventFilterProvider.notifier).setDateFilter(DateTime.now());
final filtered = ref.watch(filteredEventsListProvider);
```

### 4. Interest Providers (`interest_provider.dart`)

Управление интересами:

```dart
// Все интересы
final interestsProvider = FutureProvider<List<Interest>>((ref) { ... });

// Интересы по категории
final interestsByCategoryProvider = FutureProvider.family<List<Interest>, String>((ref, category) { ... });

// Популярные интересы (Stream)
final popularInterestsStreamProvider = StreamProvider<List<Interest>>((ref) { ... });

// Поиск интересов
final searchedInterestsProvider = FutureProvider<List<Interest>>((ref) { ... });
```

**Использование:**
```dart
// Получить интересы по категории
final interests = ref.watch(interestsByCategoryProvider('sports'));

// Поиск
ref.read(interestSearchProvider.notifier).setSearchQuery('футбол');
final results = ref.watch(searchedInterestsProvider);
```

### 5. UI Providers (`ui_provider.dart`)

Управление состоянием UI:

```dart
// Навигация
final navigationProvider = StateNotifierProvider<NavigationNotifier, AppRoute>((ref) { ... });

// Loading индикатор
final loadingProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) { ... });

// Toast сообщения
final toastProvider = StateNotifierProvider<ToastNotifier, ToastMessage?>((ref) { ... });

// Тема (светлая/темная)
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) { ... });

// Видимость фильтров
final filterVisibilityProvider = StateNotifierProvider<FilterVisibilityNotifier, bool>((ref) { ... });
```

**Использование:**
```dart
// Показать тост
ref.read(toastProvider.notifier).showSuccess('Успешно!');

// Изменить тему
ref.read(themeProvider.notifier).toggleTheme();

// Показать loading
ref.read(loadingProvider.notifier).show();
```

## Типы Providers

### 1. `Provider` - Провайдер (только для чтения)
```dart
final myProvider = Provider<String>((ref) => 'Hello');

// Использование
final value = ref.watch(myProvider);
```

### 2. `StateProvider` - Простое состояние
```dart
final countProvider = StateProvider<int>((ref) => 0);

// Использование
final count = ref.watch(countProvider);
ref.read(countProvider.notifier).state++;
```

### 3. `StateNotifierProvider` - Сложное состояние
```dart
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(authService);
});

// Использование
ref.read(authProvider.notifier).signIn(email, password);
```

### 4. `FutureProvider` - Асинхронные данные
```dart
final userProvider = FutureProvider<User?>((ref) async {
  return await getUser();
});

// Использование - автоматически возвращает AsyncValue
final user = ref.watch(userProvider);
```

### 5. `StreamProvider` - Потоковые данные
```dart
final messagesProvider = StreamProvider<List<Message>>((ref) {
  return firestore.collection('messages').snapshots();
});

// Использование - автоматически возвращает AsyncValue
final messages = ref.watch(messagesProvider);
```

### 6. `FutureProvider.family` - Параметризованный Future
```dart
final userByIdProvider = FutureProvider.family<User?, String>((ref, userId) async {
  return await getUser(userId);
});

// Использование
final user = ref.watch(userByIdProvider('user123'));
```

## AsyncValue

Все асинхронные провайдеры возвращают `AsyncValue<T>`:

```dart
final dataProvider = FutureProvider<String>((ref) async => 'data');

final data = ref.watch(dataProvider);

data.when(
  data: (value) => Text(value),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

## Best Practices

### 1. Используйте ConsumerWidget вместо StatelessWidget
```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataProvider);
    // ...
  }
}
```

### 2. Используйте ConsumerStatefulWidget для локального состояния
```dart
class MyForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyForm> createState() => _MyFormState();
}

class _MyFormState extends ConsumerState<MyForm> {
  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

### 3. Избегайте избыточного использования watch
```dart
// ❌ Неправильно
final a = ref.watch(providerA);
final b = ref.watch(providerB);
final c = ref.watch(providerC);

// ✅ Правильно - используйте select для выбора конкретного значения
final value = ref.watch(
  providerA.select((data) => data.value)
);
```

### 4. Используйте invalidate для перезагрузки данных
```dart
// Перезагрузить провайдер
ref.invalidate(dataProvider);

// Перезагрузить всех зависимых
ref.invalidate(providerA);
```

## Документация

- [Официальная документация Riverpod](https://riverpod.dev)
- [Примеры использования](https://pub.dev/packages/flutter_riverpod/example)
