import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import '../../data/repositories/breed_repository_impl.dart';
import '../../data/repositories/questionnaire_repository_impl.dart';
import '../../data/sources/http_pet_match_remote_source.dart';
import '../../data/sources/mock_pet_match_remote_source.dart';
import '../../data/sources/pet_match_remote_source.dart';
import '../localization/locale_provider.dart';
import '../../domain/repositories/breed_repository.dart';
import '../../domain/repositories/questionnaire_repository.dart';
import '../../domain/usecases/get_breed_detail.dart';
import '../../domain/usecases/get_dynamic_options.dart';
import '../../domain/usecases/poll_compatibility.dart';
import '../../domain/usecases/skip_question.dart';
import '../../domain/usecases/start_session.dart';
import '../../domain/usecases/submit_answer.dart';
import '../../presentation/details/cubit/breed_detail_cubit.dart';
import '../../presentation/questionnaire/cubit/questionnaire_cubit.dart';
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
  sl.registerLazySingleton<LocaleProvider>(
    () => const StaticLocaleProvider(Locale('ru')),
  );

  // Remote source — Mock или Http в зависимости от build-time флага.
  // Release-build всегда форсит HTTP (даже если случайно передали USE_MOCK=true)
  // — это защита от утечки mock-данных в production.
  sl.registerLazySingleton<PetMatchRemoteSource>(() {
    const shouldMock = useMock && !kReleaseMode;
    return shouldMock
        ? MockPetMatchRemoteSource()
        : HttpPetMatchRemoteSource(buildDio(baseUrl, sl<LocaleProvider>()));
  });

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

  // Cubits — также factory, новый инстанс на каждый экран.
  sl.registerFactory(
    () => QuestionnaireCubit(
      sl<StartSession>(),
      sl<SubmitAnswer>(),
      sl<SkipQuestion>(),
      sl<PollCompatibility>(),
    ),
  );
  sl.registerFactory(() => BreedDetailCubit(sl<GetBreedDetail>()));
}
