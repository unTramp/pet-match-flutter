import '../../domain/entities/compatibility.dart';
import '../dto/compatibility_dto.dart';

class CompatibilityMapper {
  const CompatibilityMapper._();

  static CompatibilityStatus _parseStatus(String raw) => switch (raw) {
    'ready' || 'completed' => CompatibilityStatus.ready,
    'processing' ||
    'pending' ||
    'in_progress' => CompatibilityStatus.processing,
    'failed' || 'error' => CompatibilityStatus.failed,
    _ => CompatibilityStatus.unknown,
  };

  static Compatibility fromDto(CompatibilityDto dto) => Compatibility(
    status: _parseStatus(dto.status),
    breedId: dto.breedId,
    breedName: dto.breedName,
    imageUrl: dto.imageUrl,
    score: _normalizeScore(dto.score),
    riskLevel: dto.riskLevel,
    summary: dto.summary,
    insights: List<String>.unmodifiable(dto.insights),
    suggestions: dto.suggestions
        .map(
          (s) => CompatibilitySuggestion(
            breedId: s.breedId,
            breedName: s.breedName,
            breedCode: s.breedCode,
            score: _normalizeScore(s.score),
            riskLevel: s.riskLevel,
            summary: s.summary,
            imageUrl: s.imageUrl,
          ),
        )
        .toList(growable: false),
  );

  /// Реальный API отдаёт score как integer 0..100 (проценты), mock-фикстуры —
  /// как фракцию 0..1. Нормализуем к единому виду 0..1: значения > 1
  /// трактуем как проценты и делим на 100.
  static double? _normalizeScore(double? raw) {
    if (raw == null) return null;
    if (raw > 1) return raw / 100;
    return raw;
  }
}
