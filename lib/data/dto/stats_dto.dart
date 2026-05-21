class StatsDto {
  const StatsDto({this.answeredCount = 0, this.totalCount = 0});

  factory StatsDto.fromJson(Map<String, dynamic> json) => StatsDto(
    // Реальный API использует *_questions_count, mock — короткие имена.
    // Поддерживаем оба, чтобы один и тот же DTO работал и там и там.
    answeredCount:
        (json['answered_questions_count'] as num?)?.toInt() ??
        (json['answered_count'] as num?)?.toInt() ??
        0,
    totalCount:
        (json['total_questions_count'] as num?)?.toInt() ??
        (json['total_count'] as num?)?.toInt() ??
        0,
  );

  final int answeredCount;
  final int totalCount;
}
