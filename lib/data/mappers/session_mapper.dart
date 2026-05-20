import '../../domain/entities/progress.dart';
import '../../domain/entities/session.dart';
import '../dto/session_dto.dart';
import 'compatibility_mapper.dart';
import 'question_mapper.dart';

class SessionMapper {
  const SessionMapper._();

  static Session fromDto(SessionDto dto) {
    final nextQuestion = dto.nextQuestion;
    final compatibility = dto.compatibility;
    return Session(
      userId: dto.user.id,
      progress: Progress(
        answered: dto.stats.answeredCount,
        total: dto.stats.totalCount,
      ),
      nextQuestion:
          nextQuestion != null ? QuestionMapper.fromDto(nextQuestion) : null,
      compatibility:
          compatibility != null
              ? CompatibilityMapper.fromDto(compatibility)
              : null,
    );
  }
}
