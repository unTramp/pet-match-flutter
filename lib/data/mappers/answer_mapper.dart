import '../../domain/entities/answer.dart';
import '../dto/answer_submit_dto.dart';

class AnswerMapper {
  const AnswerMapper._();

  static AnswerSubmitDto toDto(UserAnswer answer) => switch (answer) {
    SingleAnswer(:final questionId, :final optionId) => AnswerSubmitDto(
      questionId: questionId,
      optionId: optionId,
    ),
    MultipleAnswer(:final questionId, :final optionIds) => AnswerSubmitDto(
      questionId: questionId,
      optionIds: optionIds.toList(growable: false),
    ),
    DynamicAnswer(
      :final questionId,
      :final code,
      :final label,
      :final sourceType,
    ) =>
      AnswerSubmitDto(
        questionId: questionId,
        selectedValue: <String, dynamic>{
          if (sourceType != null) 'source_type': sourceType,
          'code': code,
          'label': label,
        },
      ),
  };
}
