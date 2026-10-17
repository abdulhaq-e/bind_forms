# bind_forms

Model-driven forms for Flutter that bind to real widgets instead of wrapping them.

| Package | Description |
| --- | --- |
| [`bind_forms_core`](packages/bind_forms_core) | Pure Dart form model: controls, groups, arrays, validators. |
| [`bind_forms`](packages/bind_forms) | Flutter adapters over the core: text controllers, value notifiers, focus, `control.listenable`. |
| [`bind_forms_signals`](packages/bind_forms_signals) | Any control's state as signals (`control.signals`). Pure Dart. |

[`packages/bind_forms/example`](packages/bind_forms/example) showcases the widgets covered by reactive_forms_widgets (49 of its 52 widget packages; the rest are empty or no longer compile), bound without wrappers, plus the same login form with `Listenable`s and with signals.
