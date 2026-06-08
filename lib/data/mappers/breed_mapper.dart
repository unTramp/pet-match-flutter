import '../../domain/entities/breed_detail.dart';
import 'breed_attributes_mapper.dart';
import 'breed_flags_mapper.dart';
import '../dto/breed_detail_dto.dart';

class BreedMapper {
  const BreedMapper._();

  static BreedDetail fromDto(BreedDetailDto dto) => BreedDetail(
    breedId: dto.breedId,
    breedName: dto.breedName,
    summary: dto.summary,
    imageUrl: dto.imageUrl,
    storyAvatarUrl: dto.storyAvatarUrl,
    group: dto.group,
    aliases: List<String>.unmodifiable(dto.aliases),
    galleryImages: List<String>.unmodifiable(dto.galleryImages),
    attributes:
        dto.attributes == null
            ? null
            : BreedAttributesMapper.fromDto(dto.attributes!),
    flags: dto.flags == null ? null : BreedFlagsMapper.fromDto(dto.flags!),
    sections: dto.sections
        .where((s) => (s.title ?? '').isNotEmpty || (s.body ?? '').isNotEmpty)
        .map((s) => BreedSection(title: s.title ?? '', body: s.body ?? ''))
        .toList(growable: false),
  );
}
