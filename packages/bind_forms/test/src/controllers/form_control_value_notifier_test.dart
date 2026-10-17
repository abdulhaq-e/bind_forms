import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:bind_forms/bind_forms.dart';

class _TestWidget extends StatefulWidget {
  final FormControl<bool> control;

  const _TestWidget({required this.control});

  @override
  State<_TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget> {
  late final notifier = FormControlValueNotifier<bool>(widget.control);
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
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListenableBuilder(
          listenable: notifier,
          builder: (context, _) {
            final errorText = notifier.errorText(context);
            return Column(
              children: [
                Checkbox(
                  value: notifier.value ?? false,
                  focusNode: focusController.focusNode,
                  isError: errorText != null,
                  onChanged: notifier.enabled ? notifier.onChanged : null,
                ),
                if (errorText != null) Text(errorText),
              ],
            );
          },
        ),
      ),
    );
  }
}

void main() {
  group('FormControlValueNotifier Tests', () {
    testWidgets('tapping the real Checkbox updates the FormControl', (
      tester,
    ) async {
      final control = FormControl<bool>(value: false);
      await tester.pumpWidget(_TestWidget(control: control));

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(control.value, isTrue);
    });

    testWidgets('updating the FormControl updates the real Checkbox', (
      tester,
    ) async {
      final control = FormControl<bool>(value: false);
      await tester.pumpWidget(_TestWidget(control: control));

      control.value = true;
      await tester.pump();

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isTrue);
    });

    testWidgets('a disabled FormControl disables the real Checkbox', (
      tester,
    ) async {
      final control = FormControl<bool>(value: false, disabled: true);
      await tester.pumpWidget(_TestWidget(control: control));

      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.onChanged, isNull);
    });

    testWidgets(
      'errorText appears after blur (focus lost) on an invalid control',
      (tester) async {
        final control = FormControl<bool>(
          value: false,
          validators: [Validators.requiredTrue],
        );
        await tester.pumpWidget(_TestWidget(control: control));

        expect(find.text(ValidationMessage.requiredTrue), findsNothing);

        // Focus then blur, same as a user tabbing through the field.
        final state = tester.state<_TestWidgetState>(find.byType(_TestWidget));
        state.focusController.focusNode.requestFocus();
        await tester.pump();
        state.focusController.focusNode.unfocus();
        // The focus -> touched -> notifyListeners chain crosses a couple of
        // microtask/frame boundaries (FocusManager applies focus changes
        // asynchronously), so settle before asserting.
        await tester.pumpAndSettle();

        expect(control.touched, isTrue);
        expect(find.text(ValidationMessage.requiredTrue), findsOneWidget);
      },
    );

    testWidgets('dispose does not throw', (tester) async {
      final control = FormControl<bool>(value: false);
      await tester.pumpWidget(_TestWidget(control: control));
      await tester.pumpWidget(const SizedBox());
    });
  });
}
