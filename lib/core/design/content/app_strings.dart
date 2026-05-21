import '../../locale/app_locale_controller.dart';

class AppStrings {
  AppStrings._();

  static LocalizedStrings get _s =>
      AppLocaleController.instance.current == AppLanguage.en ? _en : _ru;

  static final common = SectionProxy<CommonStrings>((s) => s.common);
  static final welcome = SectionProxy<WelcomeStrings>((s) => s.welcome);
  static final intro = SectionProxy<IntroStrings>((s) => s.intro);
  static final questionnaire = SectionProxy<QuestionnaireStrings>(
    (s) => s.questionnaire,
  );
  static final result = SectionProxy<ResultStrings>((s) => s.result);
  static final details = SectionProxy<DetailsStrings>((s) => s.details);

  static const _ru = LocalizedStrings(
    common: CommonStrings(
      retry: 'Повторить',
      restart: 'Начать заново',
      loadingDefault: 'Загружаем…',
      errorNetwork:
          'Нет подключения к сети. Проверьте интернет и попробуйте снова.',
      errorTimeout: 'Сервер долго не отвечает. Попробуйте позже.',
      errorServer: 'Что-то пошло не так. Попробуйте снова.',
      errorEmpty: 'Нет данных. Попробуйте снова.',
      homeTooltip: 'Домой',
      unknownBreed: 'Порода',
      appBrand: 'PET MATCH AI',
    ),
    welcome: WelcomeStrings(
      catImageSemantic: 'Иллюстрация кота',
      subtitle:
          'Несколько коротких вопросов о вашем образе жизни - '
          'и мы покажем, какие породы подойдут именно вам.',
      ctaContinue: 'Продолжить',
      ctaStart: 'Подобрать питомца',
      heroLine1: 'Найдём питомца,\n',
      heroLine2: 'который \nподойдёт\n',
      heroLine3: 'именно вам.',
    ),
    intro: IntroStrings(
      title: 'Как это работает',
      subtitle: 'Несколько вопросов - и подходящая порода у вас.',
      ctaStart: 'Начать анкету',
      bullet1Title: 'Ответьте на несколько вопросов',
      bullet1Body: 'О вашем образе жизни, жилье и предпочтениях.',
      bullet2Title: 'Получите рекомендацию',
      bullet2Body: 'Подберём породу, которая вам подходит больше всего.',
      bullet3Title: 'Узнайте детали',
      bullet3Body: 'Характер, уход, особенности и фотографии.',
    ),
    questionnaire: QuestionnaireStrings(
      appBarTitle: 'Анкета',
      loading: 'Загружаем анкету…',
      continueCta: 'Продолжить',
      skipCta: 'Пропустить',
      progressLabel: 'Вопрос',
      progressOf: 'из',
      multiSelectHint: 'Можно выбрать несколько вариантов',
      searchHint: 'Поиск породы',
      searchEmpty: 'Ничего не найдено',
      exitDialogTitle: 'Выйти из анкеты?',
      exitDialogMessage:
          'Текущий прогресс останется сохранён, и вы сможете продолжить позже.',
      exitDialogConfirm: 'Выйти',
      exitDialogCancel: 'Остаться',
      unsupportedTitle: 'Тип вопроса не поддерживается',
      unsupportedBody:
          'Похоже, эта версия приложения устарела. Если вопрос '
          'опциональный - пропустите его кнопкой ниже. Иначе обновите '
          'приложение и попробуйте снова.',
    ),
    result: ResultStrings(
      appBarTitle: 'Результат',
      influences: 'Что влияет на совпадение?',
      important: 'Важно',
      refusalTitle: 'Что важно учесть перед выбором',
      insights: 'Что важно знать',
      requirements: 'Требования породы',
      suggestionsTitle: 'Похожие варианты',
      suggestionsSubtitle: 'Альтернативные породы по вашему профилю.',
      showMore: 'Показать все',
      showLess: 'Свернуть',
      ctaViewBreed: 'Подробнее о породе',
      ctaViewAlternatives: 'Смотреть альтернативы',
      chipGood: 'Подходит',
      chipMedium: 'С оговорками',
      chipRefused: 'Не рекомендуем',
    ),
    details: DetailsStrings(
      appBarTitle: 'О породе',
      galleryLabelPrefix: 'Галерея',
      photosSuffix: 'фото',
    ),
  );

  static const _en = LocalizedStrings(
    common: CommonStrings(
      retry: 'Retry',
      restart: 'Start over',
      loadingDefault: 'Loading...',
      errorNetwork: 'No internet connection. Check your network and try again.',
      errorTimeout: 'The server is taking too long. Please try later.',
      errorServer: 'Something went wrong. Please try again.',
      errorEmpty: 'No data available. Please try again.',
      homeTooltip: 'Home',
      unknownBreed: 'Breed',
      appBrand: 'PET MATCH AI',
    ),
    welcome: WelcomeStrings(
      catImageSemantic: 'Cat illustration',
      subtitle:
          'Answer a few short questions about your lifestyle - '
          'and we will show which breeds fit you best.',
      ctaContinue: 'Continue',
      ctaStart: 'Find a pet',
      heroLine1: 'Find a pet\n',
      heroLine2: 'that fits\n',
      heroLine3: 'your life.',
    ),
    intro: IntroStrings(
      title: 'How it works',
      subtitle: 'A few questions - and your matching breed is ready.',
      ctaStart: 'Start questionnaire',
      bullet1Title: 'Answer a few questions',
      bullet1Body: 'About your lifestyle, home and preferences.',
      bullet2Title: 'Get a recommendation',
      bullet2Body: 'We will pick the breed that fits you best.',
      bullet3Title: 'Explore the details',
      bullet3Body: 'Temperament, care, traits and photos.',
    ),
    questionnaire: QuestionnaireStrings(
      appBarTitle: 'Questionnaire',
      loading: 'Loading questionnaire...',
      continueCta: 'Continue',
      skipCta: 'Skip',
      progressLabel: 'Question',
      progressOf: 'of',
      multiSelectHint: 'You can choose multiple options',
      searchHint: 'Search breed',
      searchEmpty: 'Nothing found',
      exitDialogTitle: 'Exit questionnaire?',
      exitDialogMessage:
          'Your progress will stay saved, so you can continue later.',
      exitDialogConfirm: 'Exit',
      exitDialogCancel: 'Stay',
      unsupportedTitle: 'Question type is not supported',
      unsupportedBody:
          'This app version may be outdated. If the question is optional, '
          'skip it with the button below. Otherwise update the app and try '
          'again.',
    ),
    result: ResultStrings(
      appBarTitle: 'Result',
      influences: 'What affects the match?',
      important: 'Important',
      refusalTitle: 'What to consider before choosing',
      insights: 'Good to know',
      requirements: 'Breed requirements',
      suggestionsTitle: 'Similar options',
      suggestionsSubtitle: 'Alternative breeds based on your profile.',
      showMore: 'Show all',
      showLess: 'Collapse',
      ctaViewBreed: 'Breed details',
      ctaViewAlternatives: 'View alternatives',
      chipGood: 'Good fit',
      chipMedium: 'With notes',
      chipRefused: 'Not recommended',
    ),
    details: DetailsStrings(
      appBarTitle: 'About breed',
      galleryLabelPrefix: 'Gallery',
      photosSuffix: 'photos',
    ),
  );
}

class SectionProxy<T> {
  const SectionProxy(this._select);

  final T Function(LocalizedStrings strings) _select;

  T get current => _select(AppStrings._s);
}

extension CommonStringsProxy on SectionProxy<CommonStrings> {
  String get retry => current.retry;
  String get restart => current.restart;
  String get loadingDefault => current.loadingDefault;
  String get errorNetwork => current.errorNetwork;
  String get errorTimeout => current.errorTimeout;
  String get errorServer => current.errorServer;
  String get errorEmpty => current.errorEmpty;
  String get homeTooltip => current.homeTooltip;
  String get unknownBreed => current.unknownBreed;
  String get appBrand => current.appBrand;
}

extension WelcomeStringsProxy on SectionProxy<WelcomeStrings> {
  String get catImageSemantic => current.catImageSemantic;
  String get subtitle => current.subtitle;
  String get ctaContinue => current.ctaContinue;
  String get ctaStart => current.ctaStart;
  String get heroLine1 => current.heroLine1;
  String get heroLine2 => current.heroLine2;
  String get heroLine3 => current.heroLine3;
}

extension IntroStringsProxy on SectionProxy<IntroStrings> {
  String get title => current.title;
  String get subtitle => current.subtitle;
  String get ctaStart => current.ctaStart;
  String get bullet1Title => current.bullet1Title;
  String get bullet1Body => current.bullet1Body;
  String get bullet2Title => current.bullet2Title;
  String get bullet2Body => current.bullet2Body;
  String get bullet3Title => current.bullet3Title;
  String get bullet3Body => current.bullet3Body;
}

extension QuestionnaireStringsProxy on SectionProxy<QuestionnaireStrings> {
  String get appBarTitle => current.appBarTitle;
  String get loading => current.loading;
  String get continueCta => current.continueCta;
  String get skipCta => current.skipCta;
  String get progressLabel => current.progressLabel;
  String get progressOf => current.progressOf;
  String get multiSelectHint => current.multiSelectHint;
  String get searchHint => current.searchHint;
  String get searchEmpty => current.searchEmpty;
  String get exitDialogTitle => current.exitDialogTitle;
  String get exitDialogMessage => current.exitDialogMessage;
  String get exitDialogConfirm => current.exitDialogConfirm;
  String get exitDialogCancel => current.exitDialogCancel;
  String get unsupportedTitle => current.unsupportedTitle;
  String get unsupportedBody => current.unsupportedBody;
}

extension ResultStringsProxy on SectionProxy<ResultStrings> {
  String get appBarTitle => current.appBarTitle;
  String get influences => current.influences;
  String get important => current.important;
  String get refusalTitle => current.refusalTitle;
  String get insights => current.insights;
  String get requirements => current.requirements;
  String get suggestionsTitle => current.suggestionsTitle;
  String get suggestionsSubtitle => current.suggestionsSubtitle;
  String get showMore => current.showMore;
  String get showLess => current.showLess;
  String get ctaViewBreed => current.ctaViewBreed;
  String get ctaViewAlternatives => current.ctaViewAlternatives;
  String get chipGood => current.chipGood;
  String get chipMedium => current.chipMedium;
  String get chipRefused => current.chipRefused;
}

extension DetailsStringsProxy on SectionProxy<DetailsStrings> {
  String get appBarTitle => current.appBarTitle;
  String get galleryLabelPrefix => current.galleryLabelPrefix;
  String get photosSuffix => current.photosSuffix;
}

class LocalizedStrings {
  const LocalizedStrings({
    required this.common,
    required this.welcome,
    required this.intro,
    required this.questionnaire,
    required this.result,
    required this.details,
  });

  final CommonStrings common;
  final WelcomeStrings welcome;
  final IntroStrings intro;
  final QuestionnaireStrings questionnaire;
  final ResultStrings result;
  final DetailsStrings details;
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
    required this.homeTooltip,
    required this.unknownBreed,
    required this.appBrand,
  });

  final String retry;
  final String restart;
  final String loadingDefault;
  final String errorNetwork;
  final String errorTimeout;
  final String errorServer;
  final String errorEmpty;
  final String homeTooltip;
  final String unknownBreed;
  final String appBrand;
}

class WelcomeStrings {
  const WelcomeStrings({
    required this.catImageSemantic,
    required this.subtitle,
    required this.ctaContinue,
    required this.ctaStart,
    required this.heroLine1,
    required this.heroLine2,
    required this.heroLine3,
  });

  final String catImageSemantic;
  final String subtitle;
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
    required this.appBarTitle,
    required this.loading,
    required this.continueCta,
    required this.skipCta,
    required this.progressLabel,
    required this.progressOf,
    required this.multiSelectHint,
    required this.searchHint,
    required this.searchEmpty,
    required this.exitDialogTitle,
    required this.exitDialogMessage,
    required this.exitDialogConfirm,
    required this.exitDialogCancel,
    required this.unsupportedTitle,
    required this.unsupportedBody,
  });

  final String appBarTitle;
  final String loading;
  final String continueCta;
  final String skipCta;
  final String progressLabel;
  final String progressOf;
  final String multiSelectHint;
  final String searchHint;
  final String searchEmpty;
  final String exitDialogTitle;
  final String exitDialogMessage;
  final String exitDialogConfirm;
  final String exitDialogCancel;
  final String unsupportedTitle;
  final String unsupportedBody;
}

class ResultStrings {
  const ResultStrings({
    required this.appBarTitle,
    required this.influences,
    required this.important,
    required this.refusalTitle,
    required this.insights,
    required this.requirements,
    required this.suggestionsTitle,
    required this.suggestionsSubtitle,
    required this.showMore,
    required this.showLess,
    required this.ctaViewBreed,
    required this.ctaViewAlternatives,
    required this.chipGood,
    required this.chipMedium,
    required this.chipRefused,
  });

  final String appBarTitle;
  final String influences;
  final String important;
  final String refusalTitle;
  final String insights;
  final String requirements;
  final String suggestionsTitle;
  final String suggestionsSubtitle;
  final String showMore;
  final String showLess;
  final String ctaViewBreed;
  final String ctaViewAlternatives;
  final String chipGood;
  final String chipMedium;
  final String chipRefused;
}

class DetailsStrings {
  const DetailsStrings({
    required this.appBarTitle,
    required this.galleryLabelPrefix,
    required this.photosSuffix,
  });

  final String appBarTitle;
  final String galleryLabelPrefix;
  final String photosSuffix;
}
