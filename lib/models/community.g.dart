// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Community _$CommunityFromJson(Map<String, dynamic> json) => Community(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  creatorId: json['creatorId'] as String,
  coverImageUrl: json['coverImageUrl'] as String?,
  logoUrl: json['logoUrl'] as String?,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  members:
      (json['members'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  moderators:
      (json['moderators'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  privacyLevel: json['privacyLevel'] as String? ?? 'public',
  createdAt: Community._timestampFromJson(json['createdAt']),
  updatedAt: Community._timestampFromJsonNullable(json['updatedAt']),
  eventsCount: (json['eventsCount'] as num?)?.toInt() ?? 0,
  isVerified: json['isVerified'] as bool? ?? false,
  rules: json['rules'] as String?,
  minAge: (json['minAge'] as num?)?.toInt() ?? 12,
  maxMembers: (json['maxMembers'] as num?)?.toInt() ?? 0,
  requiresApproval: json['requiresApproval'] as bool? ?? false,
  rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$CommunityToJson(Community instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'creatorId': instance.creatorId,
  'coverImageUrl': instance.coverImageUrl,
  'logoUrl': instance.logoUrl,
  'categories': instance.categories,
  'members': instance.members,
  'moderators': instance.moderators,
  'privacyLevel': instance.privacyLevel,
  'createdAt': Community._timestampToJson(instance.createdAt),
  'updatedAt': Community._timestampToJson(instance.updatedAt),
  'eventsCount': instance.eventsCount,
  'isVerified': instance.isVerified,
  'rules': instance.rules,
  'minAge': instance.minAge,
  'maxMembers': instance.maxMembers,
  'requiresApproval': instance.requiresApproval,
  'rating': instance.rating,
};
