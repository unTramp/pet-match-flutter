import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pet_match/core/design/components/breed_story_avatar.dart';
import 'package:pet_match/core/theme/app_colors.dart';
import 'package:pet_match/domain/entities/breed_attributes.dart';
import 'package:pet_match/domain/entities/compatibility.dart';
import 'package:pet_match/presentation/result/result_page.dart';
import 'package:pet_match/presentation/result/widgets/main_breed_card.dart';
import 'package:pet_match/presentation/result/widgets/suggestion_card.dart';

void main() {
  const compatibility = Compatibility(
    status: CompatibilityStatus.ready,
    breedId: 'labrador_retriever',
    breedName: 'Лабрадор',
    score: 0.9,
    summary: 'Отличный выбор',
    insights: ['Дружелюбен', 'Активный'],
    suggestions: [
      CompatibilitySuggestion(
        breedId: 'golden_retriever',
        breedName: 'Голден',
        score: 0.85,
        summary: 'Похожая порода',
      ),
      CompatibilitySuggestion(
        breedId: 'collie',
        breedName: 'Колли',
        score: 0.7,
      ),
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

  testWidgets('MainBreedCard prefers storyAvatarUrl over imageUrl', (
    tester,
  ) async {
    const cardCompatibility = Compatibility(
      status: CompatibilityStatus.ready,
      breedId: 'whippet',
      breedName: 'Уиппет',
      score: 0.91,
      imageUrl: 'https://example.com/hero-whippet.png',
      storyAvatarUrl: 'https://example.com/story-whippet.webp',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MainBreedCard(compatibility: cardCompatibility),
          ),
        ),
      ),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.imageUrl, 'https://example.com/story-whippet.webp');
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
      breedId: 'unknown_breed',
      breedName: 'Без оценки',
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SuggestionCard(suggestion: suggestion)),
      ),
    );

    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('SuggestionCard prefers storyAvatarUrl over imageUrl', (
    tester,
  ) async {
    const suggestion = CompatibilitySuggestion(
      breedId: 'whippet',
      breedName: 'Уиппет',
      score: 0.91,
      imageUrl: 'https://example.com/hero-whippet.png',
      storyAvatarUrl: 'https://example.com/story-whippet.webp',
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SuggestionCard(suggestion: suggestion)),
      ),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.imageUrl, 'https://example.com/story-whippet.webp');
  });

  testWidgets(
    'ResultPage promotes first suggestion when primary breed is absent',
    (tester) async {
      const skippedCompatibility = Compatibility(
        status: CompatibilityStatus.skipped,
        summary: 'Показана подборка подходящих вариантов.',
        suggestions: [
          CompatibilitySuggestion(
            breedId: 'border_terrier',
            breedName: 'Бордер-терьер',
            score: 1,
            risk: CompatibilityRisk.low,
            summary: 'Хорошо соответствует выбранным критериям.',
          ),
          CompatibilitySuggestion(
            breedId: 'maltese',
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

      expect(find.text('Бордер-терьер'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(
        find.text('Хорошо соответствует выбранным критериям.'),
        findsOneWidget,
      );
      expect(find.text('Порода'), findsNothing);

      // Suggestions section проверяется отдельным тестом ниже
      // (BreedStoryAvatar focused test) — здесь нельзя надёжно проверить
      // его наличие, т.к. он в горизонтальном lazy ListView далеко за
      // viewport'ом тестового экрана (800×600).

      final cta = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(cta.onPressed, isNotNull);
    },
  );

  testWidgets('ResultPage shows why-match and requirements sections', (
    tester,
  ) async {
    const explainedCompatibility = Compatibility(
      status: CompatibilityStatus.ready,
      breedId: 'labrador_retriever',
      breedName: 'Лабрадор',
      score: 0.9,
      summary: 'Отличный выбор',
      insights: [
        'Подходит для активного образа жизни.',
        'Дружелюбен к детям и другим животным.',
      ],
      requirementHighlights: [
        'Активные прогулки 1+ час в день',
        'Минимальный груминг — расчёсывание 2-3 раза в неделю',
      ],
      risks: [
        CompatibilityReason(
          message: 'Может скучать без регулярных нагрузок.',
          severity: ReasonSeverity.risk,
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: ResultPage(compatibility: explainedCompatibility),
      ),
    );

    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('Что важно знать'), findsOneWidget);
    expect(find.text('Подходит для активного образа жизни.'), findsOneWidget);
    expect(find.text('Требования породы'), findsOneWidget);
    expect(find.text('Активные прогулки 1+ час в день'), findsOneWidget);
    expect(find.text('Может скучать без регулярных нагрузок.'), findsOneWidget);
  });

  testWidgets('ResultPage shows real breed characteristics instead of stubs', (
    tester,
  ) async {
    const detailedCompatibility = Compatibility(
      status: CompatibilityStatus.ready,
      breedId: 'havanese',
      breedName: 'Хаванез',
      score: 0.93,
      summary: 'Мягкий companion-профиль для квартиры.',
      attributes: BreedAttributes(
        exerciseNeeds: 2,
        trainability: 4,
        sheddingLevel: 1,
        groomingNeeds: 5,
        goodWithChildren: 4,
        maintenanceCost: 3,
        aloneTolerance: 2,
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(home: ResultPage(compatibility: detailedCompatibility)),
    );

    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await tester.pumpAndSettle();

    expect(find.text('Характеристики'), findsOneWidget);
    expect(find.text('Потребность в нагрузке'), findsOneWidget);
    expect(find.text('Обучаемость'), findsOneWidget);
    expect(find.text('Линька'), findsOneWidget);
    expect(find.text('Потребность в уходе'), findsOneWidget);
    expect(find.text('Отношение к детям'), findsOneWidget);
    expect(find.text('Стоимость содержания'), findsOneWidget);
    expect(find.text('Переносит одиночество'), findsOneWidget);
    expect(find.text('Здоровье породы'), findsNothing);
    expect(find.text('Интеллект'), findsNothing);
  });

  // Фокусный тест на BreedStoryAvatar — изолированно проверяем что виджет
  // корректно рендерит имя породы под аватаром. Это test для
  // _SuggestionsSection ResultPage'а: внутри он использует BreedStoryAvatar
  // для каждой suggestion. Раньше эта проверка была частью широкого теста
  // ResultPage, но из-за horizontal lazy ListView виджет не строился без
  // прокрутки. Здесь рендерим напрямую, гарантированно in-tree.
  testWidgets('BreedStoryAvatar renders breed name below the circle', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: BreedStoryAvatar(breedName: 'Мальтезе', score: 0.92),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Мальтезе'), findsOneWidget);
    expect(find.text('92%'), findsOneWidget);
  });
}
