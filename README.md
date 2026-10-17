# bind_forms

Model-driven forms for Flutter that bind to real widgets instead of wrapping them.

You describe the form once, as a tree of controls with validators. Then you
build the widgets yourself (`TextField`, `Checkbox`, a third-party date
picker, anything) and hand each one an adapter that keeps it in sync with
its control. bind_forms never re-declares a widget's constructor, so it works
with any widget library, at any version, with no wrapper package needed.

| Package | Description |
| --- | --- |
| [`bind_forms_core`](packages/bind_forms_core) | Pure Dart form model: controls, groups, arrays, validators. |
| [`bind_forms`](packages/bind_forms) | Flutter adapters over the core: text controllers, value notifiers, focus, builders, `control.listenable`. |
| [`bind_forms_signals`](packages/bind_forms_signals) | Any control's state as signals (`control.signals`). Pure Dart. |
| [`bind_forms_streams`](packages/bind_forms_streams) | Any control's changes as streams (`control.valueChanges`, ...). Pure Dart. |

## Installation

```sh
flutter pub add bind_forms
# Optional, to observe controls with signals or streams:
dart pub add bind_forms_signals
dart pub add bind_forms_streams
```

`package:bind_forms/bind_forms.dart` re-exports the core, so it is the only
import a Flutter app needs.

## Usage

### 1. Describe the form

```dart
final form = FormGroup({
  'email': FormControl<String>(
    validators: [Validators.required, Validators.email],
  ),
  'password': FormControl<String>(
    validators: [Validators.required, Validators.minLength(8)],
  ),
  'acceptTerms': FormControl<bool>(
    value: false,
    validators: [Validators.requiredTrue],
  ),
});
```

The model is plain Dart. It holds values, validation (sync, async and
debounced), dirty, touched and focus state, and nested `FormGroup`s and
`FormArray`s. It doesn't depend on Flutter, so it can be unit-tested with
`dart test` and shared with non-Flutter code.

Look controls up by name or dotted path, with their type:

```dart
final email = form.formControl<String>('email');
final city = form.formControl<String>('address.city');
final tags = form.formArray<String>('tags');
```

### 2. Bind widgets

The builders create an adapter, rebuild when its control changes, and
dispose it. The widget inside is the real one, so every parameter is that
widget's own:

```dart
TextControlBuilder(
  control: form.formControl<String>('email'),
  validationMessages: {
    ValidationMessage.email: (_) => 'Enter a valid email',
  },
  builder: (context, field) => TextField(
    controller: field,                 // a TextEditingController
    focusNode: field.focusNode,        // blur marks the control touched
    decoration: InputDecoration(
      labelText: 'Email',
      errorText: field.errorText(context),
    ),
    keyboardType: TextInputType.emailAddress,
  ),
),

// Anything with value + onChanged: Checkbox, Switch, Slider, Radio,
// DropdownButton, SegmentedButton, third-party pickers, ...
ValueControlBuilder(
  control: form.formControl<bool>('acceptTerms'),
  builder: (context, field) => CheckboxListTile(
    value: field.value ?? false,
    onChanged: field.enabled ? field.onChanged : null,
    isError: field.errorText(context) != null,
    title: const Text('I accept the terms'),
  ),
),

// Anything that only reads a control, e.g. a submit button.
ControlBuilder(
  control: form,
  builder: (context, form) => FilledButton(
    onPressed: form.valid ? submit : null,
    child: const Text('Submit'),
  ),
),
```

By default an error shows once the control is invalid and touched, which
happens when its widget loses focus. To show every error on submit, call
`form.markAllAsTouched()`. To change the rule for one field, pass
`showErrors`.

For pickers that open a dialog, call `showDatePicker` (or any other picker)
yourself and put the result in the control with `field.onChanged(picked)`.

### 3. Or use the adapters directly

The builders are optional. When you'd rather own the adapters, for example to
keep them in a controller class or to observe them with something other than
a `Listenable`, create them yourself and dispose them with the widget:

| Adapter | Binds |
| --- | --- |
| `FormControlTextEditingController<T>` | Any widget that takes a `TextEditingController`. Converts `int`, `double` and `DateTime` to and from text, or any type through a `valueAccessor`. |
| `FormControlTextBinding<T>` | A `TextEditingController` subclass the widget requires, such as a code editor's `CodeController`. |
| `FormControlValueNotifier<T>` | Any widget that takes `value` and `onChanged`. |
| `control.listenable` | Any control as a `Listenable`. It's cached per control, so there is nothing to dispose. |

Each adapter exposes `focusNode` and `errorText(context)`. A control can be
bound to several widgets at once, for example a slider and a text field for
the same number. Each widget gets its own focus node, and blurring either one
marks the control touched.

App-wide validation messages go in a `BindFormsConfig` above your app.
Adapters use them for any error key they have no message of their own for:

```dart
BindFormsConfig(
  validationMessages: {
    ValidationMessage.required: (_) => 'This field is required',
  },
  child: MaterialApp(...),
);
```

### 4. Pick your state management

Every control has one change primitive: a synchronous listener, called
**once per operation** with what changed. `form.patchValue(...)` across ten
fields notifies the form once, after every field has its new value and
status, never in between.

```dart
form.addListener((changes) {
  if (changes.value) save(form.value);
});
```

Everything else is a thin layer over that listener, so you pick what fits
your app:

| You use | Observe with |
| --- | --- |
| Plain Flutter | `ListenableBuilder(listenable: control.listenable, ...)`, or `ControlBuilder` |
| [signals](https://pub.dev/packages/signals) | `control.signals.value`, `.status`, `.errors`, `.errorText(...)` from `bind_forms_signals` |
| Streams / `StreamBuilder` / Rx | `control.valueChanges`, `.statusChanged`, ... from `bind_forms_streams` |
| Anything else (Riverpod, Bloc, MobX, ...) | `control.addListener`: an adapter for another library is about a page of code (see [`control_signals.dart`](packages/bind_forms_signals/lib/src/control_signals.dart)) |

## Compared to reactive_forms

bind_forms is derived from [reactive_forms](https://pub.dev/packages/reactive_forms).
The form model (`FormControl`, `FormGroup`, `FormArray`, `Validators`, `fb`,
value accessors) is reactive_forms' model with the same API, so form
definitions and validators carry over. The difference is how widgets connect
to it.

reactive_forms **wraps** widgets. `ReactiveTextField` re-declares
`TextField`'s ~60 parameters and forwards them, and every other input needs
its own wrapper. Those wrappers live in reactive_forms itself and in the 50+
packages of reactive_forms_widgets. Each wrapper is pinned to the API of the
widget it wraps. When Flutter or the third-party package adds a parameter,
renames one, or ships a major version, the wrapper has to follow, or you
can't upgrade.

bind_forms **binds** widgets. It only uses the binding points every input
widget already has: a `TextEditingController`, a `value`/`onChanged` pair, a
`FocusNode`. Those haven't changed in years and don't depend on the widget,
so there are no wrapper packages to maintain or wait for.

| | reactive_forms | bind_forms |
| --- | --- | --- |
| Form model | `FormControl`, `FormGroup`, `FormArray`, validators | The same |
| Connecting a `TextField` | `ReactiveTextField`, a wrapper | The real `TextField` with a `FormControlTextEditingController` |
| Third-party inputs | One wrapper package each (reactive_forms_widgets) | Bound directly, at whatever version you use. The example covers the widgets of 49 of the 52 wrapper packages. |
| New widget parameters | Wait for the wrapper to add them | Available immediately |
| Finding a control | `formControlName: 'email'`, resolved from the nearest `ReactiveForm` | `form.formControl<String>('email')`, explicit and typed |
| Change notifications | A separate asynchronous stream for each kind of change (value, status, touched, focus, collection) | One synchronous, batched notification per operation, covering every kind of change, with the final state |
| State management | Streams, plus reactive_forms' own consumer and listenable-builder widgets | `Listenable`, signals, streams, or your own adapter over `addListener` |
| Flutter dependency | Model and widgets in one Flutter package | Model is pure Dart. Flutter adapters are separate. |
| Material dependency | Widgets use Material | No Material widgets. The `material_ui` `TimeOfDay` accessor is an opt-in import. |

What you give up:

- **Less code at the call site.** `ReactiveTextField(formControlName: 'email')`
  is shorter than a `TextControlBuilder` with a `builder`. That is the cost
  of building the widget yourself, and the reason the widget is never out of
  date.
- **`formControlName` lookup from context.** You pass controls explicitly.
  This is more verbose, but it is type-checked, and there is no
  `ReactiveForm` ancestor to set up.
- **Some ready-made widgets.** There is no equivalent of
  `ReactiveFormPopScope`, `ReactiveDatePicker` or `ReactiveFormArray`.
  Use `PopScope`, `showDatePicker` or a `ControlBuilder` on the array.

### Migrating

| reactive_forms | bind_forms |
| --- | --- |
| `ReactiveForm(formGroup: form, child: ...)` | Not needed |
| `ReactiveTextField<T>(formControlName: 'x', ...)` | `TextControlBuilder(control: form.formControl<T>('x'), builder: (context, field) => TextField(controller: field, focusNode: field.focusNode, ...))` |
| `ReactiveCheckbox`, `ReactiveSwitch`, `ReactiveSlider`, ... | `ValueControlBuilder` around the real widget |
| `ReactiveFormConsumer`, `ReactiveValueListenableBuilder` | `ControlBuilder`, or `ListenableBuilder` on `control.listenable` |
| `form.control('x') as FormControl<T>` | `form.formControl<T>('x')` |
| `control.valueChanges`, `statusChanged`, `focusChanges`, ... | The same, after importing `package:bind_forms_streams/bind_forms_streams.dart` |
| `ReactiveFormConfig` | `BindFormsConfig` |
| `control.focusController` | `control.focusControllers` (a control can have several) |

## Example

[`packages/bind_forms/example`](packages/bind_forms/example) is a catalog app.
It binds the widgets covered by reactive_forms_widgets (49 of its 52 widget
packages; the rest are empty or no longer compile) without wrappers. It also
has the same login form built with `Listenable`s and with signals, and a
sign-up form built with the builder helpers.

```sh
cd packages/bind_forms/example && flutter run
```

## Contributing

This is a pub workspace: `flutter pub get` at the root resolves every package. Run `dart test` (pure Dart packages) or `flutter test` in a package directory.

### CI and releases

- **Pull requests** (`.github/workflows/pr.yml`): formatting, `dart analyze --fatal-infos`, every package's tests, and a `pub publish --dry-run` per package.
- **Main** (`main.yml`): the same checks, a Linux release build of the example (which compiles every showcased plugin), and a release-status summary of what is ready to release.
- **Publish** (`publish.yml`): pushing a tag `<package>-v<version>` verifies and tests that package, publishes it to pub.dev, and only then creates the GitHub Release. If anything fails before pub.dev accepts the package, the workflow deletes the tag again, so a failed release leaves nothing behind.

#### Releasing

1. In a PR, bump `version` in the package's `pubspec.yaml` and add a `## <version>` entry to its `CHANGELOG.md`. Merge it.
2. Push the tag the main run's summary shows, e.g.:

   ```sh
   git tag bind_forms_core-v0.1.0 && git push origin bind_forms_core-v0.1.0
   ```

3. If the release fails, the tag is deleted: fix the problem and push the tag again. If only the GitHub Release step failed (the package did ship), re-run that job.

Release `bind_forms_core` before the packages that depend on it; Publish refuses a package whose workspace dependencies aren't on pub.dev yet, a version that is already published, and a version without a CHANGELOG entry. `python3 tool/release.py status` shows the summary locally.

#### One-time setup

1. Publish the first version of each package by hand (`dart pub publish` in its directory); pub.dev only enables automated publishing on an existing package.
2. On pub.dev, for each package: **Admin → Automated publishing → Enable publishing from GitHub Actions**, with repository `abdulhaq-e/bind_forms`, tag pattern `<package>-v{{version}}` (e.g. `bind_forms_core-v{{version}}`), and **Require GitHub Actions environment** set to `pub.dev`.
3. In the GitHub repository settings, create the `pub.dev` environment, ideally with yourself as a required reviewer so every publish waits for approval. Rejecting the approval counts as a failed release: the tag is deleted.
