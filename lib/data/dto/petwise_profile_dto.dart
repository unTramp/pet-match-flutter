class PetWiseSelectedAnswerDto {
  const PetWiseSelectedAnswerDto({
    required this.questionId,
    required this.selectedOptionIds,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'questionId': questionId,
    'selectedOptionIds': selectedOptionIds,
  };

  final String questionId;
  final List<String> selectedOptionIds;
}

class PetWiseProfileResponseDto {
  const PetWiseProfileResponseDto({
    required this.questionnaireVersion,
    required this.userProfile,
  });

  factory PetWiseProfileResponseDto.fromJson(Map<String, dynamic> json) =>
      PetWiseProfileResponseDto(
        questionnaireVersion: (json['questionnaireVersion'] as num).toInt(),
        userProfile: Map<String, dynamic>.from(
          json['userProfile'] as Map<String, dynamic>? ?? const {},
        ),
      );

  final int questionnaireVersion;
  final Map<String, dynamic> userProfile;
}
