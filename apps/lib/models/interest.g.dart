// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interest.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Interest _$InterestFromJson(Map<String, dynamic> json) => Interest(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  description: json['description'] as String?,
  iconUrl: json['iconUrl'] as String?,
  usersCount: (json['usersCount'] as num?)?.toInt() ?? 0,
  relatedInterests:
      (json['relatedInterests'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  popularity: (json['popularity'] as num?)?.toInt() ?? 0,
  isFeatured: json['isFeatured'] as bool? ?? false,
);

Map<String, dynamic> _$InterestToJson(Interest instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'description': instance.description,
  'iconUrl': instance.iconUrl,
  'usersCount': instance.usersCount,
  'relatedInterests': instance.relatedInterests,
  'popularity': instance.popularity,
  'isFeatured': instance.isFeatured,
};
