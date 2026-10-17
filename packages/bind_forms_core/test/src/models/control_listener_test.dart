import 'dart:async';

import 'package:bind_forms_core/bind_forms_core.dart';
import 'package:test/test.dart';

class _FakeFocusController implements FocusController {
  final _listeners = <void Function()>[];
  @override
  bool hasFocus = false;

  void userFocus(bool value) {
    hasFocus = value;
    for (final l in List.of(_listeners)) {
      l();
    }
  }

  @override
  void addListener(void Function() listener) => _listeners.add(listener);

  @override
  void removeListener(void Function() listener) => _listeners.remove(listener);

  @override
  void onControlFocusChanged(bool hasFocus) => this.hasFocus = hasFocus;
}

void main() {
  group('AbstractControl.addListener', () {
    test('notifies once per updateValue with value and status', () {
      final control = FormControl<String>(validators: [Validators.required]);
      final calls = <ControlChanges>[];
      control.addListener(calls.add);

      control.value = 'John';

      expect(calls, hasLength(1));
      expect(calls.single.value, true);
      expect(calls.single.status, true);
      expect(calls.single.touched, false);
    });

    test('listeners observe the final state, not intermediate ones', () {
      final control = FormControl<String>(
        value: 'a',
        validators: [Validators.required],
      );
      control.markAsTouched();
      final seen = <(String?, bool, ControlStatus)>[];
      control.addListener(
        (_) => seen.add((control.value, control.touched, control.status)),
      );

      // reset() marks untouched, updates the value and recalculates status:
      // several internal events, one notification.
      control.reset(value: 'b');

      expect(seen, [('b', false, ControlStatus.valid)]);
    });

    test('a group notifies once when a child changes', () {
      final form = FormGroup({
        'name': FormControl<String>(),
        'email': FormControl<String>(),
      });
      var groupCalls = 0;
      var childCalls = 0;
      form.addListener((_) => groupCalls++);
      form.control('name').addListener((_) => childCalls++);

      form.control('name').value = 'John';

      expect(childCalls, 1);
      expect(groupCalls, 1);
    });

    test('a group notifies once when patching many children', () {
      final form = FormGroup({
        'a': FormControl<int>(),
        'b': FormControl<int>(),
        'c': FormControl<int>(),
      });
      var groupCalls = 0;
      form.addListener((_) => groupCalls++);

      form.patchValue({'a': 1, 'b': 2, 'c': 3});

      expect(groupCalls, 1);
      expect(form.value, {'a': 1, 'b': 2, 'c': 3});
    });

    test('children notify before their ancestors', () {
      final form = FormGroup({'name': FormControl<String>()});
      final order = <String>[];
      form.addListener((_) => order.add('group'));
      form.control('name').addListener((_) => order.add('name'));

      form.control('name').value = 'John';

      expect(order, ['name', 'group']);
    });

    test('emitEvent: false does not notify', () {
      final control = FormControl<String>();
      var calls = 0;
      control.addListener((_) => calls++);

      control.updateValue('John', emitEvent: false);

      expect(calls, 0);
    });

    test('touched changes are reported', () {
      final control = FormControl<String>();
      final calls = <ControlChanges>[];
      control.addListener(calls.add);

      control.markAsTouched();

      expect(calls.single.touched, true);
      expect(calls.single.value, false);
    });

    test('collection changes are reported by arrays', () {
      final array = FormArray<int>([]);
      final calls = <ControlChanges>[];
      array.addListener(calls.add);

      array.add(FormControl<int>(value: 1));

      expect(calls, hasLength(1));
      expect(calls.single.collection, true);
      expect(calls.single.value, true);
    });

    test('changes made by a listener are delivered in a follow-up batch', () {
      final source = FormControl<int>();
      final mirror = FormControl<int>();
      source.addListener((_) => mirror.value = source.value);
      final mirrorValues = <int?>[];
      mirror.addListener((_) => mirrorValues.add(mirror.value));

      source.value = 1;
      source.value = 2;

      expect(mirrorValues, [1, 2]);
    });

    test('a listener removed during delivery is not called', () {
      final control = FormControl<int>();
      var secondCalls = 0;
      void second(ControlChanges _) => secondCalls++;
      control.addListener((_) => control.removeListener(second));
      control.addListener(second);

      control.value = 1;

      expect(secondCalls, 0);
    });

    test('removeListener stops notifications', () {
      final control = FormControl<int>();
      var calls = 0;
      void listener(ControlChanges _) => calls++;
      control.addListener(listener);
      control.removeListener(listener);

      control.value = 1;

      expect(calls, 0);
    });

    test('streams receive one coalesced event per update', () async {
      final form = FormGroup({
        'a': FormControl<int>(),
        'b': FormControl<int>(),
      });
      final statuses = <ControlStatus>[];
      final values = <Map<String, Object?>?>[];
      form.statusChanged.listen(statuses.add);
      form.valueChanges.listen(values.add);

      form.patchValue({'a': 1, 'b': 2});
      await Future<void>.delayed(Duration.zero);

      expect(statuses, [ControlStatus.valid]);
      expect(values, [
        {'a': 1, 'b': 2},
      ]);
    });

    test('a throwing listener does not stop other listeners', () async {
      final control = FormControl<int>();
      var secondCalls = 0;
      control.addListener((_) => throw StateError('boom'));
      control.addListener((_) => secondCalls++);

      // The error is reported to the zone, so capture it there.
      final errors = <Object>[];
      await runZonedGuarded(
        () async => control.value = 1,
        (error, _) => errors.add(error),
      );

      expect(secondCalls, 1);
      expect(errors.single, isA<StateError>());
    });
  });

  group('FocusController interface', () {
    test('UI focus loss marks the control touched in one notification', () {
      final control = FormControl<String>();
      final focus = _FakeFocusController();
      control.registerFocusController(focus);
      final calls = <ControlChanges>[];
      control.addListener(calls.add);

      focus.userFocus(true);
      focus.userFocus(false);

      expect(control.touched, true);
      expect(control.hasFocus, false);
      expect(calls, hasLength(2));
      expect(calls.last.focus, true);
      expect(calls.last.touched, true);
    });

    test('control.focus() is forwarded to the UI', () {
      final control = FormControl<String>();
      final focus = _FakeFocusController();
      control.registerFocusController(focus);

      control.focus();

      expect(focus.hasFocus, true);
    });
  });
}
