import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user.g.dart';

/// Модель пользователя HobbyHub
@JsonSerializable(explicitToJson: true)
class User {
  /// Уникальный идентификатор пользователя (Firebase UID)
  final String id;

  /// Email пользователя
  final String email;

  /// Уникальное имя пользователя (3-30 символов)
  final String username;

  /// Отображаемое имя
  final String? displayName;

  /// URL фотографии профиля
  final String? photoUrl;

  /// Биография/описание пользователя (макс 500 символов)
  final String? bio;

  /// Возраст пользователя (мин 12 лет)
  final int age;

  /// Список ID интересов пользователя
  final List<String> interests;

  /// Уровень приватности: 'public', 'friends', 'private', 'custom'
  final String privacyLevel;

  /// Широта местоположения
  final double? latitude;

  /// Долгота местоположения
  final double? longitude;

  /// Верифицирован ли пользователь
  final bool isVerified;

  /// Email родителя (для пользователей < 18 лет)
  final String? parentEmail;

  /// Дата создания аккаунта
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  /// Дата последнего обновления профиля
  @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJson)
  final DateTime? updatedAt;

  /// Список ID друзей
  final List<String> friends;

  /// Количество посещенных событий
  final int eventsAttended;

  /// Рейтинг как организатор (0.0-5.0)
  final double organizerRating;

  /// Количество созданных событий
  final int eventsCreated;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.displayName,
    this.photoUrl,
    this.bio,
    required this.age,
    this.interests = const [],
    this.privacyLevel = 'public',
    this.latitude,
    this.longitude,
    this.isVerified = false,
    this.parentEmail,
    required this.createdAt,
    this.updatedAt,
    this.friends = const [],
    this.eventsAttended = 0,
    this.organizerRating = 0.0,
    this.eventsCreated = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? photoUrl,
    String? bio,
    int? age,
    List<String>? interests,
    String? privacyLevel,
    double? latitude,
    double? longitude,
    bool? isVerified,
    String? parentEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? friends,
    int? eventsAttended,
    double? organizerRating,
    int? eventsCreated,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      age: age ?? this.age,
      interests: interests ?? this.interests,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isVerified: isVerified ?? this.isVerified,
      parentEmail: parentEmail ?? this.parentEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      friends: friends ?? this.friends,
      eventsAttended: eventsAttended ?? this.eventsAttended,
      organizerRating: organizerRating ?? this.organizerRating,
      eventsCreated: eventsCreated ?? this.eventsCreated,
    );
  }

  // Helper методы для конвертации Firestore Timestamp
  static DateTime _timestampFromJson(dynamic timestamp) {
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return DateTime.now();
  }

  static DateTime? _timestampFromJsonNullable(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) return DateTime.parse(timestamp);
    return null;
  }

  static dynamic _timestampToJson(DateTime? dateTime) {
    return dateTime?.toIso8601String();
  }
}
