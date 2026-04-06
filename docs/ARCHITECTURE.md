<div align="center">

# HobbyHub Architecture

**Архитектурное описание системы и границ компонентов**

[![Flutter](https://img.shields.io/badge/Flutter-Mobile%20App-02569B?logo=flutter)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)

</div>

---

## Содержание

- [Системный обзор](#системный-обзор)
- [Ключевые потоки](#ключевые-потоки)
- [Слои приложения](#слои-приложения)
- [Границы Firebase](#границы-firebase)
- [Нефункциональные требования](#нефункциональные-требования)

---

## Системный обзор

<div align="center">

| **Домен** | **Технология** | **Назначение** |
|:---|:---|:---|
| Mobile App | Flutter / Dart | UI, навигация, бизнес-логика, локальное состояние |
| State Management | Riverpod | Реактивное состояние, зависимости, обновление сессии |
| Navigation | Go Router | Декларативный роутинг и route guards |
| Backend Platform | Firebase | Auth, Firestore, Storage, Messaging, Analytics |
| Geo Stack | Google Maps, Geolocator, Geocoding | Геолокация, поиск по радиусу, визуализация результатов |

</div>

---

## Ключевые потоки

### Авторизация и онбординг

1. Пользователь выбирает способ входа (Email / Google / Facebook).
2. Firebase Authentication возвращает пользователя и Firebase UID.
3. Riverpod обновляет состояние сессии, профиль и связанные провайдеры.
4. Go Router переводит пользователя на онбординг, главный shell или экран входа в зависимости от состояния.

### Лента, поиск и карта

1. Пользователь открывает главную ленту или экран поиска.
2. Firestore отдает события, сообщества и интересы.
3. Geolocator / Geocoding определяют координаты и адрес.
4. Google Maps отображает события на карте и позволяет открыть детализацию.

### Создание и модерация событий

1. Организатор заполняет форму создания события.
2. Обложки и изображения загружаются в Cloud Storage.
3. Событие сохраняется в Firestore, а участники и статус хранятся в самом документе события.
4. Модерация и отзывы работают через отдельные экраны и подколлекции `applications` и `reviews` внутри события.

### Чаты и уведомления

1. Для переписки создается документ чата в коллекции `chats`.
2. Сообщения хранятся в подколлекции `messages` внутри чата.
3. Пользовательские уведомления читаются из подколлекции `users/{uid}/notifications`.
4. FCM токены привязываются к пользователю после входа, а push-сообщения обрабатываются сервисом Messaging.

---

## Слои приложения

<div align="center">

| **Слой** | **Директория** | **Назначение** |
|:---|:---|:---|
| UI | `apps/lib/ui/` | Экраны, shell-навигация, переиспользуемые виджеты |
| State | `apps/lib/providers/` | Riverpod-провайдеры и реактивная логика состояния |
| Services | `apps/lib/services/` | Интеграции с Firebase и сервисный слой приложения |
| Models | `apps/lib/models/` | Доменные сущности и сериализация данных |
| Core | `apps/lib/core/` | DI (GetIt), роутинг, темы, конфиг и константы |

</div>

---

## Границы Firebase

<div align="center">

| **Компонент** | **Назначение** | **Ключевые артефакты** |
|:---|:---|:---|
| Authentication | Email и социальный вход, управление сессией | Firebase Auth, Google Sign-In, Facebook Auth |
| Cloud Firestore | Хранение пользователей, сообществ, событий, чатов и уведомлений | Коллекции users, communities, events, chats и подколлекции messages/reviews/applications/notifications |
| Cloud Storage | Хранение изображений профилей, событий и сообществ | Storage rules, upload/download API |
| Cloud Messaging | Push-уведомления о событиях и активности | FCM токены, топики, отправка уведомлений |
| Analytics | Сбор продуктовых событий приложения | Firebase Analytics events |

</div>

---

## Нефункциональные требования

<div align="center">

| **Требование** | **Подход** |
|:---|:---|
| Безопасность | Firestore/Storage Security Rules, Firebase Auth, OAuth |
| Производительность | Локальный кэш (Hive), оптимизация изображений, lazy loading |
| Масштабируемость | Serverless Firebase, масштабирование managed-сервисов |
| Надёжность | Валидация данных, safe fallback в UI, идемпотентные операции, возможности offline-first SDK |

</div>
