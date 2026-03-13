<div align="center">

# HobbyHub — Mobile App

**Flutter-приложение платформы HobbyHub**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart)](https://dart.dev/)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.x-blue)](https://riverpod.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)

</div>

---

## Содержание

- [Назначение](#назначение)
- [Структура модулей](#структура-модулей)
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

---

## Структура модулей

<div align="center">

| **Директория** | **Назначение** |
|:---|:---|
| `lib/core/config/` | Конфигурация окружений (dev/staging/prod) |
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
| `lib/ui/home/` | Главный экран |
| `lib/ui/search/` | Поиск по интересам и геолокации |
| `lib/ui/communities/` | Список и детали сообществ |
| `lib/ui/create/` | Создание мероприятия |
| `lib/ui/profile/` | Профиль пользователя |
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

# Список доступных устройств
flutter devices

# Запуск на конкретном устройстве
flutter run -d <device_id>

# Сборка debug APK (Android)
flutter build apk --debug

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
