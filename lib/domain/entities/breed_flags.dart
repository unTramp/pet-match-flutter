import 'package:equatable/equatable.dart';

class BreedFlags extends Equatable {
  const BreedFlags({
    this.isVocal = false,
    this.isHighPreyDrive = false,
    this.isSensitive = false,
    this.isEscapeProne = false,
    this.isSuitableForFirstTimeOwners = false,
  });

  final bool isVocal;
  final bool isHighPreyDrive;
  final bool isSensitive;
  final bool isEscapeProne;
  final bool isSuitableForFirstTimeOwners;

  bool get isEmpty =>
      !isVocal &&
      !isHighPreyDrive &&
      !isSensitive &&
      !isEscapeProne &&
      !isSuitableForFirstTimeOwners;

  @override
  List<Object?> get props => [
    isVocal,
    isHighPreyDrive,
    isSensitive,
    isEscapeProne,
    isSuitableForFirstTimeOwners,
  ];
}
