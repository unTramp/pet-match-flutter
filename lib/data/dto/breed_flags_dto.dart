class BreedFlagsDto {
  const BreedFlagsDto({
    this.isVocal = false,
    this.isHighPreyDrive = false,
    this.isSensitive = false,
    this.isEscapeProne = false,
    this.isSuitableForFirstTimeOwners = false,
  });

  factory BreedFlagsDto.fromJson(Map<String, dynamic> json) => BreedFlagsDto(
    isVocal: json['isVocal'] as bool? ?? false,
    isHighPreyDrive: json['isHighPreyDrive'] as bool? ?? false,
    isSensitive: json['isSensitive'] as bool? ?? false,
    isEscapeProne: json['isEscapeProne'] as bool? ?? false,
    isSuitableForFirstTimeOwners:
        json['isSuitableForFirstTimeOwners'] as bool? ?? false,
  );

  final bool isVocal;
  final bool isHighPreyDrive;
  final bool isSensitive;
  final bool isEscapeProne;
  final bool isSuitableForFirstTimeOwners;
}
