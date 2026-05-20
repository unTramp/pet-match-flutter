import '../../core/failures.dart';
import '../entities/compatibility.dart';
import '../repositories/questionnaire_repository.dart';

/// Циклически опрашивает GET /session пока `compatibility.status` не станет
/// `ready`. Дефолтные параметры — 1.5s интервал, 30s timeout — выбраны так,
/// чтобы покрыть типичное время расчёта совместимости на бэкенде без излишней
/// нагрузки на сеть.
///
/// Тайминг управляется через `Future.delayed` и `Future.timeout` — это даёт
/// возможность контролировать его в тестах через `package:fake_async`
/// (в отличие от `DateTime.now()`, который fake_async не перехватывает).
class PollCompatibility {
  PollCompatibility(this._repository);

  final QuestionnaireRepository _repository;

  Future<Compatibility> call({
    required int userId,
    Duration timeout = const Duration(seconds: 30),
    Duration interval = const Duration(milliseconds: 1500),
  }) {
    Future<Compatibility> loop() async {
      while (true) {
        final session = await _repository.getSession(userId);
        final compatibility = session.compatibility;
        if (compatibility != null && compatibility.isReady) {
          return compatibility;
        }
        await Future<void>.delayed(interval);
      }
    }

    return loop().timeout(
      timeout,
      onTimeout: () => throw const TimeoutFailure(),
    );
  }
}
