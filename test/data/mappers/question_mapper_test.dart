import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/data/dto/option_dto.dart';
import 'package:pet_match/data/dto/question_dto.dart';
import 'package:pet_match/data/mappers/question_mapper.dart';
import 'package:pet_match/domain/entities/question.dart';

void main() {
  group('QuestionMapper.fromDto', () {
    test('single_choice → SingleChoiceQuestion with sorted options', () {
      const dto = QuestionDto(
        id: 1,
        title: 'Какой питомец?',
        questionType: 'single_choice',
        options: [
          OptionDto(id: 11, code: 'cat', label: 'Кошка', sortOrder: 2),
          OptionDto(id: 10, code: 'dog', label: 'Собака', sortOrder: 1),
        ],
      );

      final result = QuestionMapper.fromDto(dto);

      expect(result, isA<SingleChoiceQuestion>());
      final q = result as SingleChoiceQuestion;
      expect(q.options.first.label, 'Собака');
      expect(q.options.last.label, 'Кошка');
    });

    test('multiple_choice → MultipleChoiceQuestion', () {
      const dto = QuestionDto(
        id: 2,
        title: 'Что важно?',
        questionType: 'multiple_choice',
        options: [
          OptionDto(id: 1, code: 'a', label: 'A'),
          OptionDto(id: 2, code: 'b', label: 'B'),
        ],
      );

      final result = QuestionMapper.fromDto(dto);

      expect(result, isA<MultipleChoiceQuestion>());
      expect((result as MultipleChoiceQuestion).options, hasLength(2));
    });

    test('dynamic_options → DynamicOptionsQuestion (options ignored)', () {
      const dto = QuestionDto(
        id: 3,
        title: 'Какая порода?',
        questionType: 'dynamic_options',
      );

      final result = QuestionMapper.fromDto(dto);

      expect(result, isA<DynamicOptionsQuestion>());
    });

    test('search_select (real API name) → DynamicOptionsQuestion', () {
      const dto = QuestionDto(
        id: 41,
        title: 'Какая порода собаки вам ближе?',
        questionType: 'search_select',
      );

      final result = QuestionMapper.fromDto(dto);

      expect(result, isA<DynamicOptionsQuestion>());
    });

    test('exclusive_option_codes пробрасываются в MultipleChoiceQuestion', () {
      const dto = QuestionDto(
        id: 8,
        title: 'Есть ли у вас другие питомцы?',
        questionType: 'multiple_choice',
        options: [
          OptionDto(id: 29, code: 'people-q-008-option-01', label: 'Нет'),
          OptionDto(id: 30, code: 'people-q-008-option-02', label: 'Собака'),
        ],
        configJson: {
          'exclusive_option_codes': ['people-q-008-option-01'],
        },
      );

      final result = QuestionMapper.fromDto(dto);

      expect(result, isA<MultipleChoiceQuestion>());
      expect((result as MultipleChoiceQuestion).exclusiveOptionCodes, {
        'people-q-008-option-01',
      });
    });

    test('multiple_choice без config_json → пустой набор exclusive', () {
      const dto = QuestionDto(
        id: 9,
        title: 'Какие качества важны?',
        questionType: 'multiple_choice',
        options: [OptionDto(id: 1, code: 'a', label: 'A')],
      );

      final result = QuestionMapper.fromDto(dto) as MultipleChoiceQuestion;

      expect(result.exclusiveOptionCodes, isEmpty);
    });

    test(
      'unknown question_type → UnknownQuestion (not silent SingleChoice)',
      () {
        const dto = QuestionDto(
          id: 4,
          title: 'Странный вопрос',
          questionType: 'slider_input',
        );

        final result = QuestionMapper.fromDto(dto);

        // Раньше fallback был SingleChoiceQuestion с пустыми options —
        // пользователь видел кривой пустой single-choice и мог отправить
        // некорректный ответ. Теперь явный UnknownQuestion — UI рендерит
        // понятное «не поддерживается» и блокирует submit.
        expect(result, isA<UnknownQuestion>());
        expect((result as UnknownQuestion).questionType, 'slider_input');
      },
    );

    test('isOptional + helpText пробрасываются', () {
      const dto = QuestionDto(
        id: 5,
        title: 'Аллергии?',
        questionType: 'single_choice',
        isOptional: true,
        helpText: 'Можно пропустить',
      );

      final result = QuestionMapper.fromDto(dto);

      expect(result.isOptional, isTrue);
      expect(result.helpText, 'Можно пропустить');
    });
  });
}
