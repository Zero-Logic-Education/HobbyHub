<div align="center">

# HobbyHub Infrastructure

**Инфраструктурные конфигурации проекта HobbyHub**

[![Firebase](https://img.shields.io/badge/Firebase-Platform-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/)
[![Firestore](https://img.shields.io/badge/Firestore-Security%20Rules-orange?logo=firebase&logoColor=black)](https://firebase.google.com/docs/firestore/security/get-started)
[![Cloud Storage](https://img.shields.io/badge/Cloud%20Storage-Rules-1A73E8?logo=googlecloud&logoColor=white)](https://firebase.google.com/docs/storage/security)

</div>

---

## Содержание

- [Назначение](#назначение)
- [Структура каталогов](#структура-каталогов)
- [Конфигурация](#конфигурация)

---

## Назначение

Папка содержит инфраструктурные артефакты проекта:

- конфигурацию Firebase CLI для проекта и деплоя;
- правила безопасности и индексы для Firestore;
- правила доступа к Cloud Storage;
- настройки Firebase Hosting для web-сборки приложения.

---

## Структура каталогов

<div align="center">

| **Путь** | **Назначение** |
|:---|:---|
| `firebase/firebase.json` | Конфигурация Firebase CLI: сервисы, пути, hosting rewrites |
| `firebase/firestore.rules` | Политики доступа к коллекциям users, communities, events, messages |
| `firebase/firestore.indexes.json` | Составные индексы для Firestore-запросов |
| `firebase/storage.rules` | Правила чтения и записи файлов в Cloud Storage |

</div>

---

## Конфигурация

<div align="center">

| **Сервис** | **Конфиг** | **Что настраивается** |
|:---|:---|:---|
| Firebase CLI | `firebase/firebase.json` | Привязка проекта, пути конфигов, настройки Hosting |
| Firestore Security | `firebase/firestore.rules` | Авторизация, роли, приватность профилей, возрастные ограничения |
| Firestore Indexes | `firebase/firestore.indexes.json` | Индексы для фильтрации и сортировки в сложных выборках |
| Cloud Storage Security | `firebase/storage.rules` | Доступ к медиафайлам пользователей, событий и сообществ |

</div>
