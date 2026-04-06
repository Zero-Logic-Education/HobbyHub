<div align="center">

# HobbyHub

**Мобильная социальная платформа для поиска людей, сообществ и событий по интересам**

[![Flutter](https://img.shields.io/badge/Flutter-3.41.1-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.11.0-0175C2?logo=dart)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)

</div>

---

## Содержание

- [О проекте](#о-проекте)
- [Технологический стек](#технологический-стек)
- [Текущие сценарии](#текущие-сценарии)
- [Архитектура](#архитектура)
- [Быстрый старт](#быстрый-старт)
- [Команды](#команды)
- [Релиз Android](#релиз-android)
- [Документация](#документация)

---

## О проекте

### Проблема: Социальная изоляция и разрозненность локальных сообществ

Людям сложно находить единомышленников рядом, организовывать совместные активности и поддерживать живое комьюнити по интересам в одном удобном пространстве.

### Решение: HobbyHub

**HobbyHub** — мобильное Flutter-приложение для поиска людей, сообществ и событий по интересам. В текущей реализации есть полный пользовательский путь: авторизация и онбординг, лента и поиск, карта, создание событий, сообщества, чаты, уведомления, профиль и настройки, а также модерация и отзывы.

Проект использует Firebase как backend-платформу: Auth, Firestore, Storage, Messaging и Analytics.

### Текущие сценарии

- Email / Google / Facebook вход и создание профиля.
- Онбординг с возрастом, интересами и геолокацией.
- Главная лента с событиями и быстрый переход в карту и поиск.
- Поиск по интересам и категориям.
- Создание событий и сообществ.
- Чаты и непрочитанные сообщения.
- Отзывы на события и экраны модерации.
- Уведомления, профиль, редактирование профиля и настройки.

---

## Технологический стек

<div align="center">

| **Категория** | **Технологии** | **Версия / Детали** |
|:---:|:---:|:---:|
| Mobile App | Flutter, Dart, Material 3 | Flutter 3.41.1, Dart 3.11.0 |
| State & Navigation | Riverpod, Go Router, GetIt | flutter_riverpod 2.6, go_router 14.6 |
| Backend Platform | Firebase Auth, Firestore, Storage, Messaging, Analytics | Firebase SDK для Flutter |
| Geo & Maps | Google Maps Flutter, Geolocator, Geocoding | Поиск и отображение активностей на карте |
| Data & Utils | Freezed, JSON Serializable, Hive, Dio | Модели, сериализация, локальный кэш, сеть |

</div>

---

## Архитектура

```mermaid
flowchart LR
	subgraph Client["Клиент"]
		User["Пользователь"]
	end

	subgraph App["Mobile App (Flutter)"]
		UI["UI Screens"]
		State["Riverpod State"]
		Router["Go Router"]
		UI --> State
		State --> Router
	end

	subgraph Services["Application Services"]
		AuthSvc["Auth Service"]
		FirestoreSvc["Firestore Service"]
		StorageSvc["Storage Service"]
		MessagingSvc["Messaging Service"]
	end

	subgraph Firebase["Firebase"]
		Auth[("Authentication")]
		DB[("Cloud Firestore")]
		Files[("Cloud Storage")]
		Push[("FCM")]
		Analytics[("Analytics")]
	end

	subgraph External["External APIs"]
		Maps["Google Maps API"]
		Geo["Geolocation APIs"]
	end

	User --> UI
	State --> AuthSvc
	State --> FirestoreSvc
	State --> StorageSvc
	State --> MessagingSvc
	AuthSvc --> Auth
	FirestoreSvc --> DB
	StorageSvc --> Files
	MessagingSvc --> Push
	State --> Analytics
	UI --> Maps
	UI --> Geo
```

---

## Быстрый старт

### Требования

<div align="center">

| Компонент | Минимум | Рекомендуется |
|:---:|:---:|:---:|
| Flutter SDK | 3.0+ | Latest stable |
| Dart SDK | 3.0+ | 3.11+ |
| Xcode (iOS) | 15+ | Latest |
| Android Studio / SDK | API 24+ | Latest |
| Firebase CLI | 13+ | Latest |
</div>

### Клонирование репозитория

```bash
git clone https://github.com/Zero-Logic-Education/HobbyHub.git

cd hobby_hub
```

### Настройки по умолчанию

- Flutter-приложение находится в директории `apps/`
- Firebase-конфиги и правила находятся в `infrastructure/firebase/`
- Конфигурация платформы для приложения: `apps/lib/firebase_options.dart`
- Android Firebase config: `apps/android/app/google-services.json`

### 3. Запуск приложения

```bash
# перейти в приложение
cd apps

# установить зависимости
flutter pub get

# запустить на выбранном устройстве/эмуляторе
flutter run

# быстрый запуск после первого pub get
flutter run --no-pub
```

---

## Команды

### App (Flutter)

```bash
# Перейти в директорию приложения
cd apps

# Установка зависимостей
flutter pub get

# Запуск приложения
flutter run

# Быстрый debug-запуск после первого flutter pub get
flutter run --no-pub

# Статический анализ
flutter analyze

# Тесты
flutter test

# Codegen для моделей (Freezed / JSON)
flutter pub run build_runner build --delete-conflicting-outputs

# Сборка Android APK
flutter build apk --release

# Debug-сборка Android через Gradle
cd android && ./gradlew :app:assembleDebug

# Сборка iOS
flutter build ios --release

# Очистка артефактов
flutter clean
```

### Infrastructure (Firebase)

```bash
# Перейти в инфраструктурную директорию
cd infrastructure/firebase

# Проверка Firestore правил локально (через эмулятор)
firebase emulators:start --only firestore

# Деплой Firestore правил
firebase deploy --only firestore:rules

# Деплой Firestore индексов
firebase deploy --only firestore:indexes

# Деплой Storage правил
firebase deploy --only storage
```

## Документация

- [apps/README.md](apps/README.md) — подробности по Flutter-приложению.
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — актуальная архитектура и потоки.
- [docs/FIRESTORE.md](docs/FIRESTORE.md) — текущая модель данных Firestore.
- [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) — правила вклада и проверки.
- [infrastructure/README.md](infrastructure/README.md) — инфраструктура Firebase и hosting.