# bind_forms_example

Every widget covered by
[reactive_forms_widgets](https://github.com/artflutter/reactive_forms_widgets),
bound to a `FormControl` directly: the real widget, its own parameters, and
a bind_forms adapter. No wrapper widgets, no re-declared constructors.

```sh
flutter run
```

| Section | What it shows |
| --- | --- |
| Login form | A complete form: validation, errors on blur, app-wide messages, submit. |
| Flutter widgets | 15 Material and Cupertino widgets (16 wrapper packages). |
| Third-party inputs | 31 widgets from 24 wrapper packages: text, pins, phone, tags, selection, toggles, ratings, colors, signatures. |
| Pickers | 8 pickers: files, images, assets, camera, contacts, months, languages. |
| Fluent UI / macOS UI | The 8 and 7 widgets covered by `reactive_fluent_ui` and `reactive_macos_ui`. |

Each demo card names the wrapper package it replaces, shows the control's
live value, and has a reset button that changes the control from code.

## How each kind of widget binds

- **`value` + `onChanged`** (checkboxes, switches, sliders, dropdowns,
  pickers): `FormControlValueNotifier`.
- **`TextEditingController`** (text fields, pins, autocomplete):
  `FormControlTextEditingController`.
- **Its own `TextEditingController` subclass** (`CodeField`,
  `LanguageToolTextField`): `FormControlTextBinding` around that controller.
- **Its own non-text controller** (`AdvancedSwitch`, `PhoneFormField`,
  `TextFieldTags`, `Signature`): two listeners, one per direction.

## Packages still on flutter/material

`flutter/material` is being replaced by `material_ui`, and the two have
different types. Eight showcased packages haven't migrated and fail with "No
Material widget found" under a `material_ui` app. Their cards are labelled,
and `lib/showcase/legacy_material.dart` (the only file importing
`flutter/material`) gives them the ancestors they look for.

## Not shown

`reactive_awesome_select` and `reactive_md_editable_textinput` wrap packages
that no longer compile on current Flutter, so their wrappers are broken
too. `reactive_getwidget` is empty.

`test/showcase_test.dart` pumps every demo on its own and resets it from
code, failing with the widget's name if anything throws.
