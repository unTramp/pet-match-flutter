import 'dart:io';

import 'mapping_validator.dart';

void main(List<String> args) {
  final questionnairePath =
      _readArgValue(args, '--questionnaire') ??
      'docs/backend/examples/questionnaire_definition.v1.json';
  final mappingPath =
      _readArgValue(args, '--mapping') ??
      'docs/backend/config/answer_to_profile_mapping.v1.json';
  final scoringConfigPath =
      _readArgValue(args, '--scoring-config') ??
      'docs/backend/config/scoring_config.v1.json';

  final validator = MappingValidator(
    questionnairePath: questionnairePath,
    mappingPath: mappingPath,
    scoringConfigPath: scoringConfigPath,
  );
  final report = validator.validate();

  stdout.writeln(
    'Questionnaire version ${report.questionnaireVersion}, mappings version ${report.mappingVersion}',
  );
  stdout.writeln(
    'Questions: ${report.questionCount}, mappings: ${report.mappingCount}',
  );

  if (report.warnings.isNotEmpty) {
    stdout.writeln('Warnings:');
    for (final warning in report.warnings) {
      stdout.writeln('- $warning');
    }
  }

  if (report.isValid) {
    stdout.writeln('Mapping validation passed.');
    return;
  }

  stderr.writeln('Mapping validation failed:');
  for (final error in report.errors) {
    stderr.writeln('- $error');
  }
  exitCode = 1;
}

String? _readArgValue(List<String> args, String flag) {
  final index = args.indexOf(flag);
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }
  return args[index + 1];
}
