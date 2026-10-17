import 'package:bind_forms_example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Finder field(String label) => find.widgetWithText(TextField, label);

  testWidgets('submitting an empty form shows every error', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    // The app-wide message from BindFormsConfig, for both text fields.
    expect(find.text('This field must not be empty'), findsNWidgets(2));
    final checkbox = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile),
    );
    expect(checkbox.isError, true);
  });

  testWidgets('errors appear on blur, not while typing', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(field('Email'), 'not-an-email');
    await tester.pump();
    expect(find.text('The email value must be a valid email'), findsNothing);

    // Moving focus to the password field blurs the email field.
    await tester.tap(field('Password'));
    await tester.pump();
    expect(find.text('The email value must be a valid email'), findsOneWidget);
  });

  testWidgets('a valid form enables the second login button', (tester) async {
    await tester.pumpWidget(const MyApp());
    ElevatedButton enabledWhenValid() => tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Login (enabled when valid)'),
    );
    expect(enabledWhenValid().onPressed, isNull);

    await tester.enterText(field('Email'), 'john@example.com');
    await tester.enterText(field('Password'), 'correct horse');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();

    expect(enabledWhenValid().onPressed, isNotNull);

    await tester.tap(find.text('Login (enabled when valid)'));
    await tester.pump();
    expect(find.text('Logged in as john@example.com'), findsOneWidget);
  });
}
