<div align="center">

# HobbyHub Infrastructure

**Инфраструктурные конфигурации проекта HobbyHub**

[![Firebase](https://img.shields.io/badge/Firebase-CLI-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com/docs/cli)
[![Firestore](https://img.shields.io/badge/Firestore-Rules-orange?logo=firebase&logoColor=black)](https://firebase.google.com/docs/firestore/security/get-started)

</div>

---

## Содержание

- [Назначение](#назначение)
- [Структура каталогов](#структура-каталогов)
- [Конфигурация](#конфигурация)

---

## Назначение

Папка содержит инфраструктурные артефакты проекта:

- правила безопасности и индексы Firestore;
- правила доступа к Cloud Storage;
- конфигурацию Firebase-проекта.

---

## Структура каталогов

<div align="center">

| **Путь** | **Назначение** |
|:---|:---|
| `firebase/firebase.json` | Корневая конфигурация Firebase CLI |
| `firebase/firestore.rules` | Правила безопасности Firestore |
| `firebase/firestore.indexes.json` | Составные индексы коллекций Firestore |
| `firebase/storage.rules` | Правила доступа к Cloud Storage |

</div>

---

## Конфигурация

<div align="center">

| **Сервис** | **Конфиг** | **Что настраивается** |
|:---|:---|:---|
| Firestore | `firebase/firestore.rules` | Права доступа к коллекциям users, communities, events, messages |
| Firestore | `firebase/firestore.indexes.json` | Составные индексы для сложных запросов |
| Cloud Storage | `firebase/storage.rules` | Права на чтение / запись файлов |
| Firebase CLI | `firebase/firebase.json` | Цели деплоя и пути к файлам конфигурации |

</div>
