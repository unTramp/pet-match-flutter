import '../../domain/entities/compatibility.dart';
import '../dto/compatibility_dto.dart';

class CompatibilityMapper {
  const CompatibilityMapper._();

  static CompatibilityStatus _parseStatus(String raw) => switch (raw) {
    'ready' || 'completed' => CompatibilityStatus.ready,
    // Это не skip вопроса, а финальный статус compatibility: расчёт конкретной
    // породы пропущен, но сервер уже вернул итоговую подборку в suggestions.
    'skipped' => CompatibilityStatus.skipped,
    'processing' ||
    'pending' ||
    'in_progress' => CompatibilityStatus.processing,
    'failed' || 'error' => CompatibilityStatus.failed,
    _ => CompatibilityStatus.unknown,
  };

  static CompatibilityRisk _parseRisk(String? raw) => switch (raw) {
    'low' => CompatibilityRisk.low,
    'medium' => CompatibilityRisk.medium,
    'high' => CompatibilityRisk.high,
    _ => CompatibilityRisk.unknown,
  };

  static ReasonSeverity _parseSeverity(String raw) =>
      raw == 'hard' ? ReasonSeverity.hard : ReasonSeverity.risk;

  static Compatibility fromDto(CompatibilityDto dto) => Compatibility(
    status: _parseStatus(dto.status),
    breedId: dto.breedId,
    breedName: dto.breedName,
    imageUrl: dto.imageUrl,
    score: _normalizeScore(dto.score),
    risk: _parseRisk(dto.riskLevel),
    compatible: dto.compatible,
    summary: dto.summary,
    insights: List<String>.unmodifiable(dto.insights),
    requirementHighlights: List<String>.unmodifiable(dto.requirementHighlights),
    hardReasons: dto.hardReasons
        .map(
          (r) => CompatibilityReason(
            message: r.message,
            severity: _parseSeverity(r.severity),
            code: r.code,
          ),
        )
        .toList(growable: false),
    risks: dto.risks
        .map(
          (r) => CompatibilityReason(
            message: r.message,
            severity: _parseSeverity(r.severity),
            code: r.code,
          ),
        )
        .toList(growable: false),
    refusal:
        dto.refusal == null
            ? null
            : CompatibilityRefusal(
              title: dto.refusal!.title,
              message: dto.refusal!.externalMessage,
            ),
    suggestions: dto.suggestions
        .map(
          (s) => CompatibilitySuggestion(
            breedId: s.breedId,
            breedName: s.breedName,
            score: _normalizeScore(s.score),
            riskLevel: s.riskLevel,
            summary: s.summary,
            imageUrl: s.imageUrl,
          ),
        )
        .toList(growable: false),
  );

  /// Реальный API отдаёт score как integer 0..100, mock-фикстуры — как
  /// фракцию 0..1. Нормализуем к единому виду 0..1: значения > 1 трактуем
  /// как проценты и делим на 100.
  static double? _normalizeScore(double? raw) {
    if (raw == null) return null;
    if (raw > 1) return raw / 100;
    return raw;
  }
}
