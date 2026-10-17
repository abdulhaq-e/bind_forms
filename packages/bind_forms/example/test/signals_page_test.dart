import 'package:bind_forms_example/signals_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Finder field(String label) => find.widgetWithText(TextField, label);
  ElevatedButton button(WidgetTester tester) => tester.widget<ElevatedButton>(
    find.widgetWithText(ElevatedButton, 'Login (enabled when valid)'),
  );

  testWidgets('errors appear on blur through the errorText signal', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignalsPage()));

    await tester.enterText(field('Email'), 'not-an-email');
    await tester.pump();
    expect(find.text('The email value must be a valid email'), findsNothing);

    await tester.tap(field('Password'));
    await tester.pump();
    expect(find.text('The email value must be a valid email'), findsOneWidget);
  });

  testWidgets('the summary and the button follow the form signals', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignalsPage()));
    expect(find.text('Nothing typed yet'), findsOneWidget);
    expect(button(tester).onPressed, isNull);

    await tester.enterText(field('Email'), 'john@example.com');
    await tester.enterText(field('Password'), 'correct horse');
    await tester.pump();

    expect(find.text('john@example.com · 13 characters'), findsOneWidget);
    expect(button(tester).onPressed, isNotNull);
  });
}
