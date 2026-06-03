import 'dart:convert';

import 'package:postgres/postgres.dart';

import '../../../repositories/match_result_repository.dart';

class PostgresMatchResultRepository implements MatchResultRepository {
  PostgresMatchResultRepository({
    required String databaseUrl,
    int retentionDays = 30,
    int maxStoredResults = 2000,
  }) : _databaseUrl = databaseUrl,
       _retentionDays = retentionDays,
       _maxStoredResults = maxStoredResults;

  final String _databaseUrl;
  final int _retentionDays;
  final int _maxStoredResults;
  Future<Connection>? _connectionFuture;

  @override
  Future<Map<String, dynamic>?> getById(String resultId) async {
    final connection = await _connection();
    final result = await connection.execute(
      Sql.named(
        'SELECT result_payload::text '
        'FROM stored_match_results '
        'WHERE id = @id',
      ),
      parameters: <String, Object?>{'id': resultId},
    );

    if (result.isEmpty) {
      return null;
    }

    final payload = result.first[0] as String;
    return jsonDecode(payload) as Map<String, dynamic>;
  }

  @override
  Future<void> save(Map<String, dynamic> result) async {
    final resultId = result['resultId'] as String?;
    if (resultId == null || resultId.isEmpty) {
      throw StateError('Cannot persist match result without resultId.');
    }

    final topMatch = Map<String, dynamic>.from(
      result['topMatch'] as Map<String, dynamic>? ?? const {},
    );
    final connection = await _connection();
    await connection.execute(
      Sql.named(
        'INSERT INTO stored_match_results ('
        'id, questionnaire_version, scoring_version, top_breed_id, top_match_percent, user_profile, result_payload, created_at'
        ') VALUES ('
        '@id, @questionnaireVersion, @scoringVersion, @topBreedId, @topMatchPercent, '
        'CAST(@userProfile AS jsonb), CAST(@resultPayload AS jsonb), CAST(@createdAt AS timestamptz)'
        ') '
        'ON CONFLICT (id) DO UPDATE SET '
        'questionnaire_version = EXCLUDED.questionnaire_version, '
        'scoring_version = EXCLUDED.scoring_version, '
        'top_breed_id = EXCLUDED.top_breed_id, '
        'top_match_percent = EXCLUDED.top_match_percent, '
        'user_profile = EXCLUDED.user_profile, '
        'result_payload = EXCLUDED.result_payload, '
        'created_at = EXCLUDED.created_at',
      ),
      parameters: <String, Object?>{
        'id': resultId,
        'questionnaireVersion':
            (result['questionnaireVersion'] as num?)?.toInt() ?? 0,
        'scoringVersion': (result['scoringVersion'] as num?)?.toInt() ?? 0,
        'topBreedId': topMatch['breedId'] as String? ?? '',
        'topMatchPercent': (topMatch['matchPercent'] as num?)?.toInt() ?? 0,
        'userProfile': jsonEncode(
          result['userProfile'] as Map<String, dynamic>? ?? const {},
        ),
        'resultPayload': jsonEncode(result),
        'createdAt':
            result['storedAt'] as String? ??
            DateTime.now().toUtc().toIso8601String(),
      },
    );
    await _cleanup(connection);
  }

  Future<Connection> _connection() {
    return _connectionFuture ??= _openConnection();
  }

  Future<Connection> _openConnection() async {
    final connection = await Connection.openFromUrl(
      _databaseUrlWithSslModeDisabled(_databaseUrl),
    );
    await connection.execute('''
      CREATE TABLE IF NOT EXISTS stored_match_results (
        id text PRIMARY KEY,
        questionnaire_version integer NOT NULL,
        scoring_version integer NOT NULL,
        top_breed_id text NOT NULL,
        top_match_percent integer NOT NULL,
        user_profile jsonb NOT NULL,
        result_payload jsonb NOT NULL,
        created_at timestamptz NOT NULL DEFAULT now()
      )
      ''');
    return connection;
  }

  Future<void> _cleanup(Connection connection) async {
    await connection.execute(
      Sql.named(
        'DELETE FROM stored_match_results '
        'WHERE created_at < now() - make_interval(days => @retentionDays)',
      ),
      parameters: <String, Object?>{'retentionDays': _retentionDays},
    );
    await connection.execute(
      Sql.named(
        'DELETE FROM stored_match_results '
        'WHERE id IN ('
        '  SELECT id FROM stored_match_results '
        '  ORDER BY created_at DESC '
        '  OFFSET @maxStoredResults'
        ')',
      ),
      parameters: <String, Object?>{'maxStoredResults': _maxStoredResults},
    );
  }

  static String _databaseUrlWithSslModeDisabled(String databaseUrl) {
    final hasSslMode = RegExp(r'(^|[?&])sslmode=').hasMatch(databaseUrl);
    if (hasSslMode) {
      return databaseUrl;
    }

    final separator = databaseUrl.contains('?') ? '&' : '?';
    return '$databaseUrl${separator}sslmode=disable';
  }
}
