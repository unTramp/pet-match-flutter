import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/core/failures.dart';
import 'package:pet_match/presentation/widgets/error_view.dart';

Future<void> _pump(WidgetTester tester, Widget child) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));

void main() {
  group('ErrorView', () {
    testWidgets('NetworkFailure shows network message', (tester) async {
      await _pump(tester, const ErrorView(failure: NetworkFailure()));

      expect(find.textContaining('Нет подключения'), findsOneWidget);
    });

    testWidgets('TimeoutFailure shows timeout message', (tester) async {
      await _pump(tester, const ErrorView(failure: TimeoutFailure()));

      expect(find.textContaining('Сервер долго'), findsOneWidget);
    });

    testWidgets('ServerFailure shows generic message', (tester) async {
      await _pump(
        tester,
        const ErrorView(
          failure: ServerFailure(statusCode: 500, message: 'oops'),
        ),
      );

      expect(find.textContaining('Что-то пошло не так'), findsOneWidget);
    });

    testWidgets('EmptyResponseFailure shows empty message', (tester) async {
      await _pump(tester, const ErrorView(failure: EmptyResponseFailure()));

      expect(find.textContaining('Нет данных'), findsOneWidget);
    });

    testWidgets('Retry callback fires once on tap', (tester) async {
      var count = 0;
      await _pump(
        tester,
        ErrorView(failure: const NetworkFailure(), onRetry: () => count += 1),
      );

      await tester.tap(find.text('Повторить'));
      expect(count, 1);
    });

    testWidgets('No retry button when onRetry is null', (tester) async {
      await _pump(tester, const ErrorView(failure: NetworkFailure()));

      expect(find.text('Повторить'), findsNothing);
    });
  });
}
