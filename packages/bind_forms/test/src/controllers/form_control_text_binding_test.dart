import 'package:bind_forms/bind_forms.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for a third-party controller subclass like `CodeController`.
class _UppercaseController extends TextEditingController {}

void main() {
  test('syncs an existing controller in both directions', () {
    final control = FormControl<String>(value: 'a');
    final text = _UppercaseController()..text = 'ignored';
    addTearDown(text.dispose);
    final binding = FormControlTextBinding(control, text);
    addTearDown(binding.dispose);

    expect(text.text, 'a', reason: 'the control value wins at creation');

    text.text = 'typed';
    expect(control.value, 'typed');
    expect(control.dirty, true);

    control.value = 'set';
    expect(text.text, 'set');
  });

  test('notifies once per control change, including typing', () {
    final control = FormControl<String>(validators: [Validators.required]);
    final text = TextEditingController();
    addTearDown(text.dispose);
    final binding = FormControlTextBinding(control, text);
    addTearDown(binding.dispose);
    var calls = 0;
    binding.addListener(() => calls++);

    text.text = 'John';
    expect(calls, 1);

    control.value = 'Jane';
    expect(calls, 2);

    control.markAsTouched();
    expect(calls, 3);
  });

  test('dispose stops syncing and leaves the controller usable', () {
    final control = FormControl<String>();
    final text = TextEditingController();
    addTearDown(text.dispose);
    FormControlTextBinding(control, text).dispose();

    text.text = 'after';
    expect(control.value, isNull);
  });
}
