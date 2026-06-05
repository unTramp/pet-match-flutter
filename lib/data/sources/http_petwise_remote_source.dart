import 'package:dio/dio.dart';

import '../dto/breed_detail_dto.dart';
import '../dto/petwise_match_preview_dto.dart';
import '../dto/petwise_profile_dto.dart';
import '../dto/petwise_questionnaire_definition_dto.dart';
import 'petwise_remote_source.dart';

class HttpPetWiseRemoteSource implements PetWiseRemoteSource {
  HttpPetWiseRemoteSource(this._dio);

  final Dio _dio;

  static const String _questionnaireDefinitionPath =
      '/questionnaire/definition';
  static const String _profilePath = '/questionnaire/profile';
  static const String _matchPreviewPath = '/match/preview';

  @override
  Future<PetWiseQuestionnaireDefinitionDto> getQuestionnaireDefinition() async {
    final response = await _dio.get<Map<String, dynamic>>(
      _questionnaireDefinitionPath,
    );
    return PetWiseQuestionnaireDefinitionDto.fromJson(response.data!);
  }

  @override
  Future<PetWiseProfileResponseDto> buildProfile({
    required int questionnaireVersion,
    required List<PetWiseSelectedAnswerDto> answers,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _profilePath,
      data: <String, dynamic>{
        'questionnaireVersion': questionnaireVersion,
        'answers': answers.map((item) => item.toJson()).toList(growable: false),
      },
    );
    return PetWiseProfileResponseDto.fromJson(response.data!);
  }

  @override
  Future<PetWiseMatchPreviewDto> previewMatch({
    required int questionnaireVersion,
    required Map<String, dynamic> userProfile,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _matchPreviewPath,
      data: <String, dynamic>{
        'questionnaireVersion': questionnaireVersion,
        'userProfile': userProfile,
      },
    );
    return PetWiseMatchPreviewDto.fromJson(response.data!);
  }

  @override
  Future<BreedDetailDto> getBreedDetail({required String breedId}) async {
    final response = await _dio.get<Map<String, dynamic>>('/breeds/$breedId');
    return BreedDetailDto.fromJson(response.data!);
  }
}
