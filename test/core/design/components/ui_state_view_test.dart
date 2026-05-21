import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/core/design/components/ui_button.dart';
import 'package:pet_match/core/design/components/ui_state_view.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  group('UiStateView', () {
    testWidgets('.loading() — показывает CircularProgressIndicator, без message',
        (tester) async {
      await tester.pumpWidget(_wrap(const UiStateView.loading()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // message не передан → не должен рендериться.
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('.loading(message:) — показывает spinner и текст', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const UiStateView.loading(message: 'Загружаем…')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Загружаем…'), findsOneWidget);
    });

    testWidgets('.message — иконка + текст без actions', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const UiStateView.message(
            icon: Icons.cloud_off_rounded,
            message: 'Нет связи',
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      expect(find.text('Нет связи'), findsOneWidget);
      expect(find.byType(UiButton), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('.message + primaryAction — рендерит UiButton, callback ловится',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          UiStateView.message(
            icon: Icons.cloud_off_rounded,
            message: 'Нет связи',
            primaryLabel: 'Повторить',
            primaryAction: () => taps++,
          ),
        ),
      );

      expect(find.byType(UiButton), findsOneWidget);
      expect(find.text('Повторить'), findsOneWidget);

      await tester.tap(find.byType(UiButton));
      expect(taps, 1);
    });

    testWidgets('primaryLabel без primaryAction — кнопка не рендерится', (
      tester,
    ) async {
      // Защита от частичных параметров — оба должны быть заданы.
      await tester.pumpWidget(
        _wrap(
          const UiStateView.message(
            icon: Icons.info_outline_rounded,
            message: 'Info',
            primaryLabel: 'Action',
          ),
        ),
      );

      expect(find.byType(UiButton), findsNothing);
    });
  });
}
