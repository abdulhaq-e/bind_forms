import 'package:bind_forms/bind_forms.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormControlTextEditingController notifications', () {
    test('typing notifies once and updates the control synchronously', () {
      final control = FormControl<String>(validators: [Validators.required]);
      final controller = FormControlTextEditingController(control);
      addTearDown(controller.dispose);
      var calls = 0;
      controller.addListener(() => calls++);

      controller.text = 'John';

      expect(control.value, 'John');
      expect(control.dirty, true);
      expect(calls, 1);
    });

    test('a control value change updates the text synchronously, once', () {
      final control = FormControl<String>();
      final controller = FormControlTextEditingController(control);
      addTearDown(controller.dispose);
      var calls = 0;
      controller.addListener(() => calls++);

      control.value = 'John';

      expect(controller.text, 'John');
      expect(control.pristine, true);
      expect(calls, 1);
    });

    test('a status-only change notifies once', () {
      final control = FormControl<String>(value: 'a');
      final controller = FormControlTextEditingController(control);
      addTearDown(controller.dispose);
      var calls = 0;
      controller.addListener(() => calls++);

      control.setErrors({'taken': true});

      expect(controller.text, 'a');
      expect(calls, 1);
    });

    test('touched changes notify once', () {
      final control = FormControl<String>();
      final controller = FormControlTextEditingController(control);
      addTearDown(controller.dispose);
      var calls = 0;
      controller.addListener(() => calls++);

      control.markAsTouched();

      expect(calls, 1);
    });

    test('touching an empty field leaves a null value and pristine', () {
      final control = FormControl<String>();
      final controller = FormControlTextEditingController(control);
      addTearDown(controller.dispose);

      control.markAsTouched();

      expect(control.value, isNull);
      expect(control.pristine, true);
    });

    test('moving the caret does not touch the control', () {
      final control = FormControl<String>();
      final controller = FormControlTextEditingController(control);
      addTearDown(controller.dispose);

      controller.selection = const TextSelection.collapsed(offset: 0);

      expect(control.value, isNull);
      expect(control.pristine, true);
    });

    test('picks the int value accessor for int controls', () {
      final control = FormControl<int>(value: 1);
      final controller = FormControlTextEditingController(control);
      addTearDown(controller.dispose);

      expect(controller.text, '1');
      controller.text = '42';
      expect(control.value, 42);
      control.value = 7;
      expect(controller.text, '7');
    });

    test('dispose stops listening to the control', () {
      final control = FormControl<String>();
      final controller = FormControlTextEditingController(control);
      controller.dispose();

      expect(() => control.value = 'John', returnsNormally);
    });
  });

  group('FormControlValueNotifier notifications', () {
    test('one notification per control update', () {
      final control = FormControl<bool>(validators: [Validators.requiredTrue]);
      final notifier = FormControlValueNotifier(control);
      addTearDown(notifier.dispose);
      var calls = 0;
      notifier.addListener(() => calls++);

      control.value = true;

      expect(calls, 1);
    });

    test('onChanged marks the control dirty only when the value changes', () {
      final control = FormControl<bool>(value: false);
      final notifier = FormControlValueNotifier(control);
      addTearDown(notifier.dispose);

      notifier.onChanged(false);
      expect(control.pristine, true);

      notifier.onChanged(true);
      expect(control.value, true);
      expect(control.dirty, true);
    });
  });

  testWidgets('errorText falls back to BindFormsConfig messages', (
    tester,
  ) async {
    final control = FormControl<String>(
      validators: [Validators.required],
      touched: true,
    );
    final controller = FormControlTextEditingController(control);
    addTearDown(controller.dispose);
    String? errorText;

    await tester.pumpWidget(
      BindFormsConfig(
        validationMessages: {
          ValidationMessage.required: (_) => 'Required (from config)',
        },
        child: Builder(
          builder: (context) {
            errorText = controller.errorText(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(errorText, 'Required (from config)');
  });
}
