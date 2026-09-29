import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculadora_material/main.dart';

void main() {
  testWidgets('calcula operações básicas', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    Future<void> tap(String label) async {
      await tester.tap(find.text(label));
      await tester.pump();
    }

    await tap('7');
    await tap('+');
    await tap('5');
    await tap('=');

    expect(find.text('12'), findsOneWidget);
    expect(find.text('7 + 5 ='), findsOneWidget);
  });

  testWidgets('mostra erro ao dividir por zero', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    for (final label in ['8', '÷', '0', '=']) {
      await tester.tap(find.text(label));
      await tester.pump();
    }

    expect(find.text('Erro'), findsOneWidget);
    expect(find.text('Não é possível dividir por zero'), findsOneWidget);
  });

  testWidgets('limpa a calculadora', (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('9'));
    await tester.pump();
    await tester.tap(find.text('AC'));
    await tester.pump();

    final display = tester.widget<Text>(
      find.byKey(const Key('calculator-display')),
    );
    expect(display.data, '0');
  });
}
