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
    score: dto.score,
    riskLevel: dto.riskLevel,
    summary: dto.summary,
    insights: List<String>.unmodifiable(dto.insights),
    suggestions: dto.suggestions
        .map(
          (s) => CompatibilitySuggestion(
            breedId: s.breedId,
            breedName: s.breedName,
            breedCode: s.breedCode,
            score: s.score,
            riskLevel: s.riskLevel,
            summary: s.summary,
            imageUrl: s.imageUrl,
          ),
        )
        .toList(growable: false),
  );
}
