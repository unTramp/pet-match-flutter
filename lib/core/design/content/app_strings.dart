/// Пользовательский текст приложения.
/// Текущий интерфейс сфокусирован на русском сценарии dev API.
class AppStrings {
  AppStrings._();

  static const CommonStrings common = CommonStrings(
    retry: 'Повторить',
    restart: 'Начать заново',
    loadingDefault: 'Загружаем…',
    errorNetwork:
        'Нет подключения к сети. Проверьте интернет и попробуйте снова.',
    errorTimeout: 'Сервер долго не отвечает. Попробуйте позже.',
    errorServer: 'Что-то пошло не так. Попробуйте снова.',
    errorEmpty: 'Нет данных. Попробуйте снова.',
    unknownBreed: 'Порода',
    appBrand: 'PetWise',
    homeSemantic: 'На главный экран',
  );

  static const WelcomeStrings welcome = WelcomeStrings(
    catImageSemantic: 'Иллюстрация кота',
    subtitle:
        'Ответьте на несколько коротких вопросов — и мы подберём породу, '
        'которая подойдёт именно вашему образу жизни.',
    activeSessionHint:
        'Вы уже начали подбор — можно продолжить с последнего вопроса.',
    ctaContinue: 'Продолжить',
    ctaStart: 'Подобрать питомца',
    heroLine1: 'Найдём питомца,\n',
    heroLine2: 'который \nподойдёт\n',
    heroLine3: 'именно вам.',
  );

  static const IntroStrings intro = IntroStrings(
    title: 'Как это работает',
    subtitle: 'Несколько вопросов - и подходящая порода у вас.',
    ctaStart: 'Начать анкету',
    bullet1Title: 'Ответьте на несколько вопросов',
    bullet1Body: 'О вашем образе жизни, жилье и предпочтениях.',
    bullet2Title: 'Получите рекомендацию',
    bullet2Body: 'Подберём породу, которая вам подходит больше всего.',
    bullet3Title: 'Узнайте детали',
    bullet3Body: 'Характер, уход, особенности и фотографии.',
  );

  static const QuestionnaireStrings questionnaire = QuestionnaireStrings(
    loading: 'Загружаем анкету…',
    continueCta: 'Продолжить',
    skipCta: 'Пропустить',
    progressLabel: 'Вопрос',
    progressOf: 'из',
    timeEstimate: 'Это займёт около 1 минуты',
    multiSelectHint: 'Можно выбрать несколько вариантов',
    searchHint: 'Поиск породы',
    searchEmpty: 'Ничего не найдено',
    unsupportedTitle: 'Тип вопроса не поддерживается',
    unsupportedBody:
        'Похоже, эта версия приложения устарела. Если вопрос '
        'опциональный - пропустите его кнопкой ниже. Иначе обновите '
        'приложение и попробуйте снова.',
    exitConfirmTitle: 'Выйти из анкеты?',
    exitConfirmBody: 'Текущие ответы сохранятся — вы сможете продолжить позже.',
    exitConfirmStay: 'Остаться',
    exitConfirmLeave: 'Выйти',
  );

  static const ResultStrings result = ResultStrings(
    summaryTitle: 'Почему эта порода вам подходит',
    scoreLabelPerfect: 'Идеальное совпадение',
    scoreLabelGood: 'Хорошее совпадение',
    scoreLabelMedium: 'Среднее совпадение',
    scoreLabelWeak: 'Слабое совпадение',
    influences: 'Что влияет на совпадение?',
    important: 'Важно',
    refusalTitle: 'Что важно учесть перед выбором',
    insights: 'Что важно знать',
    requirements: 'Требования породы',
    suggestionsTitle: 'Похожие варианты',
    suggestionsSubtitle: 'Альтернативные породы по вашему профилю.',
    suggestionsHint: 'Нажмите на породу, чтобы посмотреть подробнее.',
    suggestionsAction: 'Показать',
    showMore: 'Показать все',
    showLess: 'Свернуть',
    ctaViewBreed: 'Узнать больше',
    ctaViewAlternatives: 'Смотреть альтернативы',
    chipGood: 'Подходит',
    chipMedium: 'С оговорками',
    chipRefused: 'Не рекомендуем',
    emptyTitle: 'Результат пока недоступен',
    emptyBody:
        'Мы не получили данные о подходящих породах. Можно начать анкету заново '
        'или попробовать позже.',
  );

  static const DetailsStrings details = DetailsStrings(
    appBarTitle: 'О породе',
    galleryLabelPrefix: 'Галерея',
    photosSuffix: 'фото',
    matchBadge: 'совпадение',
    ctaBack: 'Вернуться к подбору',
    backSemantic: 'Назад к подбору',
  );

  static const AnalyzingStrings analyzing = AnalyzingStrings(
    title: 'Подбираем породу…',
    subtitle: 'Сравниваем ваши ответы с профилями пород.',
  );
}

class CommonStrings {
  const CommonStrings({
    required this.retry,
    required this.restart,
    required this.loadingDefault,
    required this.errorNetwork,
    required this.errorTimeout,
    required this.errorServer,
    required this.errorEmpty,
    required this.unknownBreed,
    required this.appBrand,
    required this.homeSemantic,
  });

  final String retry;
  final String restart;
  final String loadingDefault;
  final String errorNetwork;
  final String errorTimeout;
  final String errorServer;
  final String errorEmpty;
  final String unknownBreed;
  final String appBrand;
  final String homeSemantic;
}

class WelcomeStrings {
  const WelcomeStrings({
    required this.catImageSemantic,
    required this.subtitle,
    required this.activeSessionHint,
    required this.ctaContinue,
    required this.ctaStart,
    required this.heroLine1,
    required this.heroLine2,
    required this.heroLine3,
  });

  final String catImageSemantic;
  final String subtitle;
  final String activeSessionHint;
  final String ctaContinue;
  final String ctaStart;
  final String heroLine1;
  final String heroLine2;
  final String heroLine3;
}

class IntroStrings {
  const IntroStrings({
    required this.title,
    required this.subtitle,
    required this.ctaStart,
    required this.bullet1Title,
    required this.bullet1Body,
    required this.bullet2Title,
    required this.bullet2Body,
    required this.bullet3Title,
    required this.bullet3Body,
  });

  final String title;
  final String subtitle;
  final String ctaStart;
  final String bullet1Title;
  final String bullet1Body;
  final String bullet2Title;
  final String bullet2Body;
  final String bullet3Title;
  final String bullet3Body;
}

class QuestionnaireStrings {
  const QuestionnaireStrings({
    required this.loading,
    required this.continueCta,
    required this.skipCta,
    required this.progressLabel,
    required this.progressOf,
    required this.timeEstimate,
    required this.multiSelectHint,
    required this.searchHint,
    required this.searchEmpty,
    required this.unsupportedTitle,
    required this.unsupportedBody,
    required this.exitConfirmTitle,
    required this.exitConfirmBody,
    required this.exitConfirmStay,
    required this.exitConfirmLeave,
  });

  final String loading;
  final String continueCta;
  final String skipCta;
  final String progressLabel;
  final String progressOf;
  final String timeEstimate;
  final String multiSelectHint;
  final String searchHint;
  final String searchEmpty;
  final String unsupportedTitle;
  final String unsupportedBody;
  final String exitConfirmTitle;
  final String exitConfirmBody;
  final String exitConfirmStay;
  final String exitConfirmLeave;
}

class ResultStrings {
  const ResultStrings({
    required this.summaryTitle,
    required this.scoreLabelPerfect,
    required this.scoreLabelGood,
    required this.scoreLabelMedium,
    required this.scoreLabelWeak,
    required this.influences,
    required this.important,
    required this.refusalTitle,
    required this.insights,
    required this.requirements,
    required this.suggestionsTitle,
    required this.suggestionsSubtitle,
    required this.suggestionsHint,
    required this.suggestionsAction,
    required this.showMore,
    required this.showLess,
    required this.ctaViewBreed,
    required this.ctaViewAlternatives,
    required this.chipGood,
    required this.chipMedium,
    required this.chipRefused,
    required this.emptyTitle,
    required this.emptyBody,
  });

  final String summaryTitle;
  final String scoreLabelPerfect;
  final String scoreLabelGood;
  final String scoreLabelMedium;
  final String scoreLabelWeak;
  final String influences;
  final String important;
  final String refusalTitle;
  final String insights;
  final String requirements;
  final String suggestionsTitle;
  final String suggestionsSubtitle;
  final String suggestionsHint;
  final String suggestionsAction;
  final String showMore;
  final String showLess;
  final String ctaViewBreed;
  final String ctaViewAlternatives;
  final String chipGood;
  final String chipMedium;
  final String chipRefused;
  final String emptyTitle;
  final String emptyBody;
}

class DetailsStrings {
  const DetailsStrings({
    required this.appBarTitle,
    required this.galleryLabelPrefix,
    required this.photosSuffix,
    required this.matchBadge,
    required this.ctaBack,
    required this.backSemantic,
  });

  final String appBarTitle;
  final String galleryLabelPrefix;
  final String photosSuffix;
  final String matchBadge;
  final String ctaBack;
  final String backSemantic;
}

class AnalyzingStrings {
  const AnalyzingStrings({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}
