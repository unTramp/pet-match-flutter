import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/domain/entities/compatibility.dart';
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

    expect(find.text('Лабрадор'), findsOneWidget);
    expect(find.text('90%'), findsOneWidget);
    expect(find.text('Отличный выбор'), findsOneWidget);
    expect(find.text('Дружелюбен'), findsOneWidget);
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

    expect(find.text('Голден'), findsOneWidget);
    expect(find.text('85%'), findsOneWidget);
    expect(find.text('Похожая порода'), findsOneWidget);

    await tester.tap(find.byType(SuggestionCard));
    expect(tapped, 1);
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
}
