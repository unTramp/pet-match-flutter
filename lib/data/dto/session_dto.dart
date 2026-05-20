import 'compatibility_dto.dart';
import 'question_dto.dart';
import 'stats_dto.dart';
import 'user_summary_dto.dart';

class SessionDto {
  const SessionDto({
    required this.user,
    required this.stats,
    this.nextQuestion,
    this.compatibility,
    this.isNewUser = false,
    this.isNewProfile = false,
  });

  factory SessionDto.fromJson(Map<String, dynamic> json) => SessionDto(
    user: UserSummaryDto.fromJson(json['user'] as Map<String, dynamic>),
    stats: StatsDto.fromJson(
      json['stats'] as Map<String, dynamic>? ?? const <String, dynamic>{},
    ),
    nextQuestion:
        json['next_question'] != null
            ? QuestionDto.fromJson(
              json['next_question'] as Map<String, dynamic>,
            )
            : null,
    compatibility:
        json['compatibility'] != null
            ? CompatibilityDto.fromJson(
              json['compatibility'] as Map<String, dynamic>,
            )
            : null,
    isNewUser: json['is_new_user'] as bool? ?? false,
    isNewProfile: json['is_new_profile'] as bool? ?? false,
  );

  final UserSummaryDto user;
  final StatsDto stats;
  final QuestionDto? nextQuestion;
  final CompatibilityDto? compatibility;
  final bool isNewUser;
  final bool isNewProfile;
}
