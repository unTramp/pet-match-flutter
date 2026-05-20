import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/data/dto/compatibility_dto.dart';
import 'package:pet_match/data/mappers/compatibility_mapper.dart';
import 'package:pet_match/domain/entities/compatibility.dart';

void main() {
  group('CompatibilityMapper score normalization', () {
    test('integer 0..100 from real API → fraction 0..1', () {
      const dto = CompatibilityDto(
        status: 'ready',
        breedName: 'Лабрадор',
        score: 85,
        suggestions: [
          CompatibilitySuggestionDto(
            breedId: 2,
            breedName: 'Голден',
            score: 72,
          ),
        ],
      );

      final result = CompatibilityMapper.fromDto(dto);

      expect(result.score, 0.85);
      expect(result.suggestions.first.score, 0.72);
    });

    test('fraction 0..1 from mock → passes through unchanged', () {
      const dto = CompatibilityDto(
        status: 'ready',
        breedName: 'Лабрадор',
        score: 0.92,
        suggestions: [
          CompatibilitySuggestionDto(
            breedId: 2,
            breedName: 'Голден',
            score: 0.88,
          ),
        ],
      );

      final result = CompatibilityMapper.fromDto(dto);

      expect(result.score, 0.92);
      expect(result.suggestions.first.score, 0.88);
    });

    test('null score → null', () {
      const dto = CompatibilityDto(status: 'ready');
      final result = CompatibilityMapper.fromDto(dto);
      expect(result.score, isNull);
    });
  });

  group('CompatibilityMapper status parsing', () {
    test('"ready" → CompatibilityStatus.ready', () {
      const dto = CompatibilityDto(status: 'ready');
      expect(
        CompatibilityMapper.fromDto(dto).status,
        CompatibilityStatus.ready,
      );
    });

    test('"processing" → CompatibilityStatus.processing', () {
      const dto = CompatibilityDto(status: 'processing');
      expect(
        CompatibilityMapper.fromDto(dto).status,
        CompatibilityStatus.processing,
      );
    });

    test('unknown string → CompatibilityStatus.unknown', () {
      const dto = CompatibilityDto(status: 'something-else');
      expect(
        CompatibilityMapper.fromDto(dto).status,
        CompatibilityStatus.unknown,
      );
    });
  });
}
