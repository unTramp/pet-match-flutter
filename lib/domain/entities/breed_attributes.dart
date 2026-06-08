import 'package:equatable/equatable.dart';

class BreedAttributes extends Equatable {
  const BreedAttributes({
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

  bool get isEmpty =>
      size == null &&
      apartmentSuitability == null &&
      exerciseNeeds == null &&
      aloneTolerance == null &&
      goodWithChildren == null &&
      goodWithOtherPets == null &&
      groomingNeeds == null &&
      sheddingLevel == null &&
      beginnerFriendly == null &&
      maintenanceCost == null &&
      noiseLevel == null &&
      trainability == null;

  @override
  List<Object?> get props => [
    size,
    apartmentSuitability,
    exerciseNeeds,
    aloneTolerance,
    goodWithChildren,
    goodWithOtherPets,
    groomingNeeds,
    sheddingLevel,
    beginnerFriendly,
    maintenanceCost,
    noiseLevel,
    trainability,
  ];
}
