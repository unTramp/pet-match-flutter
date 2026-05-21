import '../../domain/entities/question.dart';
import '../dto/question_dto.dart';
import 'option_mapper.dart';

class QuestionMapper {
  const QuestionMapper._();

  /// DTO → sealed `Question`. Неизвестный `question_type` маппится в
  /// `UnknownQuestion` (а не в SingleChoiceQuestion с пустыми опциями) —
  /// это сохраняет compile-time exhaustive switch в UI И не показывает
  /// пользователю кривой пустой single-choice. UI рендерит explicit fallback
  /// с предложением пропустить.
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
      _ => UnknownQuestion(
        id: dto.id,
        title: dto.title,
        helpText: dto.helpText,
        isOptional: dto.isOptional,
        questionType: dto.questionType,
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
