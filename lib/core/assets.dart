/// Централизованные пути ассетов. Используется как `AppAssets.catImage`,
/// `AppAssets.brandIcon`, `AppAssets.mockBreed(501)` — это устраняет
/// рассогласованность строковых литералов между местами загрузки и
/// `pubspec.yaml`.
class AppAssets {
  AppAssets._();

  // Images
  static const String catImage = 'assets/images/cat.png';
  static const String analyzingImage = 'assets/images/analyzing.png';

  // Icons
  static const String brandIcon = 'assets/icons/cathead.svg';
  static const String brandLogo = 'assets/icons/brand_logo.png';
  static const String pawFilled = 'assets/icons/paw_filled.png';
  static const String pawNotFilled = 'assets/icons/paw_not_filled.png';
  static const String stateAnalyzingIcon = 'assets/icons/Analyzing.png';
  static const String stateNetworkFailureIcon =
      'assets/icons/NetworkFailure.png';
  static const String stateServerFailureIcon = 'assets/icons/ServerFailure.png';
  static const String stateTimeoutFailureIcon =
      'assets/icons/TimeOutFailure.png';

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
