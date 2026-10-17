import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:bind_forms/bind_forms.dart';

class _TestWidget extends StatefulWidget {
  final FormControl<String> control;

  const _TestWidget({required this.control});

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget> {
  late final controller = FormControlTextEditingController<String>(
    widget.control,
  );
  final focusController = FocusNodeController();

  @override
  void initState() {
    super.initState();
    widget.control.registerFocusController(focusController);
  }

  @override
  void dispose() {
    widget.control.unregisterFocusController(focusController);
    focusController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListenableBuilder(
          listenable: controller,
          builder: (context, _) => TextField(
            controller: controller,
            focusNode: focusController.focusNode,
            decoration: InputDecoration(
              errorText: controller.errorText(context),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  group('FormControlTextEditingController Tests', () {
    testWidgets('typing in the real TextField updates the FormControl', (
      tester,
    ) async {
      final control = FormControl<String>();
      await tester.pumpWidget(_TestWidget(control: control));

      await tester.enterText(find.byType(TextField), 'John');
      await tester.pump();

      expect(control.value, 'John');
    });

    testWidgets('updating the FormControl updates the real TextField text', (
      tester,
    ) async {
      final control = FormControl<String>();
      await tester.pumpWidget(_TestWidget(control: control));

      control.value = 'Jane';
      await tester.pump();

      expect(find.text('Jane'), findsOneWidget);
    });

    testWidgets(
      'errorText is null until the control is touched, even if invalid',
      (tester) async {
        final control = FormControl<String>(validators: [Validators.required]);
        await tester.pumpWidget(_TestWidget(control: control));

        expect(control.invalid, isTrue);
        expect(find.text('Required'), findsNothing);
      },
    );

    testWidgets(
      'errorText appears after blur (focus lost) on an invalid control',
      (tester) async {
        final control = FormControl<String>(validators: [Validators.required]);
        await tester.pumpWidget(_TestWidget(control: control));

        // Focus then blur, same as a user tabbing through the field.
        await tester.tap(find.byType(TextField));
        await tester.pump();
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pump();

        expect(control.touched, isTrue);
        expect(find.text(ValidationMessage.required), findsOneWidget);
      },
    );

    testWidgets('dispose does not throw', (tester) async {
      final control = FormControl<String>();
      await tester.pumpWidget(_TestWidget(control: control));
      await tester.pumpWidget(const SizedBox());
    });
  });
}
