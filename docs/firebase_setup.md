# Настройка Firebase для HobbyHub

## Шаг 1: Создание Firebase проекта

1. Перейдите в [Firebase Console](https://console.firebase.google.com/)
2. Нажмите "Add project" (Создать проект)
3. Введите название проекта: `hobbyhub-dev` (или другое на ваш выбор)
4. Включите Google Analytics (опционально, но рекомендуется)
5. Нажмите "Create project"

## Шаг 2: Включение необходимых сервисов

### Authentication
1. В боковом меню выберите "Authentication"
2. Нажмите "Get started"
3. Включите провайдеры:
   - **Email/Password** - включить
   - **Google** - включить (потребуется настройка OAuth)
   - **Apple** - включить (для iOS, потребуется Apple Developer Account)

### Firestore Database
1. В боковом меню выберите "Firestore Database"
2. Нажмите "Create database"
3. Выберите режим:
   - **Test mode** - для разработки (данные открыты 30 дней)
   - **Production mode** - для продакшна (настройте security rules)
4. Выберите регион (например, europe-west1)

### Storage
1. В боковом меню выберите "Storage"
2. Нажмите "Get started"
3. Выберите правила безопасности (можно оставить default)
4. Выберите регион

### Cloud Messaging
1. Автоматически доступно после создания проекта
2. Дополнительные настройки не требуются на этом этапе

### Analytics
1. Если вы включили Analytics при создании проекта - всё готово
2. Если нет - в боковом меню выберите "Analytics" и включите

## Шаг 3: Регистрация приложений

### Android

1. В Project Overview нажмите значок Android
2. Введите Android package name: `com.example.hobby_hub` (должен совпадать с applicationId в android/app/build.gradle)
3. Введите App nickname (опционально): `HobbyHub Android`
4. Введите SHA-1 certificate fingerprint (опционально, но нужен для Google Sign-In)
5. Нажмите "Register app"
6. **Скачайте `google-services.json`**
7. Поместите файл в `android/app/google-services.json`

#### Получить SHA-1 fingerprint:
```bash
cd android
./gradlew signingReport
```

### iOS

1. В Project Overview нажмите значок iOS
2. Введите iOS bundle ID: `com.example.hobbyHub` (должен совпадать с Bundle Identifier в Xcode)
3. Введите App nickname (опционально): `HobbyHub iOS`
4. Введите App Store ID (опционально)
5. Нажмите "Register app"
6. **Скачайте `GoogleService-Info.plist`**
7. Откройте проект в Xcode: `open ios/Runner.xcworkspace`
8. Перетащите `GoogleService-Info.plist` в папку Runner в Xcode (выберите "Copy items if needed")

### Web

1. В Project Overview нажмите значок Web
2. Введите App nickname: `HobbyHub Web`
3. Нажмите "Register app"
4. Скопируйте конфигурацию (apiKey, authDomain, etc.)
5. Эти данные нужно добавить в `lib/firebase_options.dart` (см. Шаг 4)

### macOS

1. В Project Overview нажмите значок macOS
2. Введите macOS bundle ID: `com.example.hobbyHub`
3. Следуйте инструкциям (аналогично iOS)

## Шаг 4: Автоматическая конфигурация с FlutterFire CLI

Вместо ручной настройки можно использовать FlutterFire CLI:

```bash
# Установить FlutterFire CLI
dart pub global activate flutterfire_cli

# Войти в Firebase
firebase login

# Настроить проект
flutterfire configure
```

Эта команда:
- Создаст/обновит `lib/firebase_options.dart`
- Настроит все платформы автоматически
- Добавит необходимые конфигурационные файлы

## Шаг 5: Firestore Security Rules

В Firestore Database → Rules добавьте следующие правила:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && isOwner(userId);
      allow update, delete: if isOwner(userId);
    }
    
    // Events collection
    match /events/{eventId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && 
        resource.data.organizerId == request.auth.uid;
    }
    
    // Communities collection
    match /communities/{communityId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() && 
        resource.data.creatorId == request.auth.uid;
    }
    
    // Interests collection (read-only for users)
    match /interests/{interestId} {
      allow read: if isSignedIn();
      allow write: if false; // Only admins via backend
    }
  }
}
```

## Шаг 6: Storage Security Rules

В Storage → Rules добавьте:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Profile images
    match /profile_images/{userId}/{filename} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId
        && request.resource.size < 10 * 1024 * 1024 // 10MB
        && request.resource.contentType.matches('image/.*');
    }
    
    // Event images
    match /event_images/{eventId}/{filename} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.resource.size < 10 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }
    
    // Community images
    match /community_images/{communityId}/{filename} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.resource.size < 10 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Шаг 7: Проверка установки

Запустите приложение:

```bash
flutter run
```

Если всё настроено правильно, Firebase инициализируется без ошибок.

## Troubleshooting

### Android
- Убедитесь, что `google-services.json` находится в `android/app/`
- Проверьте, что в `android/build.gradle` подключен `google-services` плагин
- SHA-1 fingerprint должен быть добавлен в Firebase Console для Google Sign-In

### iOS
- `GoogleService-Info.plist` должен быть добавлен через Xcode
- Bundle ID должен совпадать в Firebase Console и Xcode
- Для Push-уведомлений нужен APNs certificate

### Web
- Убедитесь, что домен добавлен в Authentication → Settings → Authorized domains

### Общие проблемы
- Очистите проект: `flutter clean && flutter pub get`
- Пересоберите: `flutter run`
- Проверьте версии пакетов в `pubspec.yaml`

## Полезные ссылки

- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire документация](https://firebase.flutter.dev/)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Security Rules](https://firebase.google.com/docs/rules)
