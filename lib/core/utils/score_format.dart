/// Форматирует score 0..1 в процентную строку «42%».
/// Для `null` возвращает прочерк, чтобы UI мог рендерить плейсхолдер.
/// Score нормализован в `CompatibilityMapper._normalizeScore` к диапазону 0..1,
/// поэтому здесь умножаем на 100.
String formatScorePercent(double? score) {
  if (score == null) return '—';
  return '${(score * 100).round()}%';
}
