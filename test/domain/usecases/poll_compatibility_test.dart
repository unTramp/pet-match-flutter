import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pet_match/core/failures.dart';
import 'package:pet_match/domain/entities/compatibility.dart';
import 'package:pet_match/domain/entities/progress.dart';
import 'package:pet_match/domain/entities/session.dart';
import 'package:pet_match/domain/repositories/questionnaire_repository.dart';
import 'package:pet_match/domain/usecases/poll_compatibility.dart';

class _MockRepo extends Mock implements QuestionnaireRepository {}

Session _sessionWith({
  CompatibilityStatus? status,
  int answered = 6,
  int total = 6,
}) {
  return Session(
    userId: 1,
    progress: Progress(answered: answered, total: total),
    compatibility:
        status == null ? null : Compatibility(status: status, breedName: 'X'),
  );
}

void main() {
  late _MockRepo repo;
  late PollCompatibility usecase;

  setUp(() {
    repo = _MockRepo();
    usecase = PollCompatibility(repo);
  });

  test('returns Compatibility when status becomes ready', () {
    fakeAsync((async) {
      var callCount = 0;
      when(() => repo.getSession(any())).thenAnswer((_) async {
        callCount += 1;
        return _sessionWith(
          status:
              callCount >= 3
                  ? CompatibilityStatus.ready
                  : CompatibilityStatus.processing,
        );
      });

      Compatibility? result;
      Object? error;
      usecase(
        userId: 1,
        interval: const Duration(milliseconds: 100),
        timeout: const Duration(seconds: 5),
      ).then((c) => result = c).catchError((Object e) {
        error = e;
        return const Compatibility(status: CompatibilityStatus.failed);
      });

      async.elapse(const Duration(seconds: 1));
      expect(error, isNull);
      expect(result, isNotNull);
      expect(result!.isReady, isTrue);
      expect(callCount, greaterThanOrEqualTo(3));
    });
  });

  test('throws TimeoutFailure when status stays processing past timeout', () {
    fakeAsync((async) {
      when(() => repo.getSession(any())).thenAnswer(
        (_) async => _sessionWith(status: CompatibilityStatus.processing),
      );

      Object? error;
      usecase(
        userId: 1,
        interval: const Duration(milliseconds: 500),
        timeout: const Duration(seconds: 2),
      ).catchError((Object e) {
        error = e;
        return const Compatibility(status: CompatibilityStatus.failed);
      });

      async.elapse(const Duration(seconds: 3));
      expect(error, isA<TimeoutFailure>());
    });
  });

  test('propagates NetworkFailure from repository', () {
    fakeAsync((async) {
      when(() => repo.getSession(any())).thenThrow(const NetworkFailure());

      Object? error;
      usecase(
        userId: 1,
        interval: const Duration(milliseconds: 100),
        timeout: const Duration(seconds: 5),
      ).catchError((Object e) {
        error = e;
        return const Compatibility(status: CompatibilityStatus.failed);
      });

      async.elapse(const Duration(seconds: 1));
      expect(error, isA<NetworkFailure>());
    });
  });
}
