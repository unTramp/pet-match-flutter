class BreedAttributesDto {
  const BreedAttributesDto({
    this.size,
    this.apartmentSuitability,
    this.exerciseNeeds,
    this.aloneTolerance,
    this.goodWithChildren,
    this.goodWithOtherPets,
    this.groomingNeeds,
    this.sheddingLevel,
    this.beginnerFriendly,
    this.maintenanceCost,
    this.noiseLevel,
    this.trainability,
  });

  factory BreedAttributesDto.fromJson(Map<String, dynamic> json) {
    int? readInt(String key) => (json[key] as num?)?.toInt();

    return BreedAttributesDto(
      size: readInt('size'),
      apartmentSuitability: readInt('apartmentSuitability'),
      exerciseNeeds: readInt('exerciseNeeds'),
      aloneTolerance: readInt('aloneTolerance'),
      goodWithChildren: readInt('goodWithChildren'),
      goodWithOtherPets: readInt('goodWithOtherPets'),
      groomingNeeds: readInt('groomingNeeds'),
      sheddingLevel: readInt('sheddingLevel'),
      beginnerFriendly: readInt('beginnerFriendly'),
      maintenanceCost: readInt('maintenanceCost'),
      noiseLevel: readInt('noiseLevel'),
      trainability: readInt('trainability'),
    );
  }

  final int? size;
  final int? apartmentSuitability;
  final int? exerciseNeeds;
  final int? aloneTolerance;
  final int? goodWithChildren;
  final int? goodWithOtherPets;
  final int? groomingNeeds;
  final int? sheddingLevel;
  final int? beginnerFriendly;
  final int? maintenanceCost;
  final int? noiseLevel;
  final int? trainability;
}
