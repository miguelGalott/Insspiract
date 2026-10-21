import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primeiro_app/servicos/Tema.dart';

void main() {
  testWidgets('chipInsspiract mostra o texto', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: chipInsspiract('Livre', cor: corVerde, fundo: corAvisoFundo),
        ),
      ),
    );

    expect(find.text('Livre'), findsOneWidget);
  });
}