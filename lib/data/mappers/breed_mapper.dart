import '../../domain/entities/breed_detail.dart';
import '../dto/breed_detail_dto.dart';

class BreedMapper {
  const BreedMapper._();

  static BreedDetail fromDto(BreedDetailDto dto) => BreedDetail(
    breedId: dto.breedId,
    breedName: dto.breedName,
    breedCode: dto.breedCode,
    petType: dto.petType,
    summary: dto.summary,
    imageUrl: dto.imageUrl,
    galleryImages: List<String>.unmodifiable(dto.galleryImages),
    sections: dto.sections
        .where((s) => (s.title ?? '').isNotEmpty || (s.body ?? '').isNotEmpty)
        .map((s) => BreedSection(title: s.title ?? '', body: s.body ?? ''))
        .toList(growable: false),
  );
}
