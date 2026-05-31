import '../../domain/entities/compatibility.dart';

/// Mock-данные для preview-роутов в `app_router.dart` (`/test/result-preview`).
/// Используется только в debug/profile-сборках (conditional registration через
/// `!kReleaseMode` в router'е). В release физически отсутствует в дереве
/// зависимостей — Dart tree-shaking уберёт.
const Compatibility kResultPreviewCompatibility = Compatibility(
  status: CompatibilityStatus.ready,
  breedId: 501,
  breedName: 'Лабрадор-ретривер',
  score: 0.92,
  risk: CompatibilityRisk.low,
  compatible: true,
  summary:
      'Лабрадор — отличный выбор для активной семьи. Дружелюбный, легко '
      'обучается, прекрасно ладит с детьми и другими питомцами.',
  insights: [
    'Подходит для активного образа жизни.',
    'Дружелюбен к детям и другим животным.',
    'Требует регулярных нагрузок и общения.',
  ],
  requirementHighlights: [
    'Активные прогулки 1+ час в день',
    'Минимальный груминг — расчёсывание 2-3 раза в неделю',
    'Подходит для семей с детьми',
  ],
  suggestions: [
    CompatibilitySuggestion(
      breedId: 502,
      breedName: 'Голден-ретривер',
      score: 0.88,
      risk: CompatibilityRisk.low,
      summary: 'Очень близкий по характеру к лабрадору, чуть спокойнее.',
    ),
    CompatibilitySuggestion(
      breedId: 503,
      breedName: 'Бордер-колли',
      score: 0.81,
      risk: CompatibilityRisk.medium,
      summary: 'Очень умная и активная порода. Требует много занятости.',
    ),
    CompatibilitySuggestion(
      breedId: 504,
      breedName: 'Самоед',
      score: 0.79,
      risk: CompatibilityRisk.medium,
      summary:
          'Дружелюбный и семейный, но требует больше ухода за шерстью и общения.',
    ),
  ],
);
