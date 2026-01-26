<div align="center">

## HobbyHub

### Твое хобби — твои правила. Находи единомышленников и создавай встречи.

**Интуитивный интерфейс · Flutter & Firebase · Простота общения**

</div>

---

## Содержание

- [Быстрый запуск для новых разработчиков](#быстрый-запуск-для-новых-разработчиков)
- [Как запустить проект](#как-запустить-проект)
- [Системные требования](#системные-требования)
- [Технологический стек](#технологический-стек)
- [Основные возможности](#основные-возможности)
- [Структура проекта](#структура-проекта)
- [Команды разработки](#команды-разработки)
- [Решение проблем](#решение-проблем)

---

## Быстрый запуск для новых разработчиков

> **Работаешь над проектом впервые? Начни здесь!**

### 1. Клонируйте репозиторий

```bash
git clone <repository-url> hobby_hub
cd hobby_hub
```

### 2. Проверьте установку Flutter

```bash
flutter doctor
```

**Если Flutter не установлен:**
- **macOS/Linux:** Следуйте [официальной документации](https://docs.flutter.dev/get-started/install)
- **Windows:** Загрузите с [flutter.dev](https://flutter.dev)

### 3. Установите зависимости

```bash
flutter pub get
```

### 4. Запуск проекта

**Для iOS (macOS):**
```bash
cd ios
pod install
cd ..
flutter run
```

**Для Android:**
```bash
flutter run
```

**Для Web:**
```bash
flutter run -d chrome
```

**Для macOS:**
```bash
flutter run -d macos
```

### 5. Выберите устройство

Flutter автоматически обнаружит доступные устройства. Выберите нужное из списка.

**Готово!** Приложение запущено и готово к работе.

---

## Быстрый запуск (обычный)

> **Стандартный процесс запуска приложения**

### Способ 1: Режим разработки (Рекомендуется)

```bash
flutter run
```

Hot Reload: нажмите `r` в терминале для быстрой перезагрузки.  
Hot Restart: нажмите `R` для полного перезапуска.

### Способ 2: Режим отладки с конкретным устройством

```bash
# Просмотр доступных устройств
flutter devices

# Запуск на конкретном устройстве
flutter run -d <device_id>
```

### Способ 3: Release режим

```bash
# Android
flutter build apk --release

# iOS
flutter build ipa --release

# Web
flutter build web --release

# macOS
flutter build macos --release
```

<div align="center">

# Документация проекта

---

## Системные требования

| Компонент | Минимум | Рекомендуется | Проверка |
|:---------:|:-------:|:-------------:|:--------:|
| **Flutter SDK** | 3.10+ | 3.24+ | `flutter --version` |
| **Dart SDK** | 3.10+ | 3.5+ | `dart --version` |
| **Xcode** (macOS/iOS) | 14.0+ | 15.0+ | `xcodebuild -version` |
| **Android Studio** | 2022.3+ | 2023.1+ | В настройках IDE |
| **CocoaPods** (iOS) | 1.11+ | 1.15+ | `pod --version` |
| **Git** | 2.0+ | 2.40+ | `git --version` |
| **RAM** | 4 GB | 8 GB+ | — |
| **Диск** | 5 GB | 10 GB+ | Включая SDK и эмуляторы |

---

## Технологический стек

<table align="center">
<tr>
<td width="50%" align="center" valign="top">

### Frontend

Flutter — UI фреймворк  
Dart — язык программирования  
Material Design / Cupertino  
Provider / Riverpod  
Go Router  
Animations

</td>
<td width="50%" align="center" valign="top">

### Backend & Tools

Firebase (опционально)  
Dio / HTTP  
Shared Preferences  
Hive / SQLite  
GetIt (DI)  
Flutter Lints  
Build Runner

</td>
</tr>
</table>

---

## Основные возможности

<table align="center">
<tr>
<td width="50%" align="center" valign="top">

### Главный экран (Home)

**Интуитивная навигация**  
Bottom Navigation Bar

**Адаптивный дизайн**  
Все платформы и экраны

**Быстрый доступ**  
К основным функциям

**Плавные анимации**  
Встроенные возможности

**Темы**  
Темная и светлая

**Производительность**  
60 FPS стабильно

</td>
<td width="50%" align="center" valign="top">

### Аутентификация (Auth)

**Вход и регистрация**  
Формы с валидацией

**Безопасность**  
Шифрование данных

**Social Login**  
Google, Apple ID

**Восстановление**  
Email-подтверждение

**Сессии**  
Автоматический вход

**Биометрия**  
Face ID / Touch ID

</td>
</tr>
<tr>
<td width="50%" align="center" valign="top">

### Карта (Map)

**Интерактивность**  
Отображение локаций

**Геолокация**  
Текущее местоположение

**Кластеризация**  
Удобные маркеры

**Поиск**  
Фильтрация категорий

**Маршруты**  
Навигация к событию

**Офлайн**  
Кеширование карт

</td>
<td width="50%" align="center" valign="top">

### Профиль (Profile)

**Данные**  
Управление профилем

**Избранное**  
Сохраненное контент

**История**  
Активность пользователя

**Настройки**  
Кастомизация

**Уведомления**  
Push-сообщения

**Поддержка**  
Обратная связь

</td>
</tr>
</table>

---

## Архитектурные особенности

| Функция | Описание |
|:---:|:---:|
| **Clean Architecture** | Разделение на слои: UI, Domain, Data |
| **State Management** | Provider/Riverpod для управления состоянием |
| **Dependency Injection** | GetIt для инверсии зависимостей |
| **Responsive Design** | Адаптация под любые размеры экрана |
| **Локализация** | Поддержка множественных языков |
| **Тестирование** | Unit, Widget и Integration тесты |
| **CI/CD** | Автоматизация сборки и деплоя |

</div>

---

## Структура проекта

```
hobby_hub/
├── lib/
│   ├── core/              # Общие штуки: цвета, шрифты, константы API
│   ├── models/            # Все модели данных (Hobby, User, Meeting)
│   ├── services/          # Работа с внешним миром (Firebase, работа с картой)
│   ├── ui/                # Всё, что касается внешнего вида
│   │   ├── auth/          # Экран входа/регистрации
│   │   ├── home/          # Главный экран (лента хобби)
│   │   ├── map/           # Экран с местами встреч
│   │   ├── profile/       # Профиль пользователя
│   │   └── shared/        # Общие виджеты (кнопки, текстовые поля)
│   └── providers/         # Логика управления состоянием (твои ViewModel)
├── test/                         # Тесты
│   └── widget_test/
├── android/                      # Android конфигурация
├── ios/                          # iOS конфигурация
├── macos/                        # macOS конфигурация
├── web/                          # Web конфигурация
├── windows/                      # Windows конфигурация
├── linux/                        # Linux конфигурация
├── pubspec.yaml                  # Зависимости проекта
└── README.md                     # Этот файл
```

---

## Команды разработки

<div align="center">

| Задача | Команда |
|:-------|:--------|
| **Запустить dev сервер** | `flutter run` |
| **Hot Reload** | Нажмите `r` в терминале |
| **Hot Restart** | Нажмите `R` в терминале |
| **Установить зависимости** | `flutter pub get` |
| **Обновить зависимости** | `flutter pub upgrade` |
| **Проверить линтером** | `flutter analyze` |
| **Форматировать код** | `flutter format .` |
| **Запустить тесты** | `flutter test` |
| **Собрать APK (Android)** | `flutter build apk` |
| **Собрать IPA (iOS)** | `flutter build ipa` |
| **Собрать Web** | `flutter build web` |
| **Собрать macOS** | `flutter build macos` |
| **Очистить проект** | `flutter clean` |
| **Проверка системы** | `flutter doctor -v` |
| **Список устройств** | `flutter devices` |
| **Генерация кода** | `flutter pub run build_runner build` |
| **Создать иконку** | `flutter pub run flutter_launcher_icons` |

</div>

---

## Решение проблем

<details>
<summary><b>Обновил код из репозитория, но изменения не применяются</b></summary>

<br>

**Проблема:** После `git pull` новый код не работает, старые ошибки остаются.

**Причина:** Кеш Flutter не обновился, нужна очистка и пересборка.

**Решение:**

```bash
# 1. Остановите приложение
# Нажмите Ctrl+C в терминале или "Stop" в IDE

# 2. Обновите код
git pull origin main

# 3. Очистите кеш
flutter clean

# 4. Обновите зависимости
flutter pub get

# 5. Для iOS - обновите pods
cd ios
pod install
pod update
cd ..

# 6. Перезапустите проект
flutter run
```

**Проверка успешного обновления:**
- Проверьте терминал на наличие ошибок компиляции
- Убедитесь что `pubspec.yaml` корректен
- Выполните `flutter doctor` для проверки среды

</details>

<details>
<summary><b>Flutter приложение не запускается</b></summary>

<br>

```bash
# Проверьте версии
flutter doctor -v
dart --version

# Полная переустановка зависимостей
flutter clean
rm -rf pubspec.lock
flutter pub get

# Для iOS
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# Для Android
cd android
./gradlew clean
cd ..

# Запуск с подробными логами
flutter run -v
```

**Типичные проблемы:**
- `Package not found` → Запустите `flutter pub get`
- `CocoaPods not installed` (iOS) → Установите: `sudo gem install cocoapods`
- `SDK not found` → Проверьте пути в `flutter doctor`
- `Gradle build failed` (Android) → Очистите: `cd android && ./gradlew clean`

</details>

<details>
<summary><b>Проблемы с flutter doctor</b></summary>

<br>

**Проверка состояния системы:**

```bash
flutter doctor -v
```

**Решение распространенных проблем:**

```bash
# Android toolchain - проверьте Android SDK
flutter doctor --android-licenses

# iOS toolchain - установите Xcode (только macOS)
xcode-select --install

# CocoaPods - переустановка (macOS)
sudo gem uninstall cocoapods
sudo gem install cocoapods

# VS Code / Android Studio - установите расширения
# Откройте Extensions и найдите "Flutter" и "Dart"

# Chrome - для Web разработки
# Скачайте с https://www.google.com/chrome/
```

</details>

<details>
<summary><b>Проблемы с iOS (macOS)</b></summary>

<br>

```bash
# Очистка iOS зависимостей
cd ios
rm -rf Pods Podfile.lock .symlinks
pod cache clean --all
pod deintegrate
pod setup
pod install
cd ..

# Проверка версии CocoaPods
pod --version  # Должна быть 1.11+

# Полная очистка Xcode
xcrun simctl erase all  # Очистить симуляторы
rm -rf ~/Library/Developer/Xcode/DerivedData

# Переустановка зависимостей
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

**Типичные проблемы:**
- `pod install` не работает → Обновите: `sudo gem install cocoapods`
- `Architecture mismatch` → Очистите: `rm -rf Pods && pod install`
- `Signing error` → Настройте Team ID в Xcode
- `Module not found` → Запустите `pod install` снова

</details>

<details>
<summary><b>Проблемы с Android</b></summary>

<br>

```bash
# Очистка Android зависимостей
cd android
./gradlew clean
./gradlew cleanBuildCache
cd ..

# Проверка Android SDK
flutter doctor --android-licenses

# Полная очистка Gradle
rm -rf ~/.gradle/caches
cd android
./gradlew clean build --refresh-dependencies
cd ..

# Пересоздание проекта
flutter create --platforms=android .
```

**Типичные проблемы:**
- `Gradle sync failed` → Очистите кеш Gradle
- `SDK not found` → Установите Android SDK через Android Studio
- `Build failed` → Проверьте `android/build.gradle` версии
- `Multidex error` → Добавьте multidex в `android/app/build.gradle`

</details>

<details>
<summary><b>Проблемы с зависимостями</b></summary>

<br>

```bash
# Полная переустановка
flutter clean
rm -rf pubspec.lock
flutter pub get

# Проверка конфликтов
flutter pub outdated
flutter pub deps

# Обновление всех пакетов
flutter pub upgrade

# Решение конфликтов версий
flutter pub upgrade --major-versions

# Для конкретного пакета
flutter pub upgrade package_name
```

**Если возникают конфликты версий:**

Отредактируйте `pubspec.yaml` и укажите совместимые версии:

```yaml
dependencies:
  package_name: ^1.0.0  # Используйте каретку для семантической совместимости
```

</details>

<details>
<summary><b>Проблемы с производительностью</b></summary>

<br>

```bash
# Профилирование приложения
flutter run --profile

# Анализ размера приложения
flutter build apk --analyze-size
flutter build ios --analyze-size

# Оптимизация сборки
flutter build apk --release --shrink
flutter build ios --release

# Проверка памяти
flutter run --profile --trace-skia
```

**Советы по оптимизации:**
- Используйте `const` конструкторы где возможно
- Избегайте пересоздания виджетов в `build()`
- Применяйте `ListView.builder` для длинных списков
- Используйте `RepaintBoundary` для сложных виджетов
- Оптимизируйте изображения (сжатие, кеширование)

</details>

<details>
<summary><b>Проблемы с Hot Reload</b></summary>

<br>

**Hot Reload не работает:**

```bash
# 1. Попробуйте Hot Restart
# Нажмите 'R' в терминале вместо 'r'

# 2. Полностью перезапустите приложение
# Остановите (Ctrl+C) и запустите снова
flutter run

# 3. Очистите и перезапустите
flutter clean
flutter pub get
flutter run
```

**Когда Hot Reload не работает:**
- Изменения в `main()` функции
- Изменения в `initState()`
- Изменения в enum или const значениях
- Изменения в native коде (Android/iOS)
- Добавление новых пакетов

**В этих случаях используйте Hot Restart (R) или полный перезапуск.**

</details>

<details>
<summary><b>Расширенная диагностика</b></summary>

<br>

```bash
# Полная диагностика Flutter окружения
flutter doctor -v

# Проверка устройств
flutter devices -v

# Анализ кода
flutter analyze

# Запуск всех тестов
flutter test

# Проверка зависимостей
flutter pub deps

# Проверка устаревших пакетов
flutter pub outdated

# Логи с подробностями
flutter run -v

# Проверка производительности
flutter run --profile

# Проверка размера приложения
flutter build apk --analyze-size

# Информация о Flutter
flutter --version

# Список всех подключенных устройств
flutter devices

# Обновление Flutter
flutter upgrade

# Переключение на другой канал
flutter channel stable  # или dev, beta
flutter upgrade
```

</details>

---

<div align="center">

**[Вернуться наверх](#hobbyhub)**

</div>
