# Схема базы данных HobbyHub

## Обзор

Проект использует Firebase Firestore в качестве основной БД. Структура NoSQL с коллекциями и документами.

## Коллекции

### 1. users
Хранит информацию о пользователях

**Поля:**
- `id` (string) - уникальный идентификатор (Firebase UID)
- `email` (string) - email пользователя
- `username` (string) - уникальное имя пользователя (3-30 символов)
- `displayName` (string?) - отображаемое имя
- `photoUrl` (string?) - URL фотографии профиля
- `bio` (string?) - биография (макс 500 символов)
- `age` (number) - возраст (мин 12 лет)
- `interests` (array<string>) - список ID интересов
- `privacyLevel` (string) - уровень приватности: 'public', 'friends', 'private', 'custom'
- `latitude` (number?) - широта местоположения
- `longitude` (number?) - долгота местоположения
- `isVerified` (boolean) - верифицирован ли пользователь
- `createdAt` (timestamp) - дата создания аккаунта
- `updatedAt` (timestamp?) - дата последнего обновления
- `friends` (array<string>) - список ID друзей
- `eventsAttended` (number) - количество посещенных событий
- `organizerRating` (number) - рейтинг как организатор (0.0-5.0)
- `eventsCreated` (number) - количество созданных событий

**Индексы:**
- username (unique)
- email (unique)
- interests (array)

---

### 2. events
Хранит информацию о событиях

**Поля:**
- `id` (string) - уникальный идентификатор
- `title` (string) - название события (макс 100 символов)
- `description` (string) - описание (макс 2000 символов)
- `organizerId` (string) - ID организатора
- `startTime` (timestamp) - дата и время начала
- `endTime` (timestamp?) - дата и время окончания
- `latitude` (number) - широта местоположения
- `longitude` (number) - долгота местоположения
- `address` (string?) - адрес места проведения
- `coverImageUrl` (string?) - URL обложки
- `categories` (array<string>) - категории/теги
- `participants` (array<string>) - список ID участников
- `maxParticipants` (number) - максимум участников (0 = без ограничений)
- `price` (number) - цена (0 = бесплатно)
- `isFree` (boolean) - бесплатное ли событие
- `visibility` (string) - 'public', 'friends', 'private', 'community'
- `minAge` (number) - минимальный возраст
- `requiresApproval` (boolean) - требуется ли одобрение
- `eventType` (string) - 'single', 'recurring', 'series'
- `createdAt` (timestamp) - дата создания
- `updatedAt` (timestamp?) - дата обновления
- `rating` (number) - рейтинг (0.0-5.0)
- `reviewsCount` (number) - количество отзывов
- `communityId` (string?) - ID сообщества (если применимо)
- `coOrganizers` (array<string>) - ID со-организаторов
- `status` (string) - 'draft', 'published', 'cancelled', 'completed'

**Индексы:**
- organizerId
- startTime
- categories (array)
- status
- communityId
- geopoint (latitude, longitude) - для геозапросов

---

### 3. communities
Хранит информацию о сообществах

**Поля:**
- `id` (string) - уникальный идентификатор
- `name` (string) - название сообщества
- `description` (string) - описание
- `creatorId` (string) - ID создателя
- `coverImageUrl` (string?) - URL обложки
- `logoUrl` (string?) - URL логотипа
- `categories` (array<string>) - категории/интересы
- `members` (array<string>) - список ID участников
- `moderators` (array<string>) - список ID модераторов
- `privacyLevel` (string) - 'public', 'private', 'invite-only'
- `createdAt` (timestamp) - дата создания
- `updatedAt` (timestamp?) - дата обновления
- `eventsCount` (number) - количество событий
- `isVerified` (boolean) - верифицировано ли
- `rules` (string?) - правила сообщества
- `minAge` (number) - минимальный возраст для вступления
- `maxMembers` (number) - максимум участников (0 = без ограничений)
- `requiresApproval` (boolean) - требуется ли одобрение для вступления
- `rating` (number) - рейтинг (0.0-5.0)

**Индексы:**
- creatorId
- categories (array)
- members (array)

---

### 4. interests
Справочник интересов/хобби

**Поля:**
- `id` (string) - уникальный идентификатор
- `name` (string) - название интереса
- `category` (string) - категория (спорт, искусство, музыка, технологии и т.д.)
- `description` (string?) - описание
- `iconUrl` (string?) - URL иконки/изображения
- `usersCount` (number) - количество пользователей с этим интересом
- `relatedInterests` (array<string>) - список ID связанных интересов
- `popularity` (number) - популярность (0-100)
- `isFeatured` (boolean) - рекомендуется ли

**Индексы:**
- category
- popularity

---

## Дополнительные коллекции (для будущего)

### 5. messages
Чаты и сообщения

### 6. reviews
Отзывы на события и организаторов

### 7. reports
Жалобы на пользователей/события/сообщения

### 8. friendships
Связи между пользователями (друзья, подписки)

### 9. notifications
Уведомления пользователей

### 10. activity_history
История активности пользователей

---

## Security Rules

### Правила доступа Firestore:

**users:**
- Чтение: публичные поля доступны всем, приватные - только владельцу и друзьям
- Запись: только владелец может изменять свой профиль
- Создание: только при аутентификации

**events:**
- Чтение: в зависимости от visibility
- Запись: только организатор и со-организаторы
- Создание: только пользователи 25+ лет
- Удаление: только организатор

**communities:**
- Чтение: в зависимости от privacyLevel
- Запись: только создатель и модераторы
- Создание: только пользователи 25+ лет

**interests:**
- Чтение: все аутентифицированные пользователи
- Запись: только администраторы

---

## Связи между коллекциями

```
User (1) ---> (*) Events (как организатор)
User (*) ---> (*) Events (как участник)
User (*) ---> (*) Communities (как участник)
User (1) ---> (*) Communities (как создатель)
User (*) ---> (*) Interests
Community (1) ---> (*) Events
Event (*) ---> (*) Categories/Interests
```

---

## Примеры запросов

### Найти события рядом с пользователем:
```dart
FirebaseFirestore.instance
  .collection('events')
  .where('latitude', isGreaterThan: userLat - 0.5)
  .where('latitude', isLessThan: userLat + 0.5)
  .where('status', isEqualTo: 'published')
  .orderBy('startTime')
  .limit(20)
```

### Найти события по интересам пользователя:
```dart
FirebaseFirestore.instance
  .collection('events')
  .where('categories', arrayContainsAny: userInterests)
  .where('startTime', isGreaterThan: DateTime.now())
  .orderBy('startTime')
  .limit(20)
```

### Получить сообщества пользователя:
```dart
FirebaseFirestore.instance
  .collection('communities')
  .where('members', arrayContains: userId)
  .orderBy('name')
```
