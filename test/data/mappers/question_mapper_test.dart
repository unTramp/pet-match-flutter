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

    test('unknown question type → fallback SingleChoice (no crash)', () {
      const dto = QuestionDto(
        id: 4,
        title: 'Странный вопрос',
        questionType: 'totally_unknown_type',
      );

      final result = QuestionMapper.fromDto(dto);

      expect(result, isA<SingleChoiceQuestion>());
      expect((result as SingleChoiceQuestion).options, isEmpty);
    });

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
