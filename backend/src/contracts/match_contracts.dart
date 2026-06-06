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

class CompatibilityReasonResponse {
  const CompatibilityReasonResponse({
    required this.code,
    required this.severity,
    required this.message,
  });

  final String code;
  final String severity;
  final String message;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'severity': severity,
      'message': message,
    };
  }
}

class CompatibilityRefusalResponse {
  const CompatibilityRefusalResponse({this.title, this.externalMessage});

  final String? title;
  final String? externalMessage;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'external_message': externalMessage,
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

class CompatibilitySuggestionResponse {
  const CompatibilitySuggestionResponse({
    required this.breedId,
    required this.breedName,
    this.riskLevel,
    this.score,
    this.summary,
    this.imageUrl,
    this.storyAvatarUrl,
  });

  final String breedId;
  final String breedName;
  final String? riskLevel;
  final int? score;
  final String? summary;
  final String? imageUrl;
  final String? storyAvatarUrl;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'breed_id': breedId,
      'breed_name': breedName,
      'risk_level': riskLevel,
      'score': score,
      'summary': summary,
      'image_url': imageUrl,
      'story_avatar_url': storyAvatarUrl,
    };
  }
}

class CompatibilityViewResponse {
  const CompatibilityViewResponse({
    required this.status,
    this.breedId,
    this.breedName,
    this.imageUrl,
    this.storyAvatarUrl,
    this.riskLevel,
    this.score,
    this.summary,
    this.compatible,
    required this.insights,
    required this.requirementHighlights,
    required this.hardReasons,
    required this.risks,
    this.refusal,
    required this.suggestions,
  });

  final String status;
  final String? breedId;
  final String? breedName;
  final String? imageUrl;
  final String? storyAvatarUrl;
  final String? riskLevel;
  final int? score;
  final String? summary;
  final bool? compatible;
  final List<String> insights;
  final List<String> requirementHighlights;
  final List<CompatibilityReasonResponse> hardReasons;
  final List<CompatibilityReasonResponse> risks;
  final CompatibilityRefusalResponse? refusal;
  final List<CompatibilitySuggestionResponse> suggestions;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'status': status,
      'breed_id': breedId,
      'breed_name': breedName,
      'image_url': imageUrl,
      'story_avatar_url': storyAvatarUrl,
      'risk_level': riskLevel,
      'score': score,
      'summary': summary,
      'compatible': compatible,
      'insights': insights,
      'requirement_highlights': requirementHighlights,
      'hard_reasons': hardReasons.map((item) => item.toJson()).toList(),
      'risks': risks.map((item) => item.toJson()).toList(),
      'refusal': refusal?.toJson(),
      'suggestions': suggestions.map((item) => item.toJson()).toList(),
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
    required this.compatibility,
    this.refusal,
  });

  final String resultId;
  final String storedAt;
  final int questionnaireVersion;
  final int scoringVersion;
  final Map<String, dynamic> userProfile;
  final RankedBreedResponse? topMatch;
  final List<AlternativeBreedResponse> alternatives;
  final CompatibilityViewResponse compatibility;
  final MatchRefusalResponse? refusal;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'resultId': resultId,
      'storedAt': storedAt,
      'questionnaireVersion': questionnaireVersion,
      'scoringVersion': scoringVersion,
      'userProfile': userProfile,
      'topMatch': topMatch?.toJson(),
      'alternatives': alternatives.map((item) => item.toJson()).toList(),
      'compatibility': compatibility.toJson(),
      'refusal': refusal?.toJson(),
    };
  }
}

class MatchRefusalResponse {
  const MatchRefusalResponse({
    required this.code,
    required this.message,
    this.title,
    this.externalMessage,
  });

  final String code;
  final String message;
  final String? title;
  final String? externalMessage;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code,
      'message': message,
      'title': title,
      'externalMessage': externalMessage ?? message,
    };
  }
}
