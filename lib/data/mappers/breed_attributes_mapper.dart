import '../../domain/entities/breed_attributes.dart';
import '../dto/breed_attributes_dto.dart';

class BreedAttributesMapper {
  const BreedAttributesMapper._();

  static BreedAttributes fromDto(BreedAttributesDto dto) => BreedAttributes(
    size: dto.size,
    apartmentSuitability: dto.apartmentSuitability,
    exerciseNeeds: dto.exerciseNeeds,
    aloneTolerance: dto.aloneTolerance,
    goodWithChildren: dto.goodWithChildren,
    goodWithOtherPets: dto.goodWithOtherPets,
    groomingNeeds: dto.groomingNeeds,
    sheddingLevel: dto.sheddingLevel,
    beginnerFriendly: dto.beginnerFriendly,
    maintenanceCost: dto.maintenanceCost,
    noiseLevel: dto.noiseLevel,
    trainability: dto.trainability,
  );
}
