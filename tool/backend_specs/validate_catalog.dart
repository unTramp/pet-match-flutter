import 'dart:io';

import 'catalog_validator.dart';

void main(List<String> args) {
  final catalogPath =
      _readArgValue(args, '--catalog') ??
      'docs/backend/examples/catalog.v1.json';
  final scoringConfigPath =
      _readArgValue(args, '--scoring-config') ??
      'docs/backend/config/scoring_config.v2.json';

  final validator = CatalogValidator(
    catalogPath: catalogPath,
    scoringConfigPath: scoringConfigPath,
  );
  final report = validator.validate();

  stdout.writeln(
    'Catalog version ${report.catalogVersion}, breeds: ${report.breedCount}',
  );
  if (report.warnings.isNotEmpty) {
    stdout.writeln('Warnings:');
    for (final warning in report.warnings) {
      stdout.writeln('- $warning');
    }
  }

  if (report.isValid) {
    stdout.writeln('Catalog validation passed.');
    return;
  }

  stderr.writeln('Catalog validation failed:');
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
