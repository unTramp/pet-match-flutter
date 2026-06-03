class SelectedQuestionAnswer {
  const SelectedQuestionAnswer({
    required this.questionId,
    required this.selectedOptionIds,
  });

  factory SelectedQuestionAnswer.fromJson(Map<String, dynamic> json) {
    return SelectedQuestionAnswer(
      questionId: json['questionId'] as String,
      selectedOptionIds:
          (json['selectedOptionIds'] as List<dynamic>? ?? const [])
              .whereType<String>()
              .toList(),
    );
  }

  final String questionId;
  final List<String> selectedOptionIds;
}

class BuildProfileRequest {
  const BuildProfileRequest({
    required this.questionnaireVersion,
    required this.answers,
  });

  factory BuildProfileRequest.fromJson(Map<String, dynamic> json) {
    return BuildProfileRequest(
      questionnaireVersion:
          (json['questionnaireVersion'] as num?)?.toInt() ?? -1,
      answers:
          (json['answers'] as List<dynamic>? ?? const [])
              .map(
                (item) => SelectedQuestionAnswer.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList(),
    );
  }

  final int questionnaireVersion;
  final List<SelectedQuestionAnswer> answers;
}

class UserProfileResponse {
  const UserProfileResponse({
    required this.questionnaireVersion,
    required this.userProfile,
  });

  final int questionnaireVersion;
  final Map<String, dynamic> userProfile;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'questionnaireVersion': questionnaireVersion,
      'userProfile': userProfile,
    };
  }
}
