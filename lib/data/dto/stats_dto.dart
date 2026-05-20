class StatsDto {
  const StatsDto({
    this.answeredCount = 0,
    this.totalCount = 0,
    this.progressPercent,
    this.status,
  });

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
    progressPercent: (json['progress_percent'] as num?)?.toDouble(),
    status: json['status'] as String?,
  );

  final int answeredCount;
  final int totalCount;
  final double? progressPercent;
  final String? status;

  Map<String, dynamic> toJson() => {
    'answered_count': answeredCount,
    'total_count': totalCount,
    if (progressPercent != null) 'progress_percent': progressPercent,
    if (status != null) 'status': status,
  };
}
