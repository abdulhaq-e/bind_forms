import 'package:bind_forms_example/main.dart';
import 'package:bind_forms_example/showcase/demo.dart';
import 'package:bind_forms_example/showcase/design_systems.dart';
import 'package:bind_forms_example/showcase/flutter_widgets.dart';
import 'package:bind_forms_example/showcase/pickers.dart';
import 'package:bind_forms_example/showcase/third_party_inputs.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter_test/flutter_test.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:material_ui/material_ui.dart';

void main() {
  final sections = {
    'Flutter widgets': (flutterWidgetDemos, (Widget child) => child),
    'Third-party inputs': (thirdPartyInputDemos, (Widget child) => child),
    'Pickers': (pickerDemos, (Widget child) => child),
    'Fluent UI': (
      fluentDemos,
      (Widget child) =>
          fluent.FluentTheme(data: fluent.FluentThemeData(), child: child),
    ),
    'macOS UI': (
      macosDemos,
      (Widget child) =>
          macos.MacosTheme(data: macos.MacosThemeData.light(), child: child),
    ),
  };

  // Each demo on its own, so a failure names the widget.
  for (final MapEntry(key: section, value: (demos, wrap)) in sections.entries) {
    group(section, () {
      for (var i = 0; i < demos().length; i++) {
        testWidgets('demo #$i renders and resets without errors', (
          tester,
        ) async {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates: showcaseLocalizationsDelegates,
              home: Scaffold(
                body: wrap(SingleChildScrollView(child: demos()[i])),
              ),
            ),
          );
          await tester.pump();
          final card = tester.widget<DemoCard>(find.byType(DemoCard));

          await tester.tap(find.byTooltip('Reset from code'));
          await tester.pump();

          expect(tester.takeException(), isNull, reason: '${card.title} threw');
        });
      }
    });
  }

  testWidgets('the catalog opens every section', (tester) async {
    await tester.pumpWidget(const MyApp());

    for (final (title, _, _, _) in CatalogPage.sections) {
      await tester.scrollUntilVisible(find.text(title), 100);
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });
}
