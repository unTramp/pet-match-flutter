/// Централизованные пути ассетов. Используется как `AppAssets.catImage`,
/// `AppAssets.brandIcon`, `AppAssets.mockBreed(501)` — это устраняет
/// рассогласованность строковых литералов между местами загрузки и
/// `pubspec.yaml`.
class AppAssets {
  AppAssets._();

  // Images
  static const String catImage = 'assets/images/cat.png';

  // Icons
  static const String brandIcon = 'assets/icons/cathead.svg';

  // Mock fixtures (используются только при USE_MOCK=true)
  static const String mockQuestions = 'assets/mock/questions.json';
  static const String mockCompatibilityReady =
      'assets/mock/compatibility_ready.json';
  static const String mockCompatibilityProcessing =
      'assets/mock/compatibility_processing.json';
  static const String mockDynamicOptions =
      'assets/mock/dynamic_options_preferred_breed.json';

  static String mockBreed(int breedId) => 'assets/mock/breed_$breedId.json';

  /// Fallback-фикстура, если конкретного breed-файла нет.
  static const String mockBreedFallback = 'assets/mock/breed_501.json';
}
