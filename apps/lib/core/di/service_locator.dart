import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/firebase/auth_service.dart';
import '../../services/firebase/firestore_service.dart';
import '../../services/firebase/messaging_service.dart';

/// GetIt service locator экземпляр
final getIt = GetIt.instance;

/// Инициализация всех зависимостей приложения
Future<void> setupServiceLocator() async {
  // ============================================================================
  // Firebase Services
  // ============================================================================

  // Firebase Auth
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

  // Firebase Firestore
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  // Firebase Storage
  getIt.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);

  // Firebase Messaging
  getIt.registerSingleton<FirebaseMessaging>(FirebaseMessaging.instance);

  // ============================================================================
  // Local Storage
  // ============================================================================

  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // ============================================================================
  // Domain Services (зависят от Firebase)
  // ============================================================================

  // Auth Service
  getIt.registerSingleton<AuthService>(AuthService());

  // Firestore Service
  getIt.registerSingleton<FirestoreService>(FirestoreService());

  // Messaging Service
  getIt.registerSingleton<MessagingService>(MessagingService());

  // ============================================================================
  // Repositories (если потребуются в будущем)
  // ============================================================================

  // Примеры для добавления в будущем:
  // getIt.registerSingleton<UserRepository>(
  //   UserRepository(getIt<FirestoreService>()),
  // );

  // ============================================================================
  // Use Cases (если потребуются в будущем)
  // ============================================================================

  // Примеры для добавления в будущем:
  // getIt.registerSingleton<GetUserUseCase>(
  //   GetUserUseCase(getIt<UserRepository>()),
  // );
}

/// Вспомогательные методы для получения зависимостей
extension ServiceLocatorExtension on GetIt {
  /// Получить Firebase Auth
  FirebaseAuth get firebaseAuth => get<FirebaseAuth>();

  /// Получить Firestore
  FirebaseFirestore get firestore => get<FirebaseFirestore>();

  /// Получить Firebase Storage
  FirebaseStorage get storage => get<FirebaseStorage>();

  /// Получить Firebase Messaging
  FirebaseMessaging get messaging => get<FirebaseMessaging>();

  /// Получить Shared Preferences
  SharedPreferences get prefs => get<SharedPreferences>();

  /// Получить Auth Service
  AuthService get authService => get<AuthService>();

  /// Получить Firestore Service
  FirestoreService get firestoreService => get<FirestoreService>();

  /// Получить Messaging Service
  MessagingService get messagingService => get<MessagingService>();
}
