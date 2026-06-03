import '../../backend/src/domain/profile_builder.dart';
import '../../backend/src/domain/spec_json.dart';

export '../../backend/src/domain/profile_builder.dart';

class ReferenceProfileBuilder {
  ReferenceProfileBuilder({
    required this.questionnairePath,
    required this.mappingPath,
    required this.scoringConfigPath,
  }) : _builder = QuestionnaireProfileBuilder(
         ProfileBuilderDefinition.fromJson(
           questionnaireJson: loadJson(questionnairePath),
           mappingJson: loadJson(mappingPath),
           scoringConfigJson: loadJson(scoringConfigPath),
         ),
       );

  final String questionnairePath;
  final String mappingPath;
  final String scoringConfigPath;
  final QuestionnaireProfileBuilder _builder;

  ProfileBuildResult buildFromJson(Map<String, dynamic> payload) =>
      _builder.buildFromJson(payload);

  ProfileBuildResult build({
    required int questionnaireVersion,
    required List<QuestionnaireAnswer> answers,
  }) => _builder.build(
    questionnaireVersion: questionnaireVersion,
    answers: answers,
  );
}
