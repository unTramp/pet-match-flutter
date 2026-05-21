/// Единая таблица маршрутов приложения. Сначала путь регистрируется в
/// `app_router.dart`, затем UI навигирует через эти константы — это
/// устраняет дублирование литералов и упрощает рефакторинг.
class AppRoutes {
  AppRoutes._();

  static const String welcome = '/welcome';
  static const String intro = '/intro';
  static const String questionnaire = '/questionnaire';
  static const String result = '/result';

  static const String breedPattern = '/breed/:id';
  static const String breedGalleryPattern = '/breed/:id/gallery';

  static String breed(int id) => '/breed/$id';
  static String breedGallery(int id) => '/breed/$id/gallery';
}
