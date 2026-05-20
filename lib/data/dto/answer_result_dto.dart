import 'session_dto.dart';

class AnswerResultDto {
  const AnswerResultDto({required this.session});

  factory AnswerResultDto.fromJson(Map<String, dynamic> json) =>
      AnswerResultDto(
        session: SessionDto.fromJson(json['session'] as Map<String, dynamic>),
      );

  final SessionDto session;
}
