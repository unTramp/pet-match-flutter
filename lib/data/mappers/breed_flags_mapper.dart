import '../../domain/entities/breed_flags.dart';
import '../dto/breed_flags_dto.dart';

class BreedFlagsMapper {
  const BreedFlagsMapper._();

  static BreedFlags fromDto(BreedFlagsDto dto) => BreedFlags(
    isVocal: dto.isVocal,
    isHighPreyDrive: dto.isHighPreyDrive,
    isSensitive: dto.isSensitive,
    isEscapeProne: dto.isEscapeProne,
    isSuitableForFirstTimeOwners: dto.isSuitableForFirstTimeOwners,
  );
}
