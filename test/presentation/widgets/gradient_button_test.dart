import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/presentation/widgets/gradient_button.dart';

Future<void> _pump(WidgetTester tester, Widget child) =>
    tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));

void main() {
  group('GradientButton', () {
    testWidgets('renders label and default arrow icon', (tester) async {
      await _pump(
        tester,
        GradientButton(label: 'Продолжить', onPressed: () {}),
      );

      expect(find.text('Продолжить'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('tap invokes callback once', (tester) async {
      var count = 0;
      await _pump(
        tester,
        GradientButton(label: 'Tap', onPressed: () => count += 1),
      );

      await tester.tap(find.byType(GradientButton));
      expect(count, 1);
    });

    testWidgets('disabled (onPressed=null) renders but accepts no tap', (
      tester,
    ) async {
      await _pump(
        tester,
        const GradientButton(label: 'Disabled', onPressed: null),
      );

      expect(find.text('Disabled'), findsOneWidget);
      // Тап в disabled-стейте безопасен и ничего не делает.
      await tester.tap(find.text('Disabled'), warnIfMissed: false);
    });

    testWidgets('disabled state reduces opacity', (tester) async {
      await _pump(tester, const GradientButton(label: 'X', onPressed: null));

      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacity.opacity, lessThan(1));
    });

    testWidgets('icon is hidden when icon is null', (
      tester,
    ) async {
      await _pump(
        tester,
        GradientButton(label: 'Без иконки', onPressed: () {}, icon: null),
      );

      expect(find.byIcon(Icons.arrow_forward_rounded), findsNothing);
    });
  });
}
