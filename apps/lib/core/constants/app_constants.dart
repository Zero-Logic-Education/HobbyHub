/// Глобальные константы приложения HobbyHub
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'HobbyHub';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Твое хобби — твои правила';

  // API & Backend
  static const String apiBaseUrl = 'https://api.hobbyhub.com';
  static const int apiTimeout = 30000; // 30 seconds

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String communitiesCollection = 'communities';
  static const String interestsCollection = 'interests';
  static const String reviewsCollection = 'reviews';
  static const String reportsCollection = 'reports';

  // Storage
  static const String profileImagesPath = 'profile_images';
  static const String eventImagesPath = 'event_images';
  static const String communityImagesPath = 'community_images';

  // Pagination
  static const int pageSize = 20;
  static const int maxPageSize = 100;

  // Map
  static const double defaultLatitude = 55.7558; // Moscow
  static const double defaultLongitude = 37.6173;
  static const double defaultZoom = 12.0;
  static const double searchRadiusKm = 50.0;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const int maxBioLength = 500;
  static const int maxEventTitleLength = 100;
  static const int maxEventDescriptionLength = 2000;

  // Age Restrictions
  static const int minAge = 12;
  static const int adultAge = 18;
  static const int organizerAge = 25;

  // Time
  static const int storiesDurationHours = 24;
  static const int sessionTimeoutMinutes = 30;

  // Images
  static const int maxImageSizeMB = 10;
  static const int maxImagesPerEvent = 10;
  static const List<String> allowedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // Privacy Levels
  static const String privacyPublic = 'public';
  static const String privacyFriends = 'friends';
  static const String privacyPrivate = 'private';
  static const String privacyCustom = 'custom';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
}
