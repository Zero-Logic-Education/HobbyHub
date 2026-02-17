// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Event _$EventFromJson(Map<String, dynamic> json) => Event(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  organizerId: json['organizerId'] as String,
  startTime: Event._timestampFromJson(json['startTime']),
  endTime: Event._timestampFromJsonNullable(json['endTime']),
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  address: json['address'] as String?,
  coverImageUrl: json['coverImageUrl'] as String?,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  participants:
      (json['participants'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 0,
  price: (json['price'] as num?)?.toDouble() ?? 0.0,
  isFree: json['isFree'] as bool? ?? true,
  visibility: json['visibility'] as String? ?? 'public',
  minAge: (json['minAge'] as num?)?.toInt() ?? 12,
  requiresApproval: json['requiresApproval'] as bool? ?? false,
  eventType: json['eventType'] as String? ?? 'single',
  createdAt: Event._timestampFromJson(json['createdAt']),
  updatedAt: Event._timestampFromJsonNullable(json['updatedAt']),
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
  reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
  communityId: json['communityId'] as String?,
  coOrganizers:
      (json['coOrganizers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  status: json['status'] as String? ?? 'published',
);

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'description': instance.description,
  'organizerId': instance.organizerId,
  'startTime': Event._timestampToJson(instance.startTime),
  'endTime': Event._timestampToJson(instance.endTime),
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'address': instance.address,
  'coverImageUrl': instance.coverImageUrl,
  'categories': instance.categories,
  'participants': instance.participants,
  'maxParticipants': instance.maxParticipants,
  'price': instance.price,
  'isFree': instance.isFree,
  'visibility': instance.visibility,
  'minAge': instance.minAge,
  'requiresApproval': instance.requiresApproval,
  'eventType': instance.eventType,
  'createdAt': Event._timestampToJson(instance.createdAt),
  'updatedAt': Event._timestampToJson(instance.updatedAt),
  'rating': instance.rating,
  'reviewsCount': instance.reviewsCount,
  'communityId': instance.communityId,
  'coOrganizers': instance.coOrganizers,
  'status': instance.status,
};
