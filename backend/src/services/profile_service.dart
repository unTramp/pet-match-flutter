import '../domain/profile_builder.dart';
import '../contracts/questionnaire_contracts.dart';

class ProfileService {
  ProfileService(this._builder);

  final QuestionnaireProfileBuilder _builder;

  Map<String, dynamic> buildProfile(Map<String, dynamic> requestBody) {
    final request = BuildProfileRequest.fromJson(requestBody);
    final answers = <QuestionnaireAnswer>[];

    for (final answer in request.answers) {
      for (final optionId in answer.selectedOptionIds) {
        answers.add(
          QuestionnaireAnswer(
            questionId: answer.questionId,
            optionId: optionId,
          ),
        );
      }
    }

    final result = _builder.build(
      questionnaireVersion: request.questionnaireVersion,
      answers: answers,
    );

    return UserProfileResponse(
      questionnaireVersion: result.questionnaireVersion,
      userProfile: result.userProfile,
    ).toJson();
  }
}
