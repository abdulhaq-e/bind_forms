import 'package:bind_forms_core/bind_forms_core.dart';
import 'package:bind_forms_streams/bind_forms_streams.dart';
import 'package:test/test.dart';

/// Lets queued broadcast-stream events arrive.
Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  test('the same stream is returned every time', () {
    final control = FormControl<int>();

    expect(control.valueChanges, same(control.valueChanges));
  });

  test('one coalesced event per operation, with the final state', () async {
    final form = FormGroup({'a': FormControl<int>(), 'b': FormControl<int>()});
    final statuses = <ControlStatus>[];
    final values = <Map<String, Object?>?>[];
    form.statusChanged.listen(statuses.add);
    form.valueChanges.listen(values.add);

    form.patchValue({'a': 1, 'b': 2});
    await _flush();

    expect(statuses, [ControlStatus.valid]);
    expect(values, [
      {'a': 1, 'b': 2},
    ]);
  });

  test('each stream only emits for what it reports', () async {
    final control = FormControl<String>(validators: [Validators.required]);
    final values = <String?>[];
    final statuses = <ControlStatus>[];
    final touches = <bool>[];
    control.valueChanges.listen(values.add);
    control.statusChanged.listen(statuses.add);
    control.touchChanges.listen(touches.add);

    control.markAsTouched();
    control.value = 'x';
    await _flush();

    expect(touches, [true]);
    expect(values, ['x']);
    expect(statuses, [ControlStatus.valid]);
  });

  test('focusChanges emits focus state', () async {
    final control = FormControl<String>();
    final focus = <bool>[];
    control.focusChanges.listen(focus.add);

    control.focus();
    control.unfocus();
    await _flush();

    expect(focus, [true, false]);
  });

  test('collectionChanges emits the children', () async {
    final array = FormArray<int>([]);
    final events = <List<AbstractControl<Object?>>>[];
    array.collectionChanges.listen(events.add);

    final control = FormControl<int>();
    array.add(control);
    await _flush();

    expect(events.single, [control]);
  });

  test('listens to the control only while subscribed', () async {
    final control = FormControl<int>();
    final values = <int?>[];
    final subscription = control.valueChanges.listen(values.add);

    control.value = 1;
    await _flush();
    await subscription.cancel();
    control.value = 2;
    control.valueChanges.listen(values.add);
    control.value = 3;
    await _flush();

    expect(values, [1, 3]);
  });

  test('streams close when the control is disposed', () async {
    final control = FormControl<int>();
    var done = false;
    control.valueChanges.listen(null, onDone: () => done = true);

    control.dispose();
    await _flush();

    expect(done, true);
    await expectLater(control.statusChanged, emitsDone);
  });
}
