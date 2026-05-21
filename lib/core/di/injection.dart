import 'package:get_it/get_it.dart';

import '../../data/repositories/breed_repository_impl.dart';
import '../../data/repositories/questionnaire_repository_impl.dart';
import '../../data/sources/http_pet_match_remote_source.dart';
import '../../data/sources/mock_pet_match_remote_source.dart';
import '../../data/sources/pet_match_remote_source.dart';
import '../../domain/repositories/breed_repository.dart';
import '../../domain/repositories/questionnaire_repository.dart';
import '../../domain/usecases/get_breed_detail.dart';
import '../../domain/usecases/get_dynamic_options.dart';
import '../../domain/usecases/poll_compatibility.dart';
import '../../domain/usecases/skip_question.dart';
import '../../domain/usecases/start_session.dart';
import '../../domain/usecases/submit_answer.dart';
import '../cache/session_cache.dart';
import '../network/dio_client.dart';

final GetIt sl = GetIt.instance;

/// Default API endpoint for the dev environment. Overridable via
/// `--dart-define=API_BASE_URL=...` for staging/local servers.
const String _defaultBaseUrl = 'https://app-api.dev.pet-match.app/api/v1';

const bool useMock = bool.fromEnvironment('USE_MOCK', defaultValue: false);
const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: _defaultBaseUrl,
);
const String externalIdOverride = String.fromEnvironment(
  'PET_MATCH_EXTERNAL_ID',
);

Future<void> configureDependencies() async {
  if (sl.isRegistered<SessionCache>()) {
    return;
  }

  // Core singletons.
  sl.registerLazySingleton<SessionCache>(SessionCache.new);

  // Remote source — Mock or Http depending on build-time flag.
  // `AppLocaleController` остаётся глобальным singleton'ом (см. AppLocaleController.instance);
  // `LocaleInterceptor()` фолбэкает на него по умолчанию.
  sl.registerLazySingleton<PetMatchRemoteSource>(
    () =>
        useMock
            ? MockPetMatchRemoteSource()
            : HttpPetMatchRemoteSource(buildDio(baseUrl)),
  );

  // Repositories.
  sl.registerLazySingleton<QuestionnaireRepository>(
    () => QuestionnaireRepositoryImpl(sl<PetMatchRemoteSource>()),
  );
  sl.registerLazySingleton<BreedRepository>(
    () => BreedRepositoryImpl(sl<PetMatchRemoteSource>()),
  );

  // Use cases — factory: cheap to construct, stateless.
  sl.registerFactory(
    () => StartSession(
      sl<QuestionnaireRepository>(),
      sl<SessionCache>(),
      externalIdOverride:
          externalIdOverride.isEmpty ? null : externalIdOverride,
    ),
  );
  sl.registerFactory(() => SubmitAnswer(sl<QuestionnaireRepository>()));
  sl.registerFactory(() => SkipQuestion(sl<QuestionnaireRepository>()));
  sl.registerFactory(() => GetDynamicOptions(sl<QuestionnaireRepository>()));
  sl.registerFactory(() => PollCompatibility(sl<QuestionnaireRepository>()));
  sl.registerFactory(() => GetBreedDetail(sl<BreedRepository>()));
}
