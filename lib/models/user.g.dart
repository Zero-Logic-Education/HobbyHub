// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  displayName: json['displayName'] as String?,
  photoUrl: json['photoUrl'] as String?,
  bio: json['bio'] as String?,
  age: (json['age'] as num).toInt(),
  interests:
      (json['interests'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  privacyLevel: json['privacyLevel'] as String? ?? 'public',
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  isVerified: json['isVerified'] as bool? ?? false,
  parentEmail: json['parentEmail'] as String?,
  createdAt: User._timestampFromJson(json['createdAt']),
  updatedAt: User._timestampFromJsonNullable(json['updatedAt']),
  friends:
      (json['friends'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  eventsAttended: (json['eventsAttended'] as num?)?.toInt() ?? 0,
  organizerRating: (json['organizerRating'] as num?)?.toDouble() ?? 0.0,
  eventsCreated: (json['eventsCreated'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'username': instance.username,
  'displayName': instance.displayName,
  'photoUrl': instance.photoUrl,
  'bio': instance.bio,
  'age': instance.age,
  'interests': instance.interests,
  'privacyLevel': instance.privacyLevel,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'isVerified': instance.isVerified,
  'parentEmail': instance.parentEmail,
  'createdAt': User._timestampToJson(instance.createdAt),
  'updatedAt': User._timestampToJson(instance.updatedAt),
  'friends': instance.friends,
  'eventsAttended': instance.eventsAttended,
  'organizerRating': instance.organizerRating,
  'eventsCreated': instance.eventsCreated,
};
