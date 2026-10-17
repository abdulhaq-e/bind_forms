# bind_forms

Bind real Flutter widgets to form controls without wrapping them.

```dart
final form = FormGroup({
  'email': FormControl<String>(validators: [Validators.required, Validators.email]),
  'acceptTerms': FormControl<bool>(value: false, validators: [Validators.requiredTrue]),
});

// A real TextField: every parameter is TextField's own.
TextControlBuilder(
  control: form.formControl<String>('email'),
  builder: (context, field) => TextField(
    controller: field,
    focusNode: field.focusNode,
    decoration: InputDecoration(errorText: field.errorText(context)),
  ),
);

// Widgets with value + onChanged: Checkbox, Switch, Slider, DropdownButton, ...
ValueControlBuilder(
  control: form.formControl<bool>('acceptTerms'),
  builder: (context, field) => Checkbox(
    value: field.value ?? false,
    onChanged: field.enabled ? field.onChanged : null,
  ),
);

// Anything that only reads a control.
ControlBuilder(
  control: form,
  builder: (context, form) => FilledButton(
    onPressed: form.valid ? submit : null,
    child: const Text('Submit'),
  ),
);
```

The builders only own the adapters' lifecycle. To manage that yourself (or
to observe with something other than `Listenable`, e.g.
`bind_forms_signals`), use the adapters directly:

| Adapter | For |
| --- | --- |
| `FormControlTextEditingController` | Any widget that takes a `TextEditingController`. |
| `FormControlTextBinding` | A `TextEditingController` subclass you already have (`CodeController`, ...). |
| `FormControlValueNotifier` | Any widget that takes `value` and `onChanged`. |
| `control.listenable` | Any control as a `Listenable`, nothing to dispose. |

Several adapters can be bound to one control, e.g. a slider and a text
field; each has its own `focusNode`, and blurring either marks the control
touched.

## material_ui types

`TimeOfDayValueAccessor` (for material_ui's `TimeOfDay`) lives in a separate
library, so the main one never imports material_ui:

```dart
import 'package:bind_forms/material_ui.dart';

FormControlTextEditingController(
  form.formControl<TimeOfDay>('alarm'),
  valueAccessor: TimeOfDayValueAccessor(),
);
```
