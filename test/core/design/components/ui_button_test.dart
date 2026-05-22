import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/core/design/components/ui_button.dart';
import 'package:pet_match/core/theme/app_colors.dart';

Widget _wrap(Widget child, {TargetPlatform? platform}) {
  return MaterialApp(
    theme: ThemeData(platform: platform ?? TargetPlatform.android),
    home: Scaffold(body: child),
  );
}

void main() {
  group('UiButton — Material (Android)', () {
    testWidgets('primary рендерит label и реагирует на tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(UiButton(label: 'Continue', onPressed: () => taps++)),
      );

      expect(find.text('Continue'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      expect(taps, 1);
    });

    testWidgets('disabled (onPressed=null) — tap не вызывает callback', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const UiButton(label: 'Continue', onPressed: null)),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('icon рендерится слева от label', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiButton(
            label: 'Continue',
            onPressed: () {},
            icon: Icons.arrow_forward_rounded,
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets(
      'loading=true показывает spinner, label скрыт, tap игнорируется',
      (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          _wrap(
            UiButton(label: 'Continue', onPressed: () => taps++, loading: true),
          ),
        );

        expect(find.text('Continue'), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        final spinner = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );
        expect(spinner.valueColor?.value, Colors.white);

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(
          button.onPressed,
          isNull,
          reason: 'loading должен disable onPressed',
        );

        await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
        expect(taps, 0);
      },
    );

    testWidgets('secondary вариант — OutlinedButton', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiButton(
            label: 'Back',
            onPressed: () {},
            variant: UiButtonVariant.secondary,
          ),
        ),
      );
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('secondary loading использует primary spinner', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const UiButton(
            label: 'Back',
            onPressed: null,
            loading: true,
            variant: UiButtonVariant.secondary,
          ),
        ),
      );

      final spinner = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(spinner.valueColor?.value, AppColors.primary);
    });

    testWidgets('text вариант — TextButton', (tester) async {
      await tester.pumpWidget(
        _wrap(
          UiButton(
            label: 'Skip',
            onPressed: () {},
            variant: UiButtonVariant.text,
          ),
        ),
      );
      expect(find.byType(TextButton), findsOneWidget);
    });
  });

  group('UiButton — Cupertino (iOS)', () {
    testWidgets('primary — solid CTA с белым label', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(
          UiButton(label: 'Continue', onPressed: () => taps++),
          platform: TargetPlatform.iOS,
        ),
      );

      expect(find.byType(CupertinoButton), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      final styles = tester.widgetList<DefaultTextStyle>(
        find.byType(DefaultTextStyle),
      );
      expect(styles.any((style) => style.style.color == Colors.white), isTrue);

      await tester.tap(find.byType(CupertinoButton));
      expect(taps, 1);
    });

    testWidgets('loading на iOS — spinner и disabled onPressed', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          UiButton(label: 'Continue', onPressed: () {}, loading: true),
          platform: TargetPlatform.iOS,
        ),
      );

      expect(find.text('Continue'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      final btn = tester.widget<CupertinoButton>(find.byType(CupertinoButton));
      expect(btn.onPressed, isNull);
    });
  });
}
