# bind_forms_signals

Any bind_forms control's state as [signals](https://pub.dev/packages/signals).
Pure Dart: depends only on `bind_forms_core` and `signals_core`.

```dart
final email = form.control('email') as FormControl<String>;
final s = email.signals; // same instance every time, nothing to dispose

s.value;    // ReadonlySignal<String?>
s.status;   // ReadonlySignal<ControlStatus>
s.errors;   // ReadonlySignal<Map<String, dynamic>>
s.touched;  // ReadonlySignal<bool>, also dirty, focused, children
s.valid;    // computed from status, also invalid, pending, enabled

final error = s.errorText(
  validationMessages: {ValidationMessage.email: (_) => 'Not an email'},
);
```

Each control operation notifies once, after it completes, and every signal
that changed is updated in a single `batch`. An effect reading `value` and
`status` runs once per update and never sees a new value next to an old
status.

The signals are read-only: change the control itself, so validation and
dirty tracking stay in charge.

In Flutter, add `signals_flutter` and rebuild with `SignalBuilder`. Widgets
still bind through the `bind_forms` adapters, since a `TextField` needs a
`TextEditingController` whatever you observe it with:

```dart
SignalBuilder(
  builder: (context) => TextField(
    controller: emailController,          // FormControlTextEditingController
    focusNode: emailController.focusNode,
    decoration: InputDecoration(errorText: error.value),
  ),
);
```

See `packages/bind_forms/example/lib/signals_page.dart` for a full form.
