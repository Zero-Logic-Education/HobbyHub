<div align="center">

# HobbyHub — Mobile App

**Flutter-приложение платформы HobbyHub**

[![Flutter](https://img.shields.io/badge/Flutter-3.41.1-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.11.0-0175C2?logo=dart)](https://dart.dev/)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.x-blue)](https://riverpod.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)

</div>

---

## Содержание

- [Назначение](#назначение)
- [Структура модулей](#структура-модулей)
- [Что уже есть](#что-уже-есть)
- [Команды приложения](#команды-приложения)
- [Конфигурация](#конфигурация)

---

## Назначение

Мобильное приложение отвечает за все пользовательские сценарии платформы:

- аутентификацию (Email, Google, Facebook) и управление профилем;
- онбординг пользователя (возраст, интересы, геолокация);
- поиск сообществ и мероприятий по интересам и локации;
- создание событий и участие в комьюнити;
- push-уведомления и аналитику пользовательских действий.

### Что уже есть

- `lib/ui/home/` — главная лента, карта, детализация события, модерация и отзывы.
- `lib/ui/search/` — поиск событий и категорий.
- `lib/ui/communities/` — список, создание и детали сообществ.
- `lib/ui/create/` — создание событий.
- `lib/ui/chat/` — список чатов и экран переписки.
- `lib/ui/profile/` — профиль, редактирование и настройки.
- `lib/ui/notifications/` — экран уведомлений.
- `lib/ui/onboarding/` и `lib/ui/auth/` — онбординг и вход.

---

## Структура модулей

<div align="center">

| **Директория** | **Назначение** |
|:---|:---|
| `lib/core/config/` | Конфигурация приложения и окружений |
| `lib/core/constants/` | Глобальные константы |
| `lib/core/di/` | Dependency Injection и инициализация сервисов (GetIt) |
| `lib/core/router/` | Маршрутизация, guards и навигационные утилиты (Go Router) |
| `lib/core/theme/` | Светлая и тёмная темы (Material 3) |
| `lib/models/` | Доменные модели и сериализация данных |
| `lib/providers/` | Riverpod-провайдеры состояния |
| `lib/services/firebase/` | Сервисы Firebase (Auth, Firestore, Storage, Messaging, Analytics) |
| `lib/ui/welcome/` | Экран приветствия |
| `lib/ui/onboarding/` | Онбординг нового пользователя |
| `lib/ui/auth/` | Авторизация (Email, Google, Facebook) |
| `lib/ui/home/` | Главный экран, карта, детализация события, модерация, отзывы |
| `lib/ui/search/` | Поиск по интересам и геолокации |
| `lib/ui/communities/` | Список и детали сообществ |
| `lib/ui/create/` | Создание мероприятия |
| `lib/ui/profile/` | Профиль пользователя, редактирование и настройки |
| `lib/ui/notifications/` | Уведомления пользователя |
| `lib/ui/main_shell/` | Корневой shell с навигацией |
| `lib/ui/shared/` | Переиспользуемые виджеты |

</div>

---

## Команды приложения

```bash
# Перейти в директорию apps
cd apps

# Установка зависимостей
flutter pub get

# Запуск на устройстве / эмуляторе
flutter run

# Быстрый запуск после первого pub get
flutter run --no-pub

# Список доступных устройств
flutter devices

# Запуск на конкретном устройстве
flutter run -d <device_id>

# Сборка debug APK (Android)
flutter build apk --debug

# Сборка debug APK через Gradle
cd android && ./gradlew :app:assembleDebug

# Сборка release APK (Android)
flutter build apk --release

# Сборка iOS
flutter build ios --release

# Кодогенерация (Freezed / JSON Serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Codegen в watch-режиме
flutter pub run build_runner watch --delete-conflicting-outputs

# Статический анализ
flutter analyze

# Тесты
flutter test

# Очистка артефактов сборки
flutter clean
```

---

## Конфигурация

<div align="center">

| **Файл** | **Назначение** |
|:---|:---|
| `lib/firebase_options.dart` | Параметры подключения к Firebase (генерируется FlutterFire CLI) |
| `lib/core/config/app_config.dart` | Конфигурации окружений приложения |
| `pubspec.yaml` | Зависимости и метаданные пакета |
| `analysis_options.yaml` | Правила статического анализа (flutter_lints) |
| `android/app/google-services.json` | Конфигурация Google Services для Android |
| `ios/Runner/GoogleService-Info.plist` | Конфигурация Google Services для iOS |

</div>

## Практика запуска

Для повседневной разработки обычно хватает:

```bash
cd apps
flutter run --no-pub -d emulator-5554
```

Если нужно только проверить сборку Android без запуска приложения:

```bash
cd apps/android
./gradlew :app:assembleDebug
```

## Android release readiness

Для production release-сборки требуется указать package id и ключ подписи.

Можно задать через `apps/android/gradle.properties` или переменные окружения:

```text
HH_APPLICATION_ID=com.zerologiceducation.hobbyhub
HH_RELEASE_STORE_FILE=/absolute/path/to/release-keystore.jks
HH_RELEASE_STORE_PASSWORD=***
HH_RELEASE_KEY_ALIAS=***
HH_RELEASE_KEY_PASSWORD=***
```

Шаблон: [apps/android/keystore.properties.example](android/keystore.properties.example)
