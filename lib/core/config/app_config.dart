/// Конфигурация приложения для разных окружений
class AppConfig {
  final String appName;
  final String apiBaseUrl;
  final String firebaseProjectId;
  final bool enableAnalytics;
  final bool enableCrashlytics;
  final bool showDebugBanner;

  const AppConfig({
    required this.appName,
    required this.apiBaseUrl,
    required this.firebaseProjectId,
    required this.enableAnalytics,
    required this.enableCrashlytics,
    required this.showDebugBanner,
  });

  // Development environment
  static const AppConfig development = AppConfig(
    appName: 'HobbyHub (Dev)',
    apiBaseUrl: 'https://dev-api.hobbyhub.com',
    firebaseProjectId: 'hobbyhub-dev',
    enableAnalytics: false,
    enableCrashlytics: false,
    showDebugBanner: true,
  );

  // Staging environment
  static const AppConfig staging = AppConfig(
    appName: 'HobbyHub (Staging)',
    apiBaseUrl: 'https://staging-api.hobbyhub.com',
    firebaseProjectId: 'hobbyhub-staging',
    enableAnalytics: true,
    enableCrashlytics: true,
    showDebugBanner: true,
  );

  // Production environment
  static const AppConfig production = AppConfig(
    appName: 'HobbyHub',
    apiBaseUrl: 'https://api.hobbyhub.com',
    firebaseProjectId: 'hobbyhub-prod',
    enableAnalytics: true,
    enableCrashlytics: true,
    showDebugBanner: false,
  );

  // Current environment (по умолчанию development)
  static const AppConfig current = development;
}
