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

  final int statusCode;
  final String message;

  @override
  List<Object?> get props => [statusCode, message];
}

final class EmptyResponseFailure extends AppFailure {
  const EmptyResponseFailure();
}
