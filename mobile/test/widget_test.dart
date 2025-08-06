// Testes para o aplicativo C'Alma em Flutter
//
// Este arquivo contém testes de widgets básicos para o aplicativo C'Alma.
// Seguindo o TDD, os testes serão ampliados conforme avançamos no desenvolvimento.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calma_flutter/main.dart';

void main() {
  testWidgets('C\'Alma app smoke test', (WidgetTester tester) async {
    // Constrói a aplicação e dispara um frame
    await tester.pumpWidget(const CalmaApp());
    
    // Verifica se a aplicação é construída sem erros
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
