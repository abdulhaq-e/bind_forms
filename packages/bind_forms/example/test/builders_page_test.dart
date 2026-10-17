import 'package:bind_forms_example/builders_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  Finder field(String label) => find.widgetWithText(TextField, label);
  FilledButton signUp(WidgetTester tester) =>
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Sign up'));

  testWidgets('the slider and the text field share the age control', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: BuildersPage()));
    expect(find.text('30'), findsOneWidget);

    await tester.enterText(field('Age'), '42');
    await tester.pump();
    expect(tester.widget<Slider>(find.byType(Slider)).value, 42);

    // Dragging the slider all the way left updates the text field.
    await tester.drag(find.byType(Slider), const Offset(-2000, 0));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('age errors show after blur', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BuildersPage()));

    await tester.enterText(field('Age'), '12');
    await tester.pump();
    expect(find.text('You must be at least 18'), findsNothing);

    await tester.tap(field('Name'));
    await tester.pump();
    expect(find.text('You must be at least 18'), findsOneWidget);
  });

  testWidgets('sign up is enabled once the form is valid', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BuildersPage()));
    expect(signUp(tester).onPressed, isNull);

    await tester.enterText(field('Name'), 'Ada');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    expect(signUp(tester).onPressed, isNotNull);

    await tester.tap(find.text('Sign up'));
    await tester.pump();
    expect(find.text('Signed up Ada, age 30'), findsOneWidget);
  });
}
