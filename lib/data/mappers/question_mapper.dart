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
        exclusiveOptionCodes: _readExclusiveCodes(dto.configJson),
      ),
      // Реальный API возвращает 'search_select' для вопросов с подгрузкой
      // вариантов; mock-фикстуры используют 'dynamic_options'. Поддерживаем оба.
      'dynamic_options' || 'search_select' => DynamicOptionsQuestion(
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

  static Set<String> _readExclusiveCodes(Map<String, dynamic>? configJson) {
    if (configJson == null) return const <String>{};
    final raw = configJson['exclusive_option_codes'];
    if (raw is! List) return const <String>{};
    return raw.whereType<String>().toSet();
  }
}
