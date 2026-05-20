import '../../domain/entities/question.dart';
import '../dto/question_dto.dart';
import 'option_mapper.dart';

class QuestionMapper {
  const QuestionMapper._();

  /// DTO → sealed `Question`. Неизвестный `question_type` маппится на
  /// `SingleChoiceQuestion` с пустым списком опций (fallback), чтобы новые типы
  /// вопросов на бэкенде не роняли приложение.
  static Question fromDto(QuestionDto dto) {
    final options = (dto.options.toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
        .map(OptionMapper.fromDto)
        .toList(growable: false);

    return switch (dto.questionType) {
      'single_choice' => SingleChoiceQuestion(
        id: dto.id,
        title: dto.title,
        helpText: dto.helpText,
        isOptional: dto.isOptional,
        options: options,
      ),
      'multiple_choice' => MultipleChoiceQuestion(
        id: dto.id,
        title: dto.title,
        helpText: dto.helpText,
        isOptional: dto.isOptional,
        options: options,
      ),
      'dynamic_options' => DynamicOptionsQuestion(
        id: dto.id,
        title: dto.title,
        helpText: dto.helpText,
        isOptional: dto.isOptional,
      ),
      _ => SingleChoiceQuestion(
        id: dto.id,
        title: dto.title,
        helpText: dto.helpText,
        isOptional: dto.isOptional,
        options: options,
      ),
    };
  }
}
