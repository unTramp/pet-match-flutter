import 'package:equatable/equatable.dart';

sealed class AppFailure extends Equatable implements Exception {
  const AppFailure();

  @override
  List<Object?> get props => const [];
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure();
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure();
}

final class ServerFailure extends AppFailure {
  const ServerFailure({required this.statusCode, required this.message});

  /// Generic-фабрика для непредвиденных исключений на уровне cubit/UI.
  /// Используется в `catch (e, st)`-блоках, где специфичный код ответа
  /// отсутствует. `statusCode: -1` отличает её от настоящих HTTP-ошибок.
  const ServerFailure.unexpected()
    : statusCode = -1,
      message = 'Unexpected error';

  final int statusCode;
  final String message;

  @override
  List<Object?> get props => [statusCode, message];
}

final class EmptyResponseFailure extends AppFailure {
  const EmptyResponseFailure();
}
