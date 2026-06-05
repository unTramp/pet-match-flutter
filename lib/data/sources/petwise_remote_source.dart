import '../dto/breed_detail_dto.dart';
import '../dto/petwise_match_preview_dto.dart';
import '../dto/petwise_profile_dto.dart';
import '../dto/petwise_questionnaire_definition_dto.dart';

abstract class PetWiseRemoteSource {
  Future<PetWiseQuestionnaireDefinitionDto> getQuestionnaireDefinition();

  Future<PetWiseProfileResponseDto> buildProfile({
    required int questionnaireVersion,
    required List<PetWiseSelectedAnswerDto> answers,
  });

  Future<PetWiseMatchPreviewDto> previewMatch({
    required int questionnaireVersion,
    required Map<String, dynamic> userProfile,
  });

  Future<BreedDetailDto> getBreedDetail({required String breedId});
}
