import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'lib/clean_chat_interface.dart';
import 'lib/screens/reminders_screen.dart';

void main() {
  testWidgets('Navigation to RemindersScreen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: CleanChatInterface(
        onReturnToOrb: () {},
        sessionId: 'test',
      ),
    ));

    // Verify that the navigation works
    expect(find.byType(CleanChatInterface), findsOneWidget);
    
    // Try to find the bottom navigation
    expect(find.text('Reminders'), findsOneWidget);
    
    // Tap the reminders button
    await tester.tap(find.text('Reminders'));
    await tester.pumpAndSettle();
    
    // Verify that we navigated to RemindersScreen
    expect(find.byType(RemindersScreen), findsOneWidget);
  });
}
