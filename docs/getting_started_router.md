# Начало работы с Go Router в HobbyHub

## Что это такое?

Go Router - это пакет для навигации в Flutter приложениях. Он управляет переходами между экранами (как кнопка "назад", открытие профиля и т.д.).

## Самое быстрое начало (2 минуты)

### 1. Импортируйте

```dart
import 'core/router/navigation_helper.dart';
```

### 2. Используйте в вашем виджете

```dart
class MyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => NavigationHelper.goHome(context),
      child: const Text('На главную'),
    );
  }
}
```

**Готово!** 🎉

## Основные команды

```dart
// Переходы
NavigationHelper.goHome(context);              // На главную
NavigationHelper.goProfile(context);           // На профиль
NavigationHelper.goMap(context);               // На карту
NavigationHelper.goEventDetail(context, id);   // На событие
NavigationHelper.goBack(context);              // Назад
```

## Примеры из реальной жизни

### Кнопка для перехода на профиль

```dart
class ProfileButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.person),
      onPressed: () => NavigationHelper.goProfile(context),
    );
  }
}
```

### Список событий с нажатием

```dart
class EventsList extends StatelessWidget {
  final List<Event> events;

  const EventsList({required this.events});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return ListTile(
          title: Text(event.title),
          onTap: () => NavigationHelper.goEventDetail(context, event.id),
        );
      },
    );
  }
}
```

### Навигация с диалогом

```dart
class DeleteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Удалить?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Удалить'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          NavigationHelper.goBack(context);
        }
      },
      child: const Text('Удалить'),
    );
  }
}
```

## Различие между методами навигации

### `go()` - Замена экрана

```dart
context.go('/home');  // Текущий экран заменяется на /home
// История: было [/auth] → стало [/home]
```

### `push()` - Добавление экрана

```dart
context.push('/home/event/123');  // Новый экран добавляется на стек
// История: было [/home] → стало [/home, /home/event/123]
```

### `pop()` - Возврат на предыдущий

```dart
context.pop();  // Удаляет текущий экран
// История: было [/home, /home/event/123] → стало [/home]
```

## Автоматическая аутентификация

Роутер **автоматически** управляет входом:

```dart
// Если пользователь НЕ вошел → он всегда видит /auth
// Если пользователь ВОШЕЛ → он не может видеть /auth
// Приложение само перенаправляет куда надо
```

## Самые частые ошибки

### Забыли context

```dart
// НЕПРАВИЛЬНО - ошибка!
NavigationHelper.goHome();  

// ПРАВИЛЬНО
NavigationHelper.goHome(context);
```

### Неправильная сигнатура

```dart
// НЕПРАВИЛЬНО - где ID?
NavigationHelper.goEventDetail(context);  

// ПРАВИЛЬНО
NavigationHelper.goEventDetail(context, 'event_123');
```

### Возврат назад когда нечего возвращаться

```dart
// НЕПРАВИЛЬНО - может не сработать
context.pop();  

// ПРАВИЛЬНО
if (context.canPop()) {
  context.pop();
} else {
  NavigationHelper.goHome(context);
}
```

## Где найти информацию

- [Полное руководство](./go_router_guide.md) - все подробности
- [Шпаргалка](./router_cheatsheet.md) - быстрый справочник
- [Сводка реализации](./router_implementation_summary.md) - что было сделано

## Вопросы?

Если не работает:

1. Проверьте, импортировали ли вы `navigation_helper.dart`
2. Убедитесь, что передали `context` в метод
3. Проверьте, корректно ли передали параметры (например, ID события)
4. Посмотрите консоль - Go Router логирует навигацию в режиме разработки

## Дальше

Теперь создавайте экраны! Когда у вас готов новый экран (например, `EventDetailScreen`), просто замените заглушку в `app_router.dart`.

Удачи в разработке.
