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
            breedId: 'golden_retriever',
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
            breedId: 'golden_retriever',
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

    test('"skipped" → CompatibilityStatus.skipped и isReady=true', () {
      const dto = CompatibilityDto(
        status: 'skipped',
        summary: 'Подборка вариантов без выбранной породы.',
        suggestions: [
          CompatibilitySuggestionDto(
            breedId: 'scottish_straight',
            breedName: 'Скоттиш Страйт',
          ),
        ],
      );

      final result = CompatibilityMapper.fromDto(dto);

      expect(result.status, CompatibilityStatus.skipped);
      expect(result.isReady, isTrue);
      expect(result.suggestions, hasLength(1));
    });

    test('unknown string → CompatibilityStatus.unknown', () {
      const dto = CompatibilityDto(status: 'something-else');
      expect(
        CompatibilityMapper.fromDto(dto).status,
        CompatibilityStatus.unknown,
      );
    });
  });

  group('CompatibilityMapper расширенные поля', () {
    test('compatible=false + hard_reasons маппятся корректно', () {
      const dto = CompatibilityDto(
        status: 'completed',
        breedName: 'Бельгийская овчарка',
        compatible: false,
        riskLevel: 'high',
        hardReasons: [
          CompatibilityReasonDto(
            code: 'no-experience',
            severity: 'hard',
            message: 'Отсутствие опыта повышает чувствительность.',
          ),
        ],
        risks: [
          CompatibilityReasonDto(
            code: 'low-activity',
            severity: 'risk',
            message: 'Менее часа в день — низкая активность.',
          ),
        ],
      );

      final result = CompatibilityMapper.fromDto(dto);

      expect(result.compatible, isFalse);
      expect(result.risk, CompatibilityRisk.high);
      expect(result.hardReasons, hasLength(1));
      expect(result.hardReasons.first.severity, ReasonSeverity.hard);
      expect(result.risks, hasLength(1));
      expect(result.risks.first.severity, ReasonSeverity.risk);
    });

    test('refusal маппится в entity со всеми полями', () {
      const dto = CompatibilityDto(
        status: 'completed',
        breedName: 'X',
        refusal: CompatibilityRefusalDto(
          title: 'Почему сейчас не рекомендуем',
          externalMessage: 'Длинный текст обоснования…',
        ),
      );

      final result = CompatibilityMapper.fromDto(dto);

      expect(result.refusal, isNotNull);
      expect(result.refusal!.title, 'Почему сейчас не рекомендуем');
      expect(result.refusal!.message, 'Длинный текст обоснования…');
    });

    test('risk_level=medium → CompatibilityRisk.medium', () {
      const dto = CompatibilityDto(
        status: 'completed',
        breedName: 'X',
        compatible: true,
        riskLevel: 'medium',
      );

      final result = CompatibilityMapper.fromDto(dto);

      expect(result.risk, CompatibilityRisk.medium);
    });

    test('requirement_highlights пробрасываются', () {
      const dto = CompatibilityDto(
        status: 'completed',
        breedName: 'X',
        requirementHighlights: ['Активные прогулки', 'Минимум груминга'],
      );

      final result = CompatibilityMapper.fromDto(dto);

      expect(result.requirementHighlights, [
        'Активные прогулки',
        'Минимум груминга',
      ]);
    });
  });
}
