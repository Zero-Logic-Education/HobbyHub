// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
  id: json['id'] as String,
  participants: (json['participants'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  lastMessage: json['lastMessage'] as String?,
  lastMessageAt: Chat._timestampFromJsonNullable(json['lastMessageAt']),
  lastMessageSenderId: json['lastMessageSenderId'] as String?,
);

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
  'id': instance.id,
  'participants': instance.participants,
  'lastMessage': instance.lastMessage,
  'lastMessageAt': Chat._timestampToJson(instance.lastMessageAt),
  'lastMessageSenderId': instance.lastMessageSenderId,
};

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
  id: json['id'] as String,
  chatId: json['chatId'] as String,
  senderId: json['senderId'] as String,
  text: json['text'] as String,
  createdAt: Message._timestampFromJson(json['createdAt']),
  isRead: json['isRead'] as bool? ?? false,
);

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
  'id': instance.id,
  'chatId': instance.chatId,
  'senderId': instance.senderId,
  'text': instance.text,
  'createdAt': Message._timestampToJsonMessage(instance.createdAt),
  'isRead': instance.isRead,
};
