import 'package:dio/dio.dart';

import '../dto/answer_result_dto.dart';
import '../dto/answer_submit_dto.dart';
import '../dto/breed_detail_dto.dart';
import '../dto/dynamic_option_dto.dart';
import '../dto/session_dto.dart';
import 'endpoints.dart';
import 'pet_match_remote_source.dart';

class HttpPetMatchRemoteSource implements PetMatchRemoteSource {
  HttpPetMatchRemoteSource(this._dio);

  final Dio _dio;

  @override
  Future<SessionDto> startSession({required String externalId}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      Endpoints.startSession,
      data: {'external_id': externalId},
    );
    return SessionDto.fromJson(response.data!);
  }

  @override
  Future<SessionDto> getSession({required int userId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      Endpoints.userSession(userId),
    );
    return SessionDto.fromJson(response.data!);
  }

  @override
  Future<AnswerResultDto> submitAnswer({
    required int userId,
    required AnswerSubmitDto answer,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      Endpoints.userAnswers(userId),
      data: answer.toJson(),
    );
    return AnswerResultDto.fromJson(response.data!);
  }

  @override
  Future<SessionDto> skipQuestion({
    required int userId,
    required int questionId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      Endpoints.skipQuestion(userId, questionId),
    );
    return SessionDto.fromJson(response.data!);
  }

  @override
  Future<DynamicOptionListDto> getDynamicOptions({
    required int userId,
    required int questionId,
    String? query,
    int limit = 50,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      Endpoints.questionOptions(userId, questionId),
      queryParameters: {
        if (query != null && query.isNotEmpty) 'q': query,
        'limit': limit,
      },
    );
    return DynamicOptionListDto.fromJson(response.data!);
  }

  @override
  Future<BreedDetailDto> getBreedDetail({required int breedId}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      Endpoints.breedDetail(breedId),
    );
    return BreedDetailDto.fromJson(response.data!);
  }
}
