# bind_forms_streams

Any bind_forms control's changes as Dart `Stream`s. Pure Dart: depends only
on `bind_forms_core`.

```dart
import 'package:bind_forms_streams/bind_forms_streams.dart';

final email = form.formControl<String>('email');

email.valueChanges;       // Stream<String?>
email.statusChanged;      // Stream<ControlStatus>
email.touchChanges;       // Stream<bool>
email.focusChanges;       // Stream<bool>, FormControl only
form.collectionChanges;   // Stream<List<AbstractControl>>, FormGroup/FormArray only
```

These are the streams `reactive_forms` has on every control, kept out of the
core so that apps that don't use streams don't pay for them. Migrating from
`reactive_forms` is an import away.

Each stream emits once per control operation that changed what it reports,
with the control's state after the operation: `form.patchValue(...)` on a
group emits one `valueChanges` event, not one per child. Events arrive
asynchronously, like any broadcast stream. To react synchronously, use
`control.addListener` from `bind_forms_core`, which these streams are built
on.

A stream listens to its control only while it has subscribers, and closes
when the control is disposed. There is nothing to dispose.
