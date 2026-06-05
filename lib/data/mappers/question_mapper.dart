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
    final isOptional = _isOptional(dto);
    final options = (dto.options.toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)))
        .map(OptionMapper.fromDto)
        .toList(growable: false);

    return switch (dto.questionType) {
      'single_choice' => SingleChoiceQuestion(
        id: dto.id,
        title: dto.title,
        helpText: dto.helpText,
        isOptional: isOptional,
        options: options,
      ),
      'multiple_choice' => MultipleChoiceQuestion(
        id: dto.id,
        title: dto.title,
        helpText: dto.helpText,
        isOptional: isOptional,
        options: options,
        exclusiveOptionCodes: _readExclusiveCodes(dto.configJson),
        maxSelections: _readMaxSelections(dto.configJson),
      ),
      // Реальный API возвращает 'search_select' для вопросов с подгрузкой
      // вариантов; mock-фикстуры используют 'dynamic_options'. Поддерживаем оба.
      'dynamic_options' || 'search_select' => DynamicOptionsQuestion(
        id: dto.id,
        title: dto.title,
        helpText: dto.helpText,
        isOptional: isOptional,
      ),
      _ => UnknownQuestion(
        id: dto.id,
        title: dto.title,
        helpText: dto.helpText,
        isOptional: isOptional,
        questionType: dto.questionType,
      ),
    };
  }

  static bool _isOptional(QuestionDto dto) {
    if (dto.isOptional) return true;
    final configJson = dto.configJson;
    if (configJson == null) return false;

    final explicit = _readBool(configJson, const [
      'is_optional',
      'optional',
      'can_skip',
      'skippable',
    ]);
    if (explicit != null) return explicit;

    return false;
  }

  static bool? _readBool(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is bool) return value;
    }
    return null;
  }

  static Set<String> _readExclusiveCodes(Map<String, dynamic>? configJson) {
    if (configJson == null) return const <String>{};
    final raw = configJson['exclusive_option_codes'];
    if (raw is! List) return const <String>{};
    return raw.whereType<String>().toSet();
  }

  static int? _readMaxSelections(Map<String, dynamic>? configJson) {
    if (configJson == null) return null;
    final value = configJson['max_selections'] ?? configJson['maxSelections'];
    return value is num ? value.toInt() : null;
  }
}
