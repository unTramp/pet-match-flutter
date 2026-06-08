import 'breed_attributes_dto.dart';
import 'breed_flags_dto.dart';

class BreedSectionDto {
  const BreedSectionDto({this.title, this.body});

  factory BreedSectionDto.fromJson(Map<String, dynamic> json) =>
      BreedSectionDto(
        title: json['title'] as String?,
        body: json['body'] as String?,
      );

  final String? title;
  final String? body;
}

class BreedDetailDto {
  const BreedDetailDto({
    required this.breedId,
    required this.breedName,
    this.summary,
    this.imageUrl,
    this.storyAvatarUrl,
    this.galleryImages = const [],
    this.sections = const [],
    this.attributes,
    this.group,
    this.aliases = const [],
    this.flags,
  });

  factory BreedDetailDto.fromJson(Map<String, dynamic> json) => BreedDetailDto(
    breedId: _readId(json['breedId'] ?? json['breed_id']),
    breedName: (json['name'] ?? json['breed_name']) as String,
    summary:
        (json['summary'] ??
                (json['content'] as Map<String, dynamic>?)?['summaryShort'])
            as String?,
    imageUrl: (json['imageUrl'] ?? json['image_url']) as String?,
    storyAvatarUrl:
        (json['storyAvatarUrl'] ?? json['story_avatar_url']) as String?,
    group: json['group'] as String?,
    aliases: (json['aliases'] as List<dynamic>? ?? const []).cast<String>(),
    galleryImages:
        ((json['galleryImages'] ?? json['gallery_images']) as List<dynamic>? ??
                const [])
            .cast<String>(),
    attributes:
        json['attributes'] is Map<String, dynamic>
            ? BreedAttributesDto.fromJson(
              json['attributes'] as Map<String, dynamic>,
            )
            : null,
    flags:
        json['flags'] is Map<String, dynamic>
            ? BreedFlagsDto.fromJson(json['flags'] as Map<String, dynamic>)
            : null,
    sections: _readSections(json),
  );

  final String breedId;
  final String breedName;
  final String? summary;
  final String? imageUrl;
  final String? storyAvatarUrl;
  final String? group;
  final List<String> aliases;
  final List<String> galleryImages;
  final List<BreedSectionDto> sections;
  final BreedAttributesDto? attributes;
  final BreedFlagsDto? flags;

  static String _readId(Object? raw) {
    return switch (raw) {
      final String value => value,
      final num value => value.toInt().toString(),
      _ => '',
    };
  }

  static List<BreedSectionDto> _readSections(Map<String, dynamic> json) {
    final rawSections = json['sections'] as List<dynamic>?;
    if (rawSections != null) {
      return rawSections
          .map((e) => BreedSectionDto.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    }

    final content = json['content'] as Map<String, dynamic>?;
    if (content == null) return const <BreedSectionDto>[];

    final sections = <BreedSectionDto>[];
    final strengths = (content['strengths'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .join('\n');
    final watchouts = (content['watchouts'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .join('\n');
    final tips = (content['adaptationTips'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .join('\n');

    if (strengths.isNotEmpty) {
      sections.add(BreedSectionDto(title: 'Сильные стороны', body: strengths));
    }
    if (watchouts.isNotEmpty) {
      sections.add(BreedSectionDto(title: 'Что учитывать', body: watchouts));
    }
    if (tips.isNotEmpty) {
      sections.add(BreedSectionDto(title: 'Советы по адаптации', body: tips));
    }
    return sections;
  }
}
