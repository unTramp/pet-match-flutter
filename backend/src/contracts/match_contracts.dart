class MatchPreviewRequest {
  const MatchPreviewRequest({
    required this.questionnaireVersion,
    required this.userProfile,
  });

  factory MatchPreviewRequest.fromJson(Map<String, dynamic> json) {
    return MatchPreviewRequest(
      questionnaireVersion:
          (json['questionnaireVersion'] as num?)?.toInt() ?? -1,
      userProfile: Map<String, dynamic>.from(
        json['userProfile'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  final int questionnaireVersion;
  final Map<String, dynamic> userProfile;
}

class RankedBreedResponse {
  const RankedBreedResponse({
    required this.breedId,
    required this.name,
    required this.matchPercent,
    required this.label,
    required this.summary,
    required this.warning,
    required this.strongMatches,
    required this.weakMatches,
  });

  final String breedId;
  final String name;
  final int matchPercent;
  final String label;
  final String summary;
  final String? warning;
  final List<String> strongMatches;
  final List<String> weakMatches;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'breedId': breedId,
      'name': name,
      'matchPercent': matchPercent,
      'label': label,
      'summary': summary,
      'warning': warning,
      'strongMatches': strongMatches,
      'weakMatches': weakMatches,
    };
  }
}

class AlternativeBreedResponse {
  const AlternativeBreedResponse({
    required this.breedId,
    required this.name,
    required this.matchPercent,
  });

  final String breedId;
  final String name;
  final int matchPercent;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'breedId': breedId,
      'name': name,
      'matchPercent': matchPercent,
    };
  }
}

class MatchResultResponse {
  const MatchResultResponse({
    required this.resultId,
    required this.storedAt,
    required this.questionnaireVersion,
    required this.scoringVersion,
    required this.userProfile,
    required this.topMatch,
    required this.alternatives,
  });

  final String resultId;
  final String storedAt;
  final int questionnaireVersion;
  final int scoringVersion;
  final Map<String, dynamic> userProfile;
  final RankedBreedResponse topMatch;
  final List<AlternativeBreedResponse> alternatives;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'resultId': resultId,
      'storedAt': storedAt,
      'questionnaireVersion': questionnaireVersion,
      'scoringVersion': scoringVersion,
      'userProfile': userProfile,
      'topMatch': topMatch.toJson(),
      'alternatives': alternatives.map((item) => item.toJson()).toList(),
    };
  }
}
