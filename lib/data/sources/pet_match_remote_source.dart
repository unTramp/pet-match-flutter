import '../dto/answer_result_dto.dart';
import '../dto/answer_submit_dto.dart';
import '../dto/breed_detail_dto.dart';
import '../dto/dynamic_option_dto.dart';
import '../dto/session_dto.dart';

/// Сырые HTTP-вызовы. Знает только про DTO и про сетевые ошибки —
/// никакой бизнес-логики, никаких маппингов, никаких AppFailure.
/// Реализации: HTTP (через dio) и Mock (из assets).
abstract class PetMatchRemoteSource {
  Future<SessionDto> startSession({required String externalId});

  Future<SessionDto> getSession({required int userId});

  Future<AnswerResultDto> submitAnswer({
    required int userId,
    required AnswerSubmitDto answer,
  });

  Future<SessionDto> skipQuestion({
    required int userId,
    required int questionId,
  });

  Future<DynamicOptionListDto> getDynamicOptions({
    required int userId,
    required int questionId,
    String? query,
    int limit = 50,
  });

  Future<BreedDetailDto> getBreedDetail({required int breedId});
}
