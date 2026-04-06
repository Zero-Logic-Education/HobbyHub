# HobbyHub Comprehensive Issue Analysis & Resolution Plan

## Executive Summary

This document provides a complete analysis of the HobbyHub Flutter application, identifying all non-working functions, their root causes, and a phased resolution plan to ensure UI/UX consistency and feature completeness.

**Current Completion**: ~68%  
**Critical Issues**: 8  
**High Priority Issues**: 12  
**Medium Priority Issues**: 15  
**Low Priority Issues**: 10  

---

## Table of Contents

1. [Critical Syntax & Compilation Errors](#1-critical-syntax--compilation-errors)
2. [Platform Configuration Issues](#2-platform-configuration-issues)
3. [Routing & Navigation System Issues](#3-routing--navigation-system-issues)
4. [Non-Working UI Features](#4-non-working-ui-features)
5. [Firebase-Dependent Features Requiring User Notifications](#5-firebase-dependent-features-requiring-user-notifications)
6. [Incomplete Screen Implementations](#6-incomplete-screen-implementations)
7. [UI/UX Inconsistencies](#7-uiux-inconsistencies)
8. [Unused Providers & Dead Code](#8-unused-providers--dead-code)
9. [Phased Implementation Plan](#9-phased-implementation-plan)

---

## 1. Critical Syntax & Compilation Errors

### 1.1 AnalyticsService Syntax Error

**Severity**: CRITICAL - Blocks app compilation  
**File**: `apps/lib/services/firebase/analytics_service.dart`  
**Lines**: 72, 117, 156

**Issue**: Invalid Dart syntax `'category': ?category` in three methods:
- `logCreateEvent()` (line 72)
- `logSearch()` (line 117)
- `logSendMessage()` (line 156)

**Root Cause**: Incorrect attempt at optional parameter syntax

**Fix**:
```dart
// Line 72 - Change from:
'category': ?category,
// To:
if (category != null) 'category': category,

// Line 117 - Change from:
'category': ?category,
// To:
if (category != null) 'category': category,

// Line 156 - Change from:
'chat_id': ?chatId,
// To:
if (chatId != null) 'chat_id': chatId,
```

---

## 2. Platform Configuration Issues

### 2.1 iOS Missing Location Permissions

**Severity**: CRITICAL - App crashes on iOS  
**File**: `apps/ios/Runner/Info.plist`

**Issue**: Missing required location usage description keys. iOS will crash or silently deny location requests.

**Missing Keys**:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>HobbyHub uses your location to find events and communities near you</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>HobbyHub needs location access to notify you about nearby events even when the app is in background</string>
```

**Impact**: 
- `Geolocator.requestPermission()` will fail
- Location onboarding screen will crash
- Map features will not work
- App Store will reject binary

### 2.2 Android Missing Location Permissions

**Severity**: CRITICAL - Geolocation fails on Android  
**File**: `apps/android/app/src/main/AndroidManifest.xml`

**Issue**: Missing location permission declarations in `<manifest>` section (before `<application>`)

**Missing Permissions**:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**Impact**:
- All geolocation features fail
- "Use current location" button in event creation fails
- Location onboarding screen fails

### 2.3 Google Maps API Key Not Configured

**Severity**: CRITICAL - Maps display broken  
**Files**: 
- `apps/android/app/src/main/AndroidManifest.xml`
- `apps/ios/Runner/AppDelegate.swift`

**Issue**: No Google Maps API key configured for either platform

**Fix Android** (in AndroidManifest.xml, inside `<application>`):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE" />
```

**Fix iOS** (in AppDelegate.swift, before `GeneratedPluginRegistrant.register(with: self)`):
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

**Impact**:
- MapScreen shows blank tiles or error overlay
- Event location visualization broken
- Map-based search non-functional

### 2.4 Firebase Background Message Handler Not Registered

**Severity**: HIGH - Background push notifications don't work  
**File**: `apps/lib/main.dart`

**Issue**: `firebaseMessagingBackgroundHandler` is defined in `messaging_service.dart` but never registered in `main.dart`

**Fix** (add in `main.dart` before `runApp()`):
```dart
FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
```

**Impact**:
- Background push notifications not received
- Users don't get notified about messages or events when app is closed

---

## 3. Routing & Navigation System Issues

### 3.1 Missing Route Registrations

**Severity**: HIGH - Screens unreachable via router  
**File**: `apps/lib/core/router/app_router.dart`

**Screens NOT registered in GoRouter**:

| Screen | Required Route | Current Access Method |
|--------|---------------|----------------------|
| `EventDetailScreen` | `/home/event/:id` | `Navigator.push` only |
| `ChatListScreen` | `/chats` | `Navigator.push` only |
| `ChatScreen` | `/chats/:id` | `Navigator.push` only |
| `NotificationsScreen` | `/notifications` | `Navigator.push` only |
| `MapScreen` | `/map` | `Navigator.push` only |
| `SettingsScreen` | `/settings` | `Navigator.push` only |
| `EventModerationScreen` | `/events/:id/moderation` | Nowhere (dead code) |
| `EventReviewScreen` | `/events/:id/review` | Nowhere (dead code) |
| `EventReviewsListScreen` | `/events/:id/reviews` | Nowhere (dead code) |

**Root Cause**: Inconsistent navigation pattern mixing - some screens use `Navigator.push`, some use `context.push()`, some use navigation helpers

### 3.2 Broken Navigation Helpers

**Severity**: HIGH - Runtime crashes when using helpers  
**File**: `apps/lib/core/router/navigation_helper.dart`

**Broken Methods**:

1. **`goEventDetail()`** (line 61):
   ```dart
   // Generates: /home/event/123 - ROUTE DOESN'T EXIST
   context.push('${AppRoutes.home}/event/$eventId');
   ```

2. **`goCreateEvent()`** (line 66):
   ```dart
   // Generates: /home/create-event - ROUTE DOESN'T EXIST
   context.push('${AppRoutes.home}/create-event');
   ```

3. **`goChats()`** (line 71):
   ```dart
   // Generates: /home/chats - ROUTE DOESN'T EXIST
   context.push('${AppRoutes.home}/chats');
   ```

4. **`goChatDetail()`** (line 76):
   ```dart
   // Generates: /home/chats/123 - ROUTE DOESN'T EXIST
   context.push('${AppRoutes.home}/chats/$chatId');
   ```

**Same issues in**: `apps/lib/core/router/router_extensions.dart` (lines 31, 34, 42)

### 3.3 Wrong Route Path in Communities Screen

**Severity**: MEDIUM - Community detail navigation fails  
**File**: `apps/lib/ui/communities/communities_screen.dart` (line 185)

**Issue**:
```dart
// Uses: /communities/detail/123
context.push('/communities/detail/${item.id}');

// But registered route is: /communities/:id
// Should be:
context.push('/communities/${item.id}');
```

### 3.4 DeepLinkHandler Generates Invalid Routes

**Severity**: MEDIUM - Deep links don't work  
**File**: `apps/lib/core/router/navigation_config.dart` (lines 96-122)

**Issue**: All generated deep links are invalid:
```dart
// Generates: /home/event/123 - DOESN'T EXIST
'${AppRoutes.home}/event/${path[1]}'

// Generates: /home/communities/456 - SHOULD BE /communities/456
'${AppRoutes.home}/communities/${path[1]}'

// Generates: /home/chats/789 - DOESN'T EXIST
'${AppRoutes.home}/chats/${path[1]}'
```

---

## 4. Non-Working UI Features

### 4.1 Event Detail Screen - Stubbed Actions

**Severity**: HIGH - Core features non-functional  
**File**: `apps/lib/ui/home/event_detail_screen.dart`

**Non-Working Buttons**:

| Button | Line | Issue | Required Fix |
|--------|------|-------|--------------|
| "Присоединиться" (Join) | ~255 | `onPressed: () {}` | Connect to `eventParticipationProvider` |
| "Показать на карте" (Show on Map) | ~215 | `onPressed: () {}` | Navigate to MapScreen with event location |
| "Смотреть всех" (View All Attendees) | ~323 | `onPressed: () {}` | Navigate to attendees list screen |
| Share button | ~91 | `onPressed: () {}` | Implement share functionality |
| Chat with organizer | ~318 | Comment: "Not passing actual creator logic yet" | Fetch organizer profile, start chat |

**Additional Issues**:
- Screen is `StatelessWidget`, cannot access Riverpod providers
- Must convert to `ConsumerWidget` to use providers
- Organizer hardcoded as "Команда HobbyHub" (line 300-320)
- Attendee avatars are placeholder images from pravatar.cc

### 4.2 Home Screen Issues

**Severity**: MEDIUM  
**File**: `apps/lib/ui/home/home_screen.dart`

**Issues**:

1. **"Исследовать" (Discover) button** (line 210):
   ```dart
   ElevatedButton(
     onPressed: () {}, // EMPTY - does nothing
     child: Text('Исследовать'),
   )
   ```

2. **Participant avatars hardcoded** (lines 595-625):
   - Three static colored circles instead of real participants
   - No actual participant data displayed

3. **Time-insensitive greeting**:
   - Always says "Доброе утро" regardless of actual time
   - Should be time-aware (morning/afternoon/evening)

### 4.3 Profile Screen Issues

**Severity**: MEDIUM  
**File**: `apps/lib/ui/profile/profile_screen.dart`

**Issues**:

| Feature | Line | Problem | Fix Required |
|---------|------|---------|--------------|
| Followers count | ~272 | Hardcoded to '0' | Create followers provider |
| Events tab | 340-354 | Always shows "Нет событий" | Display `userEvents` data |
| Settings tiles | Multiple | `onTap` handlers missing | Implement navigation to settings screens |
| Settings navigation | Multiple | Uses `Navigator.push` | Convert to `context.push()` |

### 4.4 Communities Screen - Discover Tab Stub

**Severity**: MEDIUM  
**File**: `apps/lib/ui/communities/communities_screen.dart`

**Issue**: `_buildDiscover()` method (line 141) is completely stubbed:
```dart
Widget _buildDiscover() {
  return const Center(
    child: Text('Найти сообщества'), // Just placeholder text
  );
}
```

**Fix**: Should display `allCommunitiesProvider` data with search/filter capability

### 4.5 Notifications Screen - No Navigation on Tap

**Severity**: MEDIUM  
**File**: `apps/lib/ui/notifications/notifications_screen.dart`

**Issue**: Tapping a notification only marks it as read but doesn't navigate to related content (event, chat, community)

**Expected Behavior**:
- Event notification → Navigate to EventDetailScreen
- Message notification → Navigate to ChatScreen
- Community notification → Navigate to CommunityDetailScreen

---

## 5. Firebase-Dependent Features Requiring User Notifications

The following features depend on Firebase services that may not be available in all environments or may fail silently. Each should display a user-friendly notification when unavailable.

### 5.1 Firebase Storage Features

**Affected Features**:
- Profile image upload/edit
- Event cover image upload
- Event gallery images upload
- Community cover image upload

**User Notification Required**:
```dart
// When Firebase Storage fails or is unavailable:
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text(
      'Загрузка изображений временно недоступна. '
      'Пожалуйста, попробуйте позже.',
    ),
    backgroundColor: Colors.orange,
  ),
);
```

### 5.2 Geolocation & Maps Features

**Affected Features**:
- Location permission screen (onboarding)
- "Use current location" in event creation
- Map screen with event markers
- Location-based event search
- Address geocoding

**User Notification Required**:
```dart
// When geolocation permission denied or fails:
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text(
      'Геолокация недоступна. Функции карты и поиска рядом '
      'временно не работают. Проверьте настройки разрешений.',
    ),
    backgroundColor: Colors.orange,
  ),
);

// When Google Maps API key is missing:
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text(
      'Карты временно недоступны. Пожалуйста, попробуйте позже.',
    ),
    backgroundColor: Colors.orange,
  ),
);
```

### 5.3 Firebase Cloud Messaging (Push Notifications)

**Affected Features**:
- Push notification receipt
- Topic subscriptions (events, communities, categories)
- Background message handling

**User Notification Required**:
```dart
// When FCM permission denied:
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text(
      'Push-уведомления отключены. Вы не будете получать '
      'уведомления о новых сообщениях и событиях.',
    ),
    backgroundColor: Colors.orange,
    duration: Duration(seconds: 5),
    action: SnackBarAction(
      label: 'Включить',
      onPressed: /* Open app settings */,
    ),
  ),
);
```

### 5.4 Firebase Analytics

**Affected Features**:
- Screen view tracking
- Event logging (login, signup, create event, join event, etc.)
- User property tracking

**User Notification Required**:
```dart
// Analytics should fail silently - NO user notification needed
// Just log error in debug mode
if (kDebugMode) {
  print('Analytics error: $error');
}
```

### 5.5 Real-time Chat

**Affected Features**:
- Chat list loading
- Message sending/receiving
- Real-time message streaming

**User Notification Required**:
```dart
// When Firestore connection fails for chat:
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text(
      'Нет подключения к интернету. Сообщения будут '
      'отправлены при восстановлении соединения.',
    ),
    backgroundColor: Colors.orange,
  ),
);
```

---

## 6. Incomplete Screen Implementations

### 6.1 Event Moderation Screen

**Status**: DEAD CODE - Completely unreachable  
**File**: `apps/lib/ui/home/moderation/event_moderation_screen.dart`  
**Issue**: No route registered, no imports from other files, no navigation to it

**Required for**: Events with `requiresApproval` flag where organizers review participant applications

### 6.2 Event Review Screen

**Status**: DEAD CODE - Completely unreachable  
**File**: `apps/lib/ui/home/reviews/event_review_screen.dart`  
**Issue**: No route registered, no imports from other files

**Required for**: Submitting reviews and ratings (1-5 stars) after events complete

### 6.3 Event Reviews List Screen

**Status**: DEAD CODE - Completely unreachable  
**File**: `apps/lib/ui/home/reviews/event_reviews_list_screen.dart`  
**Issue**: No route registered, no imports from other files  
**Additional**: Uses `FirebaseFirestore.instance` directly instead of through service layer

**Required for**: Displaying all reviews for an event

---

## 7. UI/UX Inconsistencies

### 7.1 Navigation Pattern Mixing

**Severity**: MEDIUM - Breaks back button, deep linking, and state management

**Issue**: App uses GoRouter but 6+ screens bypass it with `Navigator.push()`:

| Screen | Navigation Method | Should Use |
|--------|------------------|------------|
| EventDetailScreen | `Navigator.push(MaterialPageRoute)` | `context.push()` |
| ChatListScreen | `Navigator.push(MaterialPageRoute)` | `context.push()` |
| NotificationsScreen | `Navigator.push(MaterialPageRoute)` | `context.push()` |
| MapScreen | `Navigator.push(MaterialPageRoute)` | `context.push()` |
| SettingsScreen | `Navigator.push(MaterialPageRoute)` | `context.push()` |
| ChatScreen | `Navigator.push(MaterialPageRoute)` | `context.push()` |

**Impact**:
- Browser back button unreliable
- Deep linking broken for these screens
- StatefulShellRoute indexedStack doesn't preserve tab state
- Auth bypass guards not triggered

### 7.2 Event Card Inconsistency

**Severity**: LOW - Visual inconsistency

**Issue**: Two different event card implementations:

1. **HomeScreen `_EventCard`** (private):
   - Custom implementation with inline styles
   - Image height: 150px
   - Different border radius
   - Different layout structure

2. **Shared `EventCard`** (in `ui/shared/event_card.dart`):
   - Reusable component
   - Used by SearchScreen
   - Different styling and layout

**Fix**: Consolidate to single shared component

### 7.3 Category Color Mismatch

**Severity**: LOW - Visual inconsistency

**Issue**: Three different category color functions with different key sets:

| File | Keys Used | Colors Used |
|------|-----------|-------------|
| `home_screen.dart` | 'спорт', 'технологии', etc. + English | Palette A |
| `event_detail_screen.dart` | Different set | Palette B |
| `communities_screen.dart` | Russian only ('здоровье', 'творчество') | Palette C |

**Fix**: Extract to shared utility with consistent key set and color palette

### 7.4 AppBar Inconsistency

**Severity**: LOW - Visual inconsistency

**Issue**: Three different header patterns:

1. **Custom header rows** (no AppBar): HomeScreen, ProfileScreen, CommunitiesScreen
2. **Standard AppBar**: ChatListScreen, NotificationsScreen, ChatScreen
3. **SliverAppBar**: EventDetailScreen

**Fix**: Standardize on single pattern (preferably CustomAppBar from shared widgets)

### 7.5 Duplicated `_formatPrice` Method

**Severity**: LOW - Code duplication

**Issue**: Same method exists in:
- `home_screen.dart`
- `event_detail_screen.dart`

**Fix**: Extract to shared utility in `lib/core/utils/` or add to `AppConstants`

---

## 8. Unused Providers & Dead Code

### 8.1 Unused UI Providers

**Severity**: LOW - Dead code weight

**File**: `apps/lib/providers/ui_provider.dart`

**Providers defined but NEVER consumed by any UI screen**:
- `navigationProvider` (navigation state)
- `loadingProvider` (global loading indicator)
- `toastProvider` (toast messages)
- `filterVisibilityProvider` (filter UI visibility)

**Only `themeProvider` is actively used** (in main.dart)

**Recommendation**: Either integrate these providers into UI screens or remove them

### 8.2 Incomplete Barrel Export

**File**: `apps/lib/providers/providers.dart`

**Missing exports**:
- `chat_providers.dart`
- `community_provider.dart`
- `notification_provider.dart`
- `error_observer.dart`

**Impact**: Screens must import these individually instead of single import

### 8.3 Placeholder Image URL

**File**: `apps/lib/ui/communities/communities_screen.dart` (line 211)

**Issue**: Falls back to external placeholder:
```dart
coverImageUrl ?? 'https://via.placeholder.com/800x400?text=${item.name}'
```

**Fix**: Use local asset or gradient placeholder

---

## 9. Phased Implementation Plan

This plan is organized to minimize UI/UX breakage and ensure consistent user experience throughout development.

---

### Phase 1: Critical Fixes (Unblock Development)

**Goal**: Fix compilation errors and platform configuration  
**Estimated Impact**: App won't build or crashes on launch without these

#### Tasks:

1. **Fix AnalyticsService syntax errors**
   - File: `apps/lib/services/firebase/analytics_service.dart`
   - Changes: Lines 72, 117, 156 - fix optional parameter syntax
   - Risk: None - pure syntax fix
   - UI/UX Impact: None

2. **Add iOS location permissions**
   - File: `apps/ios/Runner/Info.plist`
   - Add: `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`
   - Risk: None - required by Apple
   - UI/UX Impact: Enables location features on iOS

3. **Add Android location permissions**
   - File: `apps/android/app/src/main/AndroidManifest.xml`
   - Add: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
   - Risk: None - required by Android
   - UI/UX Impact: Enables location features on Android

4. **Configure Google Maps API keys**
   - Files: Android Manifest.xml, iOS AppDelegate.swift
   - Action: Add API keys for both platforms
   - Risk: Low - requires API key generation
   - UI/UX Impact: Enables map display
   - **Add user notification for when API key is missing or invalid**

5. **Register Firebase background message handler**
   - File: `apps/lib/main.dart`
   - Add: `FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler)`
   - Risk: None
   - UI/UX Impact: Enables background push notifications

#### Deliverables:
- ✅ App compiles without errors
- ✅ Location features work on both platforms
- ✅ Maps display correctly
- ✅ Background push notifications work
- ✅ User notifications for unavailable Firebase features

---

### Phase 2: Routing System Overhaul

**Goal**: Centralize all navigation through GoRouter  
**UI/UX Impact**: Enables deep linking, proper back navigation, consistent state management

#### Tasks:

1. **Register all missing routes**
   - File: `apps/lib/core/router/app_router.dart`
   - Add routes for:
     ```dart
     GoRoute(
       path: '/home/event/:id',
       parent: homeRoute,
       builder: (context, state) => EventDetailScreen(eventId: state.pathParameters['id']!),
     ),
     GoRoute(
       path: '/chats',
       builder: (context, state) => const ChatListScreen(),
     ),
     GoRoute(
       path: '/chats/:id',
       builder: (context, state) => ChatScreen(chatId: state.pathParameters['id']!),
     ),
     GoRoute(
       path: '/notifications',
       builder: (context, state) => const NotificationsScreen(),
     ),
     GoRoute(
       path: '/map',
       builder: (context, state) => const MapScreen(),
     ),
     GoRoute(
       path: '/settings',
       builder: (context, state) => const SettingsScreen(),
     ),
     // Moderation & Reviews (for future use)
     GoRoute(
       path: '/events/:id/moderation',
       builder: (context, state) => EventModerationScreen(eventId: state.pathParameters['id']!),
     ),
     GoRoute(
       path: '/events/:id/review',
       builder: (context, state) => EventReviewScreen(eventId: state.pathParameters['id']!),
     ),
     GoRoute(
       path: '/events/:id/reviews',
       builder: (context, state) => EventReviewsListScreen(eventId: state.pathParameters['id']!),
     ),
     ```

2. **Fix navigation helpers**
   - Files: `navigation_helper.dart`, `router_extensions.dart`
   - Update all methods to use correct routes:
     ```dart
     // navigation_helper.dart
     static void goEventDetail(BuildContext context, String eventId) {
       context.push('/home/event/$eventId'); // Now valid route
     }
     
     static void goCreateEvent(BuildContext context) {
       context.push('/create'); // Correct route
     }
     
     static void goChats(BuildContext context) {
       context.push('/chats'); // Now valid route
     }
     ```

3. **Replace all Navigator.push with context.push**
   - Files: home_screen.dart, profile_screen.dart, etc.
   - Replace:
     ```dart
     // Before:
     Navigator.push(
       context,
       MaterialPageRoute(builder: (_) => const ChatListScreen()),
     );
     
     // After:
     context.push('/chats');
     ```

4. **Fix community detail route mismatch**
   - File: `communities_screen.dart` (line 185)
   - Change: `/communities/detail/${item.id}` → `/communities/${item.id}`

5. **Fix DeepLinkHandler**
   - File: `navigation_config.dart`
   - Update all generated routes to match actual registered routes

#### Deliverables:
- ✅ All screens accessible via GoRouter
- ✅ Navigation helpers work correctly
- ✅ Deep links resolve to valid routes
- ✅ Back button works consistently
- ✅ Auth guards apply to all routes
- ⚠️ **UI/UX Note**: Users may notice smoother transitions and proper back navigation

---

### Phase 3: Complete Event Detail Screen

**Goal**: Make EventDetailScreen fully functional  
**UI/UX Impact**: High - this is a core user flow

#### Tasks:

1. **Convert to ConsumerWidget**
   - Change: `StatelessWidget` → `ConsumerWidget`
   - Enable access to Riverpod providers

2. **Implement "Join" button**
   - Connect to `eventParticipationProvider`
   - Add loading state during toggle
   - Show success/error toast
   - Update participant count on success

3. **Implement "Show on Map" button**
   - Navigate to MapScreen centered on event location
   - Pass event coordinates to map
   - Add user notification if map unavailable:
     ```dart
     if (event.latitude == 0 && event.longitude == 0) {
       // Show notification
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text('Карта для этого события недоступна.'),
         ),
       );
       return;
     }
     ```

4. **Implement "View All Attendees" button**
   - Create attendees list screen or bottom sheet
   - Display real participant profiles
   - Show avatars/initials from Firestore

5. **Implement Share button**
   - Use `share_plus` package
   - Share event title, date, location, description
   - Add user notification if sharing fails

6. **Fetch real organizer profile**
   - Use `userProfileProvider(event.organizerId)`
   - Replace hardcoded "Команда HobbyHub"
   - Display organizer name and avatar
   - Implement "Chat with organizer" button:
     - Check if chat exists
     - Create chat if needed
     - Navigate to ChatScreen
     - Add user notification if chat unavailable

7. **Replace attendee placeholder avatars**
   - Fetch actual participant profiles from Firestore
   - Display real avatars or initials
   - Show up to 5-10 avatars with "+X more" indicator

#### Deliverables:
- ✅ Users can join/leave events
- ✅ Map shows event location
- ✅ Attendees list displays real users
- ✅ Organizer profile is real data
- ✅ Share functionality works
- ✅ Chat with organizer works
- ⚠️ **UI/UX Note**: Add loading states for all async operations to prevent UI jumps

---

### Phase 4: Complete Profile & Settings Screens

**Goal**: Remove all hardcoded profile data, make settings functional  
**UI/UX Impact**: Medium - users interact frequently

#### Tasks:

1. **Implement real followers count**
   - Create `followersProvider` to count user's followers
   - Replace hardcoded '0' with real count
   - Add tap handler to view followers list

2. **Fix Events tab**
   - Display `userEvents` data in list format
   - Show event cards with proper loading state
   - Handle empty state with helpful message

3. **Implement Settings tiles**
   - Add `onTap` handlers to all tiles:
     - "Уведомления" → Notification settings screen
     - "Конфиденциальность" → Privacy settings screen
     - "Оценить приложение" → Open app store rating
   - Add navigation routes for settings screens

4. **Standardize settings navigation**
   - Replace all `Navigator.push` with `context.push()`
   - Register settings routes in GoRouter

5. **Add Firebase Storage user notification**
   - When avatar upload fails:
     ```dart
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
         content: Text('Загрузка фото недоступна. Попробуйте позже.'),
         backgroundColor: Colors.orange,
       ),
     );
     ```

#### Deliverables:
- ✅ Followers count shows real data
- ✅ Events tab displays user's events
- ✅ All settings tiles are tappable
- ✅ Settings screens accessible
- ⚠️ **UI/UX Note**: Maintain consistent settings screen design pattern

---

### Phase 5: Complete Communities Screen

**Goal**: Implement Discover tab, fix category colors  
**UI/UX Impact**: Medium - key social feature

#### Tasks:

1. **Implement Discover tab**
   - Replace stub in `_buildDiscover()`
   - Use `allCommunitiesProvider` to fetch communities
   - Add search bar for community names
   - Add category filter dropdown
   - Display community cards with:
     - Cover image
     - Name and description
     - Member count
     - Join button
   - Add loading and error states

2. **Fix category color inconsistency**
   - Create shared utility: `lib/core/utils/category_colors.dart`
   - Define consistent category keys (English preferred):
     ```dart
     const Map<String, Color> categoryColors = {
       'sports': Color(0xFFFF5722),
       'tech': Color(0xFF2196F3),
       'arts': Color(0xFF9C27B0),
       'music': Color(0xFFFF9800),
       'health': Color(0xFF4CAF50),
       'gaming': Color(0xFF607D8B),
       'cooking': Color(0xFF795548),
       'travel': Color(0xFF00BCD4),
     };
     ```
   - Use this utility in: home_screen.dart, event_detail_screen.dart, communities_screen.dart, search_screen.dart

3. **Fix placeholder image URL**
   - Replace external placeholder with local asset or gradient:
     ```dart
     coverImageUrl ?? null, // Show gradient placeholder instead
     
     // In build:
     if (coverImageUrl != null)
       CachedNetworkImage(imageUrl: coverImageUrl)
     else
       Container(
         decoration: BoxDecoration(
           gradient: LinearGradient(
             colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
           ),
         ),
         child: Center(
           child: Text(item.name[0].toUpperCase()),
         ),
       ),
     ```

#### Deliverables:
- ✅ Discover tab shows all communities
- ✅ Users can search and join communities
- ✅ Category colors consistent across app
- ✅ No external placeholder URLs
- ⚠️ **UI/UX Note**: Discover tab should match "My Groups" tab styling

---

### Phase 6: Complete Home Screen & Event Cards

**Goal**: Fix stubbed buttons, unify event cards  
**UI/UX Impact**: High - primary user entry point

#### Tasks:

1. **Implement "Discover" button**
   - Navigate to SearchScreen or MapScreen
   - Or show curated list of trending events

2. **Implement time-aware greeting**
   - Replace hardcoded "Доброе утро" with:
     ```dart
     String getTimeGreeting() {
       final hour = DateTime.now().hour;
       if (hour < 6) return 'Доброй ночи';
       if (hour < 12) return 'Доброе утро';
       if (hour < 18) return 'Добрый день';
       return 'Добрый вечер';
     }
     ```

3. **Replace participant avatars with real data**
   - Fetch event participants from Firestore
   - Show actual avatars/initials
   - Display up to 3-4 with "+X more" indicator

4. **Consolidate EventCard implementations**
   - Extract home_screen's `_EventCard` to use shared `EventCard` component
   - Or enhance shared component to support both use cases
   - Ensure consistent styling:
     - Image height
     - Border radius
     - Spacing
     - Typography

5. **Add retry mechanism for errors**
   - When events fail to load, show retry button:
     ```dart
     ElevatedButton.icon(
       onPressed: () => ref.invalidate(eventsStreamProvider),
       icon: const Icon(Icons.refresh),
       label: const Text('Повторить'),
     )
     ```

#### Deliverables:
- ✅ "Discover" button functional
- ✅ Greeting changes with time of day
- ✅ Real participant avatars on cards
- ✅ Single EventCard component used everywhere
- ✅ Error states have retry buttons
- ⚠️ **UI/UX Note**: Card redesign should maintain current visual appeal

---

### Phase 7: Complete Notifications & Chat Features

**Goal**: Make notifications navigate to content, enhance chat UX  
**UI/UX Impact**: Medium - daily active features

#### Tasks:

1. **Implement notification tap navigation**
   - Based on `notificationType`:
     ```dart
     onTap: () {
       firestoreService.markNotificationAsRead(notification.id);
       switch (notification.type) {
         case 'event':
           context.push('/home/event/${notification.relatedId}');
           break;
         case 'message':
           context.push('/chats/${notification.relatedId}');
           break;
         case 'community':
           context.push('/communities/${notification.relatedId}');
           break;
       }
     },
     ```

2. **Add unread message count badge to chats**
   - Extend Chat model with `unreadCount` field
   - Update chat_service.dart to track unread messages
   - Display badge on ChatListScreen tiles

3. **Improve chat list loading UX**
   - Replace "Загрузка..." with skeleton loader or shimmer
   - Show cached chat data while refreshing

4. **Add search functionality to chat list**
   - Search bar to filter chats by participant name
   - Real-time filtering

5. **Add FCM user notification**
   - When push notification permission denied:
     ```dart
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: const Text(
           'Уведомления отключены. Вы не будете получать уведомления о сообщениях.',
         ),
         backgroundColor: Colors.orange,
         action: SnackBarAction(
           label: 'Настройки',
           onPressed: () => openAppSettings(), // Requires permission_handler
         ),
       ),
     );
     ```

#### Deliverables:
- ✅ Notification taps navigate to related content
- ✅ Unread message badges visible
- ✅ Better loading states for chats
- ✅ Chat search works
- ✅ User notified about push notification status
- ⚠️ **UI/UX Note**: Badge design should match app's visual style

---

### Phase 8: Implement Moderation & Reviews

**Goal**: Complete event moderation and review flows  
**UI/UX Impact**: Medium - power user features

#### Tasks:

1. **Register moderation and review routes**
   - Already covered in Phase 2

2. **Implement EventModerationScreen**
   - Show list of pending applications
   - Approve/Reject buttons for each
   - Use batch writes for efficiency
   - Update UI in real-time with stream
   - Add user notification if moderation fails

3. **Implement EventReviewScreen**
   - Star rating widget (1-5)
   - Text input for review
   - Submit button with validation
   - Use transaction for atomic writes
   - Add user notification if review submission fails

4. **Implement EventReviewsListScreen**
   - Display all reviews for event
   - Show reviewer avatar, name, rating, text
   - Calculate average rating
   - Add sorting (newest, highest, lowest)

5. **Connect review submission to event detail**
   - After event ends, show "Leave Review" button
   - Navigate to EventReviewScreen
   - Update event organizer rating

6. **Add Firestore user notifications**
   - When features unavailable:
     ```dart
     // In error handlers for moderation/reviews:
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
         content: Text('Функция модерирования временно недоступна.'),
         backgroundColor: Colors.orange,
       ),
     );
     ```

#### Deliverables:
- ✅ Organizers can approve/reject participants
- ✅ Users can leave reviews after events
- ✅ Reviews visible to all users
- ✅ Organizer ratings update
- ⚠️ **UI/UX Note**: Review UI should match app's card-based design

---

### Phase 9: Search & Map Improvements

**Goal**: Complete search functionality, fix map UX  
**UI/UX Impact**: Medium - discovery features

#### Tasks:

1. **Add loading state to search results**
   - Show skeleton/shimmer while `searchedEventsProvider` loads
   - Distinguish between "loading" and "no results"

2. **Improve category count display**
   - Replace vague "Популярность: X" with:
     - Event count in category, OR
     - Community count, OR
     - Remove count entirely

3. **Center map on user location**
   - Replace hardcoded Moscow coordinates
   - Use Geolocator to get user position
   - Fallback to Moscow only if location unavailable
   - Add user notification if location unavailable:
     ```dart
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(
         content: Text('Геолокация недоступна. Карта показывает события по умолчанию.'),
         backgroundColor: Colors.orange,
       ),
     );
     ```

4. **Optimize map marker updates**
   - Debounce `_updateMarkers()` calls
   - Only update when events actually change
   - Use `ref.listen` with comparison

5. **Fix location onboarding screen logic**
   - File: `location_screen.dart`
   - Fix `deniedForever` handling:
     ```dart
     if (permission == LocationPermission.deniedForever) {
       // Don't navigate to home - show dialog to open settings
       showDialog(
         context: context,
         builder: (_) => AlertDialog(
           title: const Text('Геолокация отключена'),
           content: const Text(
             'Для функций карты и поиска рядом включите геолокацию в настройках.',
           ),
           actions: [
             TextButton(
               onPressed: () => Navigator.pop(context),
               child: const Text('Отмена'),
             ),
             TextButton(
               onPressed: () {
                 Navigator.pop(context);
                 openAppSettings(); // Requires permission_handler
               },
               child: const Text('Настройки'),
             ),
           ],
         ),
       );
       return; // Don't navigate to home
     }
     ```

6. **Add geolocation user notifications**
   - Throughout app, when location features fail
   - Graceful degradation with helpful messages

#### Deliverables:
- ✅ Search shows loading state
- ✅ Category counts are meaningful
- ✅ Map centers on user location
- ✅ Location onboarding handles deniedForever properly
- ✅ User notified about geolocation status
- ⚠️ **UI/UX Note**: Map loading should show spinner or skeleton

---

### Phase 10: Cleanup & Polish

**Goal**: Remove dead code, improve consistency, add error handling  
**UI/UX Impact**: Low-Medium - quality of life improvements

#### Tasks:

1. **Remove or integrate unused providers**
   - Option A: Integrate `navigationProvider`, `loadingProvider`, `toastProvider`, `filterVisibilityProvider`
   - Option B: Remove them to reduce dead code
   - Recommendation: Remove and use Riverpod's built-in patterns

2. **Complete barrel export**
   - File: `providers.dart`
   - Add missing exports:
     ```dart
     export 'chat_providers.dart';
     export 'community_provider.dart';
     export 'notification_provider.dart';
     export 'error_observer.dart';
     ```

3. **Extract duplicated utilities**
   - `_formatPrice` → `lib/core/utils/formatters.dart`
   - Category colors → `lib/core/utils/category_colors.dart`
   - Time greeting → `lib/core/utils/greetings.dart`

4. **Add global error boundary**
   - Use `ErrorWidget.builder` in main.dart
   - Show friendly error screen instead of red error
   - Add "Restart app" button

5. **Improve error handling throughout**
   - Add try-catch to all async operations
   - Show user-friendly error messages
   - Add retry mechanisms where applicable
   - Log errors for debugging

6. **Add loading skeletons**
   - Replace all "Загрузка..." text with shimmer effects
   - Use `shimmer` package for skeleton loaders
   - Maintain layout stability during loading

7. **Standardize snackbar messages**
   - Create helper: `lib/core/utils/show_snackbar.dart`
   - Consistent styling (colors, duration, positioning)
   - Support for action buttons

8. **Update ACTION_PLANE.md**
   - Mark completed phases
   - Update completion percentage
   - Add any new discovered issues

#### Deliverables:
- ✅ No dead code or unused providers
- ✅ Single imports replaced with barrel export
- ✅ No code duplication
- ✅ Global error boundary in place
- ✅ Consistent error handling
- ✅ Smooth loading transitions
- ⚠️ **UI/UX Note**: Skeleton loaders prevent layout shifts

---

## Summary of Required User Notifications

### When to Notify Users

| Feature | When Unavailable | Notification Type | Message |
|---------|-----------------|-------------------|---------|
| Firebase Storage | Upload fails, network error | SnackBar (orange) | "Загрузка изображений временно недоступна. Попробуйте позже." |
| Geolocation | Permission denied, service unavailable | SnackBar (orange) | "Геолокация недоступна. Функции карты и поиска рядом временно не работают." |
| Google Maps | API key missing, network error | SnackBar (orange) | "Карты временно недоступны. Пожалуйста, попробуйте позже." |
| Push Notifications | Permission denied | SnackBar (orange) with action | "Push-уведомления отключены. Вы не будете получать уведомления о новых событиях." |
| Real-time Chat | Network unavailable | SnackBar (orange) | "Нет подключения к интернету. Сообщения будут отправлены при восстановлении соединения." |
| Event Moderation | Firestore error | SnackBar (red) | "Ошибка модерирования. Попробуйте позже." |
| Review Submission | Firestore error, not participant | SnackBar (red) | "Не удалось отправить отзыв. Попробуйте позже." |
| Chat with Organizer | Firestore error | SnackBar (orange) | "Чат с организатором временно недоступен." |
| Image Loading | Network error, broken URL | Fallback UI (inline) | Gradient placeholder with initial |

### Notification Design Pattern

```dart
// Standard pattern for all Firebase feature unavailability notifications:
void showFeatureUnavailable(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.warning, // Define in app_colors.dart
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(AppSpacing.md),
      duration: const Duration(seconds: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
  );
}
```

---

## Risk Assessment

| Phase | Risk Level | Potential UI/UX Breakage | Mitigation |
|-------|-----------|-------------------------|------------|
| 1: Critical Fixes | LOW | None - pure fixes | Test on both platforms |
| 2: Routing | MEDIUM | Navigation flows | Test all navigation paths |
| 3: Event Detail | MEDIUM | Layout shifts | Add loading states |
| 4: Profile | LOW | Settings tiles | Test all taps |
| 5: Communities | LOW | Discover tab | Match existing styling |
| 6: Home Screen | MEDIUM | Card redesign | A/B test if possible |
| 7: Notifications | LOW | Badge display | Test with empty states |
| 8: Moderation | LOW | New screens | Follow existing patterns |
| 9: Search & Map | MEDIUM | Map centering | Test geolocation flows |
| 10: Cleanup | LOW | None - refactoring | Run full test suite |

---

## Testing Checklist

After each phase, verify:

- [ ] App builds without errors on both Android and iOS
- [ ] All existing features still work
- [ ] New features work as expected
- [ ] No UI regressions (visual inspection)
- [ ] Navigation flows correctly (forward and back)
- [ ] Deep links work (if routes changed)
- [ ] Error states display properly
- [ ] Loading states are smooth
- [ ] User notifications appear when features unavailable
- [ ] No crashes or ANRs
- [ ] Riverpod providers connect correctly
- [ ] Firebase security rules allow operations

---

## Future Enhancements (Beyond Scope)

1. **Offline support** - Cache Firestore data locally
2. **Pagination** - For large event/chat/community lists
3. **Infinite scroll** - Better UX than pagination
4. **Pull to refresh** - On all list screens
5. **Dark mode optimization** - Test all screens in dark mode
6. **Accessibility** - Screen reader support, larger fonts
7. **Internationalization** - Full i18n support
8. **Performance optimization** - Lazy loading, image caching
9. **Analytics dashboard** - For organizers to view event stats
10. **Social features** - Friend requests, activity feed

---

## Conclusion

This comprehensive analysis identified **45 distinct issues** across 9 categories. The phased implementation plan ensures:

1. **Critical blockers fixed first** (compilation, platform config)
2. **Foundation stabilized** (routing, navigation)
3. **Core features completed** (events, profile, communities)
4. **Social features enhanced** (chat, notifications)
5. **Power features enabled** (moderation, reviews)
6. **Polish and cleanup** (consistency, error handling)

**Key Principles Throughout**:
- User notifications for all Firebase-dependent features when unavailable
- Consistent UI/UX patterns (cards, colors, spacing, typography)
- Proper loading states (skeleton/shimmer, not "Загрузка...")
- Error handling with retry mechanisms
- Graceful degradation when features unavailable
- No dead code or unused providers
- Single source of truth for shared utilities

**Estimated Final Completion**: ~95-98% after all phases

---

*Document created: 2026-04-06*  
*App version: Development stage (~68% complete)*  
*Firebase project: hobbyhub-dev*
