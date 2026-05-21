class AppStrings {
  AppStrings._();

  static const common = _CommonStrings();
  static const welcome = _WelcomeStrings();
  static const intro = _IntroStrings();
  static const questionnaire = _QuestionnaireStrings();
  static const analyzing = _AnalyzingStrings();
  static const result = _ResultStrings();
  static const details = _DetailsStrings();
}

class _CommonStrings {
  const _CommonStrings();

  final String retry = 'Повторить';
  final String restart = 'Начать заново';
  final String loadingDefault = 'Загружаем…';
  final String errorNetwork =
      'Нет подключения к сети. Проверьте интернет и попробуйте снова.';
  final String errorTimeout = 'Сервер долго не отвечает. Попробуйте позже.';
  final String errorServer = 'Что-то пошло не так. Попробуйте снова.';
  final String errorEmpty = 'Нет данных. Попробуйте снова.';
}

class _WelcomeStrings {
  const _WelcomeStrings();

  final String catImageSemantic = 'Иллюстрация кота';
  final String subtitle =
      'Несколько коротких вопросов о вашем образе жизни '
      '— и мы покажем, какие породы подойдут именно вам.';
  final String ctaContinue = 'Продолжить';
  final String ctaStart = 'Подобрать питомца';
  final String heroLine1 = 'Найдём питомца,\n';
  final String heroLine2 = 'который \nподойдёт\n';
  final String heroLine3 = 'именно вам.';
}

class _IntroStrings {
  const _IntroStrings();

  final String title = 'Как это работает';
  final String subtitle = 'Несколько вопросов — и подходящая порода у вас.';
  final String ctaStart = 'Начать анкету';
  final String bullet1Title = 'Ответьте на несколько вопросов';
  final String bullet1Body = 'О вашем образе жизни, жилье и предпочтениях.';
  final String bullet2Title = 'Получите рекомендацию';
  final String bullet2Body = 'Подберём породу, которая вам подходит больше всего.';
  final String bullet3Title = 'Узнайте детали';
  final String bullet3Body = 'Характер, уход, особенности и фотографии.';
}

class _QuestionnaireStrings {
  const _QuestionnaireStrings();

  final String appBarTitle = 'Анкета';
  final String loading = 'Загружаем анкету…';
  final String privacy = 'Ваши ответы конфиденциальны';
  final String continueCta = 'Продолжить';
  final String skipCta = 'Пропустить';
  final String progressLabel = 'Вопрос';
  final String stepTypeSingle = 'Один вариант';
  final String stepTypeMultiple = 'Несколько вариантов';
  final String stepTypeSearch = 'Поиск по списку';
  final String searchHint = 'Поиск породы';
  final String searchEmpty = 'Ничего не найдено';
  final String unsupportedTitle = 'Тип вопроса не поддерживается';
  final String unsupportedBody =
      'Похоже, эта версия приложения устарела. Если вопрос '
      'опциональный — пропустите его кнопкой ниже. Иначе обновите '
      'приложение и попробуйте снова.';
}

class _AnalyzingStrings {
  const _AnalyzingStrings();

  final String title = 'Анализируем ответы';
  final String subtitle = 'Подбираем подходящую породу под ваш профиль…';
}

class _ResultStrings {
  const _ResultStrings();

  final String appBarTitle = 'Результат';
  final String influences = 'Что влияет на совпадение?';
  final String important = 'Важно';
  final String refusalTitle = 'Что важно учесть перед выбором';
  final String insights = 'Что важно знать';
  final String requirements = 'Требования породы';
  final String suggestionsTitle = 'Похожие варианты';
  final String suggestionsSubtitle = 'Альтернативные породы по вашему профилю.';
  final String showMore = 'Показать все';
  final String showLess = 'Свернуть';
  final String ctaViewBreed = 'Подробнее о породе';
  final String ctaViewAlternatives = 'Смотреть альтернативы';
  final String chipGood = 'Подходит';
  final String chipMedium = 'С оговорками';
  final String chipRefused = 'Не рекомендуем';
}

class _DetailsStrings {
  const _DetailsStrings();

  final String appBarTitle = 'О породе';
  final String galleryLabelPrefix = 'Галерея';
  final String photosSuffix = 'фото';
}
