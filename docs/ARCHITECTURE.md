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

### Авторизация пользователя

1. Пользователь выбирает способ входа (Email / Google / Facebook).
2. Firebase Authentication выдаёт токен.
3. Провайдеры Riverpod обновляют состояние сессии в приложении.
4. Go Router применяет редирект на защищенные экраны.

### Поиск по интересам и геолокации

1. Пользователь открывает экран поиска.
2. Geolocator получает текущие координаты.
3. Firestore-запросы фильтруют сообщества и мероприятия по интересам и приватности.
4. Google Maps отображает результаты на карте.

### Создание мероприятия

1. Организатор заполняет форму создания.
2. Изображение загружается в Cloud Storage.
3. Данные события сохраняются в Firestore (коллекция `events`).
4. Firebase Messaging рассылает push-уведомления участникам сообщества.

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
| Cloud Firestore | Хранение пользователей, сообществ, событий, сообщений | Коллекции users, communities, events, messages |
| Cloud Storage | Хранение изображений профилей и событий | Storage rules, upload/download API |
| Cloud Messaging | Push-уведомления о событиях и активности | FCM токены, отправка уведомлений |
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
| Надёжность | Валидация данных, идемпотентные операции, offline-first возможности SDK |

</div>
