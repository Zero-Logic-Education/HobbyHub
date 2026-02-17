import 'package:json_annotation/json_annotation.dart';

part 'interest.g.dart';

/// Модель интереса/хобби HobbyHub
@JsonSerializable(explicitToJson: true)
class Interest {
  /// Уникальный идентификатор интереса
  final String id;

  /// Название интереса
  final String name;

  /// Категория интереса (спорт, искусство, музыка, технологии и т.д.)
  final String category;

  /// Описание интереса
  final String? description;

  /// URL иконки/изображения
  final String? iconUrl;

  /// Количество пользователей с этим интересом
  final int usersCount;

  /// Список ID связанных интересов
  final List<String> relatedInterests;

  /// Популярность (0-100)
  final int popularity;

  /// Рекомендуется ли (featured)
  final bool isFeatured;

  Interest({
    required this.id,
    required this.name,
    required this.category,
    this.description,
    this.iconUrl,
    this.usersCount = 0,
    this.relatedInterests = const [],
    this.popularity = 0,
    this.isFeatured = false,
  });

  factory Interest.fromJson(Map<String, dynamic> json) => _$InterestFromJson(json);
  Map<String, dynamic> toJson() => _$InterestToJson(this);

  Interest copyWith({
    String? id,
    String? name,
    String? category,
    String? description,
    String? iconUrl,
    int? usersCount,
    List<String>? relatedInterests,
    int? popularity,
    bool? isFeatured,
  }) {
    return Interest(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      usersCount: usersCount ?? this.usersCount,
      relatedInterests: relatedInterests ?? this.relatedInterests,
      popularity: popularity ?? this.popularity,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
}
