import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/core/theme/app_colors.dart';
import 'package:pet_match/domain/entities/compatibility.dart';
import 'package:pet_match/presentation/result/result_page.dart';
import 'package:pet_match/presentation/result/widgets/main_breed_card.dart';
import 'package:pet_match/presentation/result/widgets/suggestion_card.dart';

void main() {
  const compatibility = Compatibility(
    status: CompatibilityStatus.ready,
    breedId: 1,
    breedName: 'Лабрадор',
    score: 0.9,
    summary: 'Отличный выбор',
    insights: ['Дружелюбен', 'Активный'],
    suggestions: [
      CompatibilitySuggestion(
        breedId: 2,
        breedName: 'Голден',
        score: 0.85,
        summary: 'Похожая порода',
      ),
      CompatibilitySuggestion(breedId: 3, breedName: 'Колли', score: 0.7),
    ],
  );

  testWidgets('MainBreedCard renders breed name, score, and summary', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MainBreedCard(compatibility: compatibility),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Лабрадор'), findsOneWidget);
    expect(find.text('90%'), findsOneWidget);
    expect(find.text('Отличный выбор'), findsOneWidget);
    // Insights больше не рендерятся внутри MainBreedCard —
    // их показывает ResultPage отдельной секцией.
  });

  testWidgets('MainBreedCard tap invokes onTap when provided', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MainBreedCard(
              compatibility: compatibility,
              onTap: () => tapped += 1,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(MainBreedCard));
    expect(tapped, 1);
  });

  testWidgets('SuggestionCard renders fields and is tappable', (tester) async {
    final suggestion = compatibility.suggestions.first;
    var tapped = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuggestionCard(
            suggestion: suggestion,
            onTap: () => tapped += 1,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Голден'), findsOneWidget);
    expect(find.text('85%'), findsOneWidget);
    expect(find.text('Похожая порода'), findsOneWidget);

    await tester.tap(find.byType(SuggestionCard));
    expect(tapped, 1);
  });

  group('MainBreedCard score color (по style текста)', () {
    Color scoreLabelColor(WidgetTester tester) {
      // Score-label — Text «90%»/«0%»/etc. Цвет его TextStyle = accent.
      final text = tester.widget<Text>(
        find.descendant(
          of: find.byType(MainBreedCard),
          matching: find.byWidgetPredicate(
            (w) => w is Text && (w.data?.endsWith('%') ?? false),
          ),
        ),
      );
      return text.style!.color!;
    }

    Future<void> pumpCard(WidgetTester tester, Compatibility c) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: MainBreedCard(compatibility: c)),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('compatible=true, risk=low → зелёный', (tester) async {
      await pumpCard(
        tester,
        const Compatibility(
          status: CompatibilityStatus.ready,
          breedName: 'X',
          score: 0.9,
          compatible: true,
        ),
      );
      expect(scoreLabelColor(tester), AppColors.accent);
    });

    testWidgets('compatible=false + risk=high → красный', (tester) async {
      await pumpCard(
        tester,
        const Compatibility(
          status: CompatibilityStatus.ready,
          breedName: 'X',
          score: 0,
          compatible: false,
          risk: CompatibilityRisk.high,
        ),
      );
      expect(scoreLabelColor(tester), AppColors.error);
    });

    testWidgets('risk=medium → оранжевый', (tester) async {
      await pumpCard(
        tester,
        const Compatibility(
          status: CompatibilityStatus.ready,
          breedName: 'X',
          score: 0.6,
          compatible: true,
          risk: CompatibilityRisk.medium,
        ),
      );
      expect(scoreLabelColor(tester), AppColors.warning);
    });
  });

  testWidgets('SuggestionCard without score shows em-dash', (tester) async {
    const suggestion = CompatibilitySuggestion(
      breedId: 99,
      breedName: 'Без оценки',
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SuggestionCard(suggestion: suggestion)),
      ),
    );

    expect(find.text('—'), findsOneWidget);
  });

  testWidgets(
    'ResultPage promotes first suggestion when primary breed is absent',
    (tester) async {
      const skippedCompatibility = Compatibility(
        status: CompatibilityStatus.skipped,
        summary: 'Показана подборка подходящих вариантов.',
        suggestions: [
          CompatibilitySuggestion(
            breedId: 139,
            breedName: 'Бордер-терьер',
            score: 1,
            risk: CompatibilityRisk.low,
            summary: 'Хорошо соответствует выбранным критериям.',
          ),
          CompatibilitySuggestion(
            breedId: 242,
            breedName: 'Мальтезе',
            score: 0.92,
            risk: CompatibilityRisk.low,
          ),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ResultPage(compatibility: skippedCompatibility),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(MainBreedCard), findsOneWidget);
      expect(find.text('Бордер-терьер'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(
        find.text('Хорошо соответствует выбранным критериям.'),
        findsOneWidget,
      );
      expect(find.text('Порода'), findsNothing);

      await tester.scrollUntilVisible(find.text('Мальтезе'), 300);
      expect(find.text('Мальтезе'), findsOneWidget);

      final cta = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(cta.onPressed, isNotNull);
    },
  );
}
