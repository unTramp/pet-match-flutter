import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_match/core/cache/session_cache.dart';
import 'package:pet_match/domain/entities/progress.dart';
import 'package:pet_match/domain/entities/session.dart';
import 'package:pet_match/domain/repositories/questionnaire_repository.dart';
import 'package:pet_match/domain/usecases/start_session.dart';

class _MockRepository extends Mock implements QuestionnaireRepository {}

class _MockCache extends Mock implements SessionCache {}

void main() {
  late _MockRepository repository;
  late _MockCache cache;

  setUp(() {
    repository = _MockRepository();
    cache = _MockCache();
  });

  const session = Session(
    userId: 7,
    progress: Progress(answered: 2, total: 10),
  );

  test('resume flow: when saved user id exists, uses getSession', () async {
    when(cache.getSavedUserId).thenAnswer((_) async => 7);
    when(() => repository.getSession(7)).thenAnswer((_) async => session);
    when(() => cache.saveUserId(7)).thenAnswer((_) async {});

    final usecase = StartSession(repository, cache);
    final result = await usecase();

    expect(result.userId, 7);
    verify(() => repository.getSession(7)).called(1);
    verifyNever(() => cache.getOrCreateUid());
    verifyNever(() => repository.startSession(any()));
  });

  test('new flow: when no saved user id, uses startSession with uid', () async {
    when(cache.getSavedUserId).thenAnswer((_) async => null);
    when(cache.getOrCreateUid).thenAnswer((_) async => 'abc');
    when(
      () => repository.startSession('uid:abc'),
    ).thenAnswer((_) async => session);
    when(() => cache.saveUserId(7)).thenAnswer((_) async {});

    final usecase = StartSession(repository, cache);
    final result = await usecase();

    expect(result.userId, 7);
    verify(() => cache.getOrCreateUid()).called(1);
    verify(() => repository.startSession('uid:abc')).called(1);
    verifyNever(() => repository.getSession(any()));
  });

  test(
    'external id override uses provided id and bypasses local session',
    () async {
      when(
        () => repository.startSession('tester-123458'),
      ).thenAnswer((_) async => session);
      when(() => cache.saveUserId(7)).thenAnswer((_) async {});

      final usecase = StartSession(
        repository,
        cache,
        externalIdOverride: 'tester-123458',
      );
      final result = await usecase();

      expect(result.userId, 7);
      verify(() => repository.startSession('tester-123458')).called(1);
      verifyNever(() => cache.getSavedUserId());
      verifyNever(() => cache.getOrCreateUid());
      verifyNever(() => repository.getSession(any()));
    },
  );
}
