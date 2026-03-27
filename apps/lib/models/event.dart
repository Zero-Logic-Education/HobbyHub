import 'package:json_annotation/json_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'event.g.dart';

/// Модель события HobbyHub
@JsonSerializable(explicitToJson: true)
class Event {
  /// Уникальный идентификатор события
  final String id;

  /// Название события (макс 100 символов)
  final String title;

  /// Описание события (макс 2000 символов)
  final String description;

  /// ID организатора события
  final String organizerId;

  /// Дата и время начала события
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime startTime;

  /// Дата и время окончания события
  @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJson)
  final DateTime? endTime;

  /// Широта местоположения события
  final double latitude;

  /// Долгота местоположения события
  final double longitude;

  /// Адрес места проведения
  final String? address;

  /// URL обложки события
  final String? coverImageUrl;

  /// Дополнительные фотографии
  final List<String> images;

  /// Список категорий/тегов
  final List<String> categories;

  /// Список ID участников
  final List<String> participants;

  /// Максимальное количество участников (0 = без ограничений)
  final int maxParticipants;

  /// Цена участия (0 = бесплатно)
  final double price;

  /// Бесплатное ли событие
  final bool isFree;

  /// Видимость: 'public', 'friends', 'private', 'community'
  final String visibility;

  /// Минимальный возраст для участия
  final int minAge;

  /// Требуется ли одобрение организатора для участия
  final bool requiresApproval;

  /// Тип события: 'single' (разовое), 'recurring' (регулярное), 'series' (серия)
  final String eventType;

  /// Дата создания события
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;

  /// Дата последнего обновления
  @JsonKey(fromJson: _timestampFromJsonNullable, toJson: _timestampToJson)
  final DateTime? updatedAt;

  /// Рейтинг события (0.0-5.0)
  final double rating;

  /// Количество отзывов
  final int reviewsCount;

  /// ID сообщества (если событие создано сообществом)
  final String? communityId;

  /// Список ID со-организаторов
  final List<String> coOrganizers;

  /// Статус события: 'draft', 'published', 'cancelled', 'completed'
  final String status;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.organizerId,
    required this.startTime,
    this.endTime,
    required this.latitude,
    required this.longitude,
    this.address,
    this.coverImageUrl,
    this.images = const [],
    this.categories = const [],
    this.participants = const [],
    this.maxParticipants = 0,
    this.price = 0.0,
    this.isFree = true,
    this.visibility = 'public',
    this.minAge = 12,
    this.requiresApproval = false,
    this.eventType = 'single',
    required this.createdAt,
    this.updatedAt,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.communityId,
    this.coOrganizers = const [],
    this.status = 'published',
  });

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
  Map<String, dynamic> toJson() => _$EventToJson(this);

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? organizerId,
    DateTime? startTime,
    DateTime? endTime,
    double? latitude,
    double? longitude,
    String? address,
    String? coverImageUrl,
    List<String>? images,
    List<String>? categories,
    List<String>? participants,
    int? maxParticipants,
    double? price,
    bool? isFree,
    String? visibility,
    int? minAge,
    bool? requiresApproval,
    String? eventType,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? reviewsCount,
    String? communityId,
    List<String>? coOrganizers,
    String? status,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      organizerId: organizerId ?? this.organizerId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      images: images ?? this.images,
      categories: categories ?? this.categories,
      participants: participants ?? this.participants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
      visibility: visibility ?? this.visibility,
      minAge: minAge ?? this.minAge,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      eventType: eventType ?? this.eventType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      communityId: communityId ?? this.communityId,
      coOrganizers: coOrganizers ?? this.coOrganizers,
      status: status ?? this.status,
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
