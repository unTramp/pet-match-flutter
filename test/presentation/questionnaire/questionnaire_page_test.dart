import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_match/domain/entities/option.dart';
import 'package:pet_match/domain/entities/progress.dart';
import 'package:pet_match/presentation/questionnaire/widgets/option_tile.dart';
import 'package:pet_match/presentation/questionnaire/widgets/progress_bar.dart';
import 'package:pet_match/presentation/questionnaire/widgets/single_choice_widget.dart';

/// Widget-тесты на изолированные виджеты Question-страницы. Cubit мокать
/// смысла нет: всё, что Page делает в Question-state — рендерит progress,
/// заголовок и набор опций. Это покрывается напрямую на ProgressBar и
/// SingleChoiceWidget.
void main() {
  testWidgets('ProgressBar renders "N из M" и проценты', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgressBar(progress: Progress(answered: 0, total: 6)),
        ),
      ),
    );

    expect(find.textContaining('1 из 6'), findsOneWidget);
    expect(find.textContaining('0%'), findsOneWidget);
  });

  testWidgets('ProgressBar 3 из 6 → 50%', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProgressBar(progress: Progress(answered: 3, total: 6)),
        ),
      ),
    );

    expect(find.textContaining('50%'), findsOneWidget);
  });

  testWidgets('SingleChoiceWidget рендерит все опции', (tester) async {
    const options = [
      QuestionOption(id: 1, code: 'dog', label: 'Собака'),
      QuestionOption(id: 2, code: 'cat', label: 'Кошка'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChoiceWidget(
            options: options,
            selectedId: null,
            onSelect: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Собака'), findsOneWidget);
    expect(find.text('Кошка'), findsOneWidget);
  });

  testWidgets('SingleChoiceWidget tap → onSelect с правильным id', (
    tester,
  ) async {
    const options = [
      QuestionOption(id: 10, code: 'a', label: 'A'),
      QuestionOption(id: 11, code: 'b', label: 'B'),
    ];
    int? tapped;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChoiceWidget(
            options: options,
            selectedId: null,
            onSelect: (id) => tapped = id,
          ),
        ),
      ),
    );

    await tester.tap(find.text('B'));
    expect(tapped, 11);
  });

  testWidgets('SingleChoiceWidget marks selected radio', (tester) async {
    const options = [
      QuestionOption(id: 1, code: 'a', label: 'A'),
      QuestionOption(id: 2, code: 'b', label: 'B'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChoiceWidget(
            options: options,
            selectedId: 2,
            onSelect: (_) {},
          ),
        ),
      ),
    );

    final radios = tester.widgetList<OptionRadio>(find.byType(OptionRadio));
    expect(radios.length, 2);
    expect(radios.elementAt(0).selected, isFalse);
    expect(radios.elementAt(1).selected, isTrue);
  });
}
