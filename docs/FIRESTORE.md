<div align="center">

# HobbyHub Firestore

**Документ по модели данных и правилам безопасности Firestore**

[![Firestore](https://img.shields.io/badge/Firestore-NoSQL-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/docs/firestore)
[![Security Rules](https://img.shields.io/badge/Security-Rules-orange?logo=firebase&logoColor=black)](https://firebase.google.com/docs/firestore/security/get-started)

</div>

---

## Содержание

- [Назначение](#назначение)
- [Ключевые коллекции](#ключевые-коллекции)
- [Правила безопасности](#правила-безопасности)
- [Правила изменений схемы](#правила-изменений-схемы)

---

## Назначение

Этот документ фиксирует модель данных Firestore на уровне домена.

Исполняемой спецификацией являются файлы в `infrastructure/firebase/`. Приоритет у них.

---

## Ключевые коллекции

<div align="center">

| **Коллекция** | **Назначение** |
|:---|:---|
| `users` | Профили пользователей и настройки приватности |
| `users/{id}/friends` | Список друзей пользователя |
| `users/{id}/followers` | Подписчики пользователя |
| `users/{id}/following` | Подписки пользователя |
| `users/{id}/interests` | Интересы и хобби пользователя |
| `users/{id}/sentRequests` | Исходящие заявки в друзья |
| `users/{id}/receivedRequests` | Входящие заявки в друзья |
| `communities` | Сообщества по интересам |
| `communities/{id}/members` | Участники сообщества |
| `communities/{id}/events` | Мероприятия сообщества |
| `events` | Мероприятия (публичные и приватные) |
| `events/{id}/participants` | Участники мероприятия |
| `events/{id}/reviews` | Отзывы участников |
| `interests` | Глобальный справочник интересов (read-only для пользователей) |
| `messages` | Личные сообщения между пользователями |

</div>

---

## Правила безопасности

<div align="center">

| **Коллекция** | **Чтение** | **Запись** |
|:---|:---|:---|
| `users` | По уровню приватности (public / friends / private) | Только владелец |
| `users/*/friends` | Только владелец | Только владелец |
| `users/*/interests` | Владелец или если `isPublic == true` | Только владелец |
| `communities` | Публичные — всем, приватные — участникам | Только создатель / участник с правами |
| `events` | Публичные — всем, приватные — организатору и участникам | Только организатор (возраст 25+) |
| `events/*/participants` | Участники по eventId | Пользователь, соответствующий minAge события |
| `events/*/reviews` | Всем | Только подтверждённый участник |
| `interests` | Всем | Только администратор |
| `messages` | Только отправитель и получатель | Только отправитель |

</div>

Путь к правилам: `infrastructure/firebase/firestore.rules`.
Путь к индексам: `infrastructure/firebase/firestore.indexes.json`.

---

## Правила изменений схемы

- добавление новых полей должно быть обратно совместимым;
- изменение уровней приватности и ролей согласуется с Security Rules;
- новые составные запросы требуют соответствующего индекса в `firestore.indexes.json`;
- удаление коллекций или полей согласуется в PR перед применением в production.
