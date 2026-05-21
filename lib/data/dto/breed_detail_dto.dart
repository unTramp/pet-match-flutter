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
    this.galleryImages = const [],
    this.sections = const [],
  });

  factory BreedDetailDto.fromJson(Map<String, dynamic> json) => BreedDetailDto(
    breedId: (json['breed_id'] as num).toInt(),
    breedName: json['breed_name'] as String,
    summary: json['summary'] as String?,
    imageUrl: json['image_url'] as String?,
    galleryImages:
        (json['gallery_images'] as List<dynamic>? ?? const []).cast<String>(),
    sections: (json['sections'] as List<dynamic>? ?? const [])
        .map((e) => BreedSectionDto.fromJson(e as Map<String, dynamic>))
        .toList(growable: false),
  );

  final int breedId;
  final String breedName;
  final String? summary;
  final String? imageUrl;
  final List<String> galleryImages;
  final List<BreedSectionDto> sections;
}
