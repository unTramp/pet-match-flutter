import 'dart:convert';
import 'dart:io';

import '../../../repositories/match_result_repository.dart';

class FileMatchResultRepository implements MatchResultRepository {
  FileMatchResultRepository({required String storagePath})
    : _resultsDir = Directory('$storagePath/match_results') {
    _resultsDir.createSync(recursive: true);
  }

  final Directory _resultsDir;

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
  }

  File _fileFor(String resultId) => File('${_resultsDir.path}/$resultId.json');
}
