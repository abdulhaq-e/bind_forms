import 'package:bind_forms_core/bind_forms_core.dart';
import 'package:bind_forms_signals/bind_forms_signals.dart';
import 'package:signals_core/signals_core.dart';
import 'package:test/test.dart';

/// Runs [read] in an effect, returning how many times it has run. The
/// effect is disposed after the test.
int Function() track(void Function() read) {
  var runs = 0;
  final dispose = effect(() {
    read();
    runs++;
  });
  addTearDown(dispose);
  return () => runs;
}

void main() {
  test('returns the same instance for a control', () {
    final control = FormControl<String>();

    expect(control.signals, same(control.signals));
  });

  test('starts with the control state', () {
    final control = FormControl<String>(
      value: 'a',
      validators: [Validators.minLength(3)],
    );
    final s = control.signals;

    expect(s.value.value, 'a');
    expect(s.status.value, ControlStatus.invalid);
    expect(s.invalid.value, true);
    expect(s.errors.value.keys, [ValidationMessage.minLength]);
    expect(s.touched.value, false);
    expect(s.dirty.value, false);
  });

  test('reads are fresh outside effects', () {
    final control = FormControl<String>();
    final s = control.signals;

    control.value = 'John';

    expect(s.value.value, 'John');
  });

  test('an effect over value and status runs once per update', () {
    final control = FormControl<String>(validators: [Validators.required]);
    final s = control.signals;
    final seen = <(String?, ControlStatus)>[];
    final runs = track(() => seen.add((s.value.value, s.status.value)));

    control.value = 'John';

    expect(runs(), 2, reason: 'initial run + one update');
    // Never a new value next to the old status.
    expect(seen, [
      (null, ControlStatus.invalid),
      ('John', ControlStatus.valid),
    ]);
  });

  test('a group patch runs a group effect once', () {
    final form = FormGroup({
      'a': FormControl<int>(),
      'b': FormControl<int>(),
      'c': FormControl<int>(),
    });
    final s = form.signals;
    final runs = track(() => s.value.value);

    form.patchValue({'a': 1, 'b': 2, 'c': 3});

    expect(runs(), 2);
    expect(s.value.value, {'a': 1, 'b': 2, 'c': 3});
  });

  test('an unchanged group value does not re-run effects', () {
    final form = FormGroup({'name': FormControl<String>(value: 'a')});
    final s = form.signals;
    final runs = track(() => s.value.value);

    // Touching changes the group, but its value map is structurally equal.
    form.control('name').markAsTouched();

    expect(runs(), 1);
    expect(s.touched.value, true);
  });

  test('errors update, and unchanged errors do not re-run effects', () {
    final control = FormControl<String>(
      value: 'ab',
      validators: [Validators.minLength(5)],
    );
    final s = control.signals;
    final runs = track(() => s.errors.value);

    control.updateValueAndValidity();
    expect(runs(), 1, reason: 'same errors');

    control.value = 'abcdef';
    expect(runs(), 2);
    expect(s.errors.value, isEmpty);
  });

  test('a group touched by its child updates', () {
    final form = FormGroup({'name': FormControl<String>()});
    final s = form.signals;

    form.control('name').markAsTouched();
    expect(s.touched.value, true);

    form.control('name').markAsUntouched();
    expect(s.touched.value, false);
  });

  test('dirty goes back to false on markAsPristine', () {
    final control = FormControl<String>()..markAsDirty();
    final s = control.signals;
    expect(s.dirty.value, true);

    control.markAsPristine();

    expect(s.dirty.value, false);
  });

  test('enabled and disabled', () {
    final control = FormControl<String>();
    final s = control.signals;

    control.markAsDisabled();
    expect(s.enabled.value, false);
    expect(s.status.value, ControlStatus.disabled);

    control.markAsEnabled();
    expect(s.enabled.value, true);
  });

  test('array children update when controls are added', () {
    final array = FormArray<int>([]);
    final s = array.signals;
    final runs = track(() => s.children.value);

    array.add(FormControl<int>(value: 1));

    expect(runs(), 2);
    expect(s.children.value, hasLength(1));
    expect(s.value.value, [1]);
  });

  test('pending while an async validator runs', () async {
    final control = FormControl<String>(
      asyncValidators: [
        Validators.delegateAsync((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return {'taken': true};
        }),
      ],
    );
    final s = control.signals;

    control.value = 'john';
    expect(s.pending.value, true);

    // Past the default 250ms debounce plus the validator's own delay.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(s.pending.value, false);
    expect(s.errors.value, {'taken': true});
  });

  group('errorText', () {
    test('appears once touched, from the given messages', () {
      final control = FormControl<String>(validators: [Validators.required]);
      final text = control.signals.errorText(
        validationMessages: {ValidationMessage.required: (_) => 'Required'},
      );
      expect(text.value, isNull);

      control.markAsTouched();
      expect(text.value, 'Required');

      control.value = 'John';
      expect(text.value, isNull);
    });

    test('uses fallback messages and custom showErrors', () {
      final control = FormControl<String>(validators: [Validators.required]);
      final text = control.signals.errorText(
        fallbackMessages: {ValidationMessage.required: (_) => 'Fallback'},
        showErrors: (control) => control.invalid,
      );

      expect(text.value, 'Fallback');
    });

    test('re-runs an effect only when the text changes', () {
      final control = FormControl<String>(validators: [Validators.required]);
      final text = control.signals.errorText();
      final runs = track(() => text.value);

      control.markAsTouched();
      expect(runs(), 2);

      // Still invalid with the same message: the computed stays equal.
      control.updateValueAndValidity();
      expect(runs(), 2);
    });
  });
}
