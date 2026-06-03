import 'dart:io';

import 'reference_matcher.dart';

void main(List<String> args) {
  final bundle = ReferenceSpecBundle.load();
  final matcher = ReferenceMatcher(
    config: bundle.config,
    breeds: bundle.breeds.values.toList(),
  );

  if (args.contains('--help') || args.contains('-h')) {
    _printUsage();
    return;
  }

  final fixtureId = _readArgValue(args, '--fixture');
  final jsonPath = _readArgValue(args, '--profile-json');
  final showTop = int.tryParse(_readArgValue(args, '--top') ?? '') ?? 5;

  if (jsonPath != null) {
    final userProfile = loadJson(jsonPath);
    final results = matcher.rank(userProfile);
    _printRanking(
      title: 'Profile from $jsonPath',
      results: results.take(showTop).toList(),
    );
    return;
  }

  final fixtures =
      fixtureId == null
          ? bundle.fixtures
          : bundle.fixtures
              .where((fixture) => fixture.fixtureId == fixtureId)
              .toList();

  if (fixtures.isEmpty) {
    stderr.writeln('Fixture not found: $fixtureId');
    stderr.writeln(
      'Available fixtures: ${bundle.fixtures.map((f) => f.fixtureId).join(', ')}',
    );
    exitCode = 2;
    return;
  }

  for (final fixture in fixtures) {
    final results = matcher.rank(fixture.inputUserProfile);
    final top = results.first;
    stdout.writeln('');
    stdout.writeln('=== ${fixture.fixtureId} ===');
    stdout.writeln(
      fixture.expected.topBreedId == top.breedId
          ? 'Top breed OK: ${top.breedId} (${top.matchPercent}%)'
          : 'Top breed MISMATCH: expected ${fixture.expected.topBreedId}, got ${top.breedId} (${top.matchPercent}%)',
    );
    _printRanking(
      title: fixture.description,
      results: results.take(showTop).toList(),
    );
  }
}

void _printUsage() {
  stdout.writeln('PetWise reference matcher');
  stdout.writeln('');
  stdout.writeln('Usage:');
  stdout.writeln('  dart run tool/backend_specs/run_reference_matcher.dart');
  stdout.writeln(
    '  dart run tool/backend_specs/run_reference_matcher.dart --fixture apartment_quiet_beginner',
  );
  stdout.writeln(
    '  dart run tool/backend_specs/run_reference_matcher.dart --profile-json path/to/profile.json',
  );
  stdout.writeln('');
  stdout.writeln('Options:');
  stdout.writeln('  --fixture <id>      Run one ranking fixture');
  stdout.writeln(
    '  --profile-json <p>  Rank breeds for an arbitrary user profile JSON',
  );
  stdout.writeln('  --top <n>           Limit printed results, default 5');
}

void _printRanking({
  required String title,
  required List<MatchResult> results,
}) {
  stdout.writeln(title);
  for (var i = 0; i < results.length; i++) {
    final result = results[i];
    stdout.writeln(
      '${i + 1}. ${result.breedId}  ${result.matchPercent}%  raw=${result.rawScore.toStringAsFixed(3)}',
    );
  }
}

String? _readArgValue(List<String> args, String flag) {
  final index = args.indexOf(flag);
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }
  return args[index + 1];
}
