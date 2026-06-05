import 'compatibility_dto.dart';

class PetWiseMatchPreviewDto {
  const PetWiseMatchPreviewDto({
    required this.questionnaireVersion,
    required this.scoringVersion,
    required this.compatibility,
  });

  factory PetWiseMatchPreviewDto.fromJson(Map<String, dynamic> json) =>
      PetWiseMatchPreviewDto(
        questionnaireVersion: (json['questionnaireVersion'] as num).toInt(),
        scoringVersion: (json['scoringVersion'] as num).toInt(),
        compatibility: CompatibilityDto.fromJson(
          json['compatibility'] as Map<String, dynamic>,
        ),
      );

  final int questionnaireVersion;
  final int scoringVersion;
  final CompatibilityDto compatibility;
}
