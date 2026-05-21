import '../../domain/entities/option.dart';
import '../dto/dynamic_option_dto.dart';
import '../dto/option_dto.dart';

class OptionMapper {
  const OptionMapper._();

  static QuestionOption fromDto(OptionDto dto) =>
      QuestionOption(id: dto.id, code: dto.code, label: dto.label);

  static DynamicOption fromDynamicDto(DynamicOptionDto dto) =>
      DynamicOption(code: dto.code, label: dto.label, sourceType: dto.sourceType);
}
