import 'dart:convert';
import 'dart:io';

import 'profile_builder.dart';

void main(List<String> args) {
  final answersPath =
      _readArgValue(args, '--answers-json') ??
      'docs/backend/examples/answers.apartment_quiet_beginner.json';
  final questionnairePath =
      _readArgValue(args, '--questionnaire') ??
      'docs/backend/examples/questionnaire_definition.v1.json';
  final mappingPath =
      _readArgValue(args, '--mapping') ??
      'docs/backend/config/answer_to_profile_mapping.v1.json';
  final scoringConfigPath =
      _readArgValue(args, '--scoring-config') ??
      'docs/backend/config/scoring_config.v1.json';

  final builder = ReferenceProfileBuilder(
    questionnairePath: questionnairePath,
    mappingPath: mappingPath,
    scoringConfigPath: scoringConfigPath,
  );

  try {
    final payload =
        jsonDecode(File(answersPath).readAsStringSync())
            as Map<String, dynamic>;
    final result = builder.buildFromJson(payload);
    stdout.writeln(
      const JsonEncoder.withIndent('  ').convert(<String, dynamic>{
        'questionnaireVersion': result.questionnaireVersion,
        'userProfile': result.userProfile,
      }),
    );
  } on ProfileBuildValidationError catch (error) {
    stderr.writeln('Profile build failed:');
    for (final message in error.messages) {
      stderr.writeln('- $message');
    }
    exitCode = 1;
  }
}

String? _readArgValue(List<String> args, String flag) {
  final index = args.indexOf(flag);
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }
  return args[index + 1];
}
