import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'services/firebase/messaging_service.dart';
import 'providers/ui_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'core/router/app_router.dart';
import 'core/di/service_locator.dart';
import 'providers/error_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Настройка прозрачного статус-бара
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Инициализация Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Инициализация GetIt (Dependency Injection)
  await setupServiceLocator();

  // Инициализация Firebase Messaging
  await getIt.messagingService.initialize();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    ProviderScope(observers: [GlobalErrorObserver()], child: const MyApp()),
  );
}

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Получаем тему из Riverpod провайдера
    final isDarkMode = ref.watch(themeProvider);

    // Подписываемся на изменение текущего пользователя для привязки FCM токена
    ref.listen(currentUserIdProvider, (previous, next) {
      if (next != null) {
        final firestoreService = ref.read(firestoreServiceProvider);
        final messagingService = getIt.messagingService;

        messagingService.getToken().then((token) {
          if (token != null) {
            firestoreService.saveFcmToken(next, token);
          }
        });

        // Также слушаем обновление токена
        FirebaseMessaging.instance.onTokenRefresh.listen((token) {
          firestoreService.saveFcmToken(next, token);
        });
      }
    });

    // Получаем маршрутизатор
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'HobbyHub',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
    );
  }
}
