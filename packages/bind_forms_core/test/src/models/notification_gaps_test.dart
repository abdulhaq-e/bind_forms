import 'package:bind_forms_core/bind_forms_core.dart';
import 'package:test/test.dart';

void main() {
  group('pristine and touched changes notify', () {
    test('markAsPristine notifies a status change when it was dirty', () {
      final control = FormControl<String>()..markAsDirty();
      final calls = <ControlChanges>[];
      control.addListener(calls.add);

      control.markAsPristine();

      expect(control.pristine, true);
      expect(calls.single.status, true);
    });

    test('markAsPristine does not notify when already pristine', () {
      final control = FormControl<String>();
      var calls = 0;
      control.addListener((_) => calls++);

      control.markAsPristine();

      expect(calls, 0);
    });

    test('a parent notifies when a child touch makes it touched', () {
      final form = FormGroup({'name': FormControl<String>()});
      final calls = <ControlChanges>[];
      form.addListener(calls.add);

      form.control('name').markAsTouched();

      expect(form.touched, true);
      expect(calls.single.touched, true);
    });

    test('a parent notifies when its last touched child is untouched', () {
      final form = FormGroup({'name': FormControl<String>()});
      form.control('name').markAsTouched();
      final calls = <ControlChanges>[];
      form.addListener(calls.add);

      form.control('name').markAsUntouched();

      expect(form.touched, false);
      expect(calls.single.touched, true);
    });

    test('a parent notifies when its last dirty child becomes pristine', () {
      final form = FormGroup({'name': FormControl<String>()});
      form.control('name').markAsDirty();
      final calls = <ControlChanges>[];
      form.addListener(calls.add);

      form.control('name').markAsPristine();

      expect(form.pristine, true);
      expect(calls.single.status, true);
    });

    test('emitEvent: false is respected all the way up', () {
      final form = FormGroup({'name': FormControl<String>()});
      var calls = 0;
      form.addListener((_) => calls++);
      form.control('name').addListener((_) => calls++);

      form.control('name').markAsTouched(emitEvent: false);

      expect(form.touched, true);
      expect(calls, 0);
    });

    test('unfocus(touched: false) on a group notifies its own untouch', () {
      final form = FormGroup({'name': FormControl<String>()})
        ..markAllAsTouched();
      final calls = <ControlChanges>[];
      form.addListener(calls.add);

      form.unfocus(touched: false);

      expect(form.touched, false);
      expect(calls.any((c) => c.touched), true);
    });
  });

  group('errors identity', () {
    test('is stable while the errors are unchanged', () {
      final control = FormControl<String>(
        value: 'ab',
        validators: [Validators.minLength(5)],
      );
      final before = control.errors;

      // Re-runs the validator, which builds a new (equal) error map.
      control.value = 'abc';

      expect(control.errors, isNot(same(before)), reason: 'actual changed');
      final after = control.errors;
      control.updateValueAndValidity();
      expect(control.errors, same(after));
    });

    test('changes when the errors change', () {
      final control = FormControl<String>(validators: [Validators.required]);
      final invalid = control.errors;

      control.value = 'John';

      expect(control.errors, isNot(same(invalid)));
      expect(control.errors, isEmpty);
    });

    test('setErrors and removeError produce new snapshots', () {
      final control = FormControl<String>();
      final empty = control.errors;

      control.setErrors({'taken': true});
      final taken = control.errors;
      expect(taken, isNot(same(empty)));
      expect(taken, {'taken': true});

      control.removeError('taken');
      expect(control.errors, isNot(same(taken)));
      expect(control.errors, isEmpty);
    });

    test('a returned snapshot never changes underneath the caller', () {
      final control = FormControl<String>(validators: [Validators.required]);
      final snapshot = control.errors;

      control.value = 'John';

      expect(snapshot, {ValidationMessage.required: true});
      expect(() => (snapshot as Map)['x'] = 1, throwsUnsupportedError);
    });
  });
}
