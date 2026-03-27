import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'community.g.dart';

/// Модель сообщества HobbyHub
@JsonSerializable(explicitToJson: true)
class Community {
  /// Уникальный идентификатор сообщества
  final String id;

  /// Название сообщества
  final String name;

  /// Описание сообщества
  final String description;

  /// ID создателя сообщества
  final String creatorId;

  /// URL обложки сообщества
  final String? coverImageUrl;

  /// URL логотипа сообщества
  final String? logoUrl;

  /// Список категорий/интересов сообщества
  final List<String> categories;

  /// Список ID участников
  final List<String> members;

  /// Список ID модераторов
  final List<String> moderators;

  /// Уровень приватности: 'public', 'private', 'invite-only'
  final String privacyLevel;

  /// Дата создания сообщества
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  /// Дата последнего обновления
  @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJson)
  final DateTime? updatedAt;

  /// Количество событий, созданных сообществом
  final int eventsCount;

  /// Верифицировано ли сообщество
  final bool isVerified;

  /// Правила сообщества
  final String? rules;

  /// Минимальный возраст для вступления
  final int minAge;

  /// Максимальное количество участников (0 = без ограничений)
  final int maxMembers;

  /// Требуется ли одобрение для вступления
  final bool requiresApproval;

  /// Рейтинг сообщества (0.0-5.0)
  final double rating;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    this.coverImageUrl,
    this.logoUrl,
    this.categories = const [],
    this.members = const [],
    this.moderators = const [],
    this.privacyLevel = 'public',
    required this.createdAt,
    this.updatedAt,
    this.eventsCount = 0,
    this.isVerified = false,
    this.rules,
    this.minAge = 12,
    this.maxMembers = 0,
    this.requiresApproval = false,
    this.rating = 0.0,
  });

  factory Community.fromJson(Map<String, dynamic> json) =>
      _$CommunityFromJson(json);
  Map<String, dynamic> toJson() => _$CommunityToJson(this);

  Community copyWith({
    String? id,
    String? name,
    String? description,
    String? creatorId,
    String? coverImageUrl,
    String? logoUrl,
    List<String>? categories,
    List<String>? members,
    List<String>? moderators,
    String? privacyLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? eventsCount,
    bool? isVerified,
    String? rules,
    int? minAge,
    int? maxMembers,
    bool? requiresApproval,
    double? rating,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      categories: categories ?? this.categories,
      members: members ?? this.members,
      moderators: moderators ?? this.moderators,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      eventsCount: eventsCount ?? this.eventsCount,
      isVerified: isVerified ?? this.isVerified,
      rules: rules ?? this.rules,
      minAge: minAge ?? this.minAge,
      maxMembers: maxMembers ?? this.maxMembers,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      rating: rating ?? this.rating,
    );
  }

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
