import 'dart:convert';
import 'dart:io';

import '../../../repositories/match_result_repository.dart';

class FileMatchResultRepository implements MatchResultRepository {
  FileMatchResultRepository({
    required String storagePath,
    int retentionDays = 30,
    int maxStoredResults = 2000,
  }) : _resultsDir = Directory('$storagePath/match_results'),
       _retention = Duration(days: retentionDays),
       _maxStoredResults = maxStoredResults {
    _resultsDir.createSync(recursive: true);
  }

  final Directory _resultsDir;
  final Duration _retention;
  final int _maxStoredResults;

  @override
  Future<Map<String, dynamic>?> getById(String resultId) async {
    final file = _fileFor(resultId);
    if (!file.existsSync()) {
      return null;
    }
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  @override
  Future<void> save(Map<String, dynamic> result) async {
    final resultId = result['resultId'] as String?;
    if (resultId == null || resultId.isEmpty) {
      throw StateError('Cannot persist match result without resultId.');
    }

    final stored = <String, dynamic>{
      ...result,
      'storedAt':
          result['storedAt'] as String? ??
          DateTime.now().toUtc().toIso8601String(),
    };
    final file = _fileFor(resultId);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(stored));
    _cleanup();
  }

  File _fileFor(String resultId) => File('${_resultsDir.path}/$resultId.json');

  void _cleanup() {
    final now = DateTime.now().toUtc();
    final staleCutoff = now.subtract(_retention);
    final files = _resultsDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.json'))
        .toList(growable: false);

    for (final file in files) {
      final modifiedAt = file.lastModifiedSync().toUtc();
      if (modifiedAt.isBefore(staleCutoff)) {
        file.deleteSync();
      }
    }

    final freshFiles =
        _resultsDir
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.json'))
            .toList()
          ..sort(
            (left, right) => right.lastModifiedSync().toUtc().compareTo(
              left.lastModifiedSync().toUtc(),
            ),
          );
    if (freshFiles.length <= _maxStoredResults) {
      return;
    }

    for (final file in freshFiles.skip(_maxStoredResults)) {
      file.deleteSync();
    }
  }
}
