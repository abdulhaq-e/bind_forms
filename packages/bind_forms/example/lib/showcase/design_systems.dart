import 'package:bind_forms/bind_forms.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:material_ui/material_ui.dart';

import 'demo.dart';

const _sizes = ['Small', 'Medium', 'Large'];

/// Fluent UI (Windows) widgets, covered by the reactive_fluent_ui wrapper
/// package.
class FluentPage extends StatelessWidget {
  const FluentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return fluent.FluentTheme(
      data: fluent.FluentThemeData(),
      child: DemoPage(title: 'Fluent UI', children: fluentDemos()),
    );
  }
}

/// macOS widgets, covered by the reactive_macos_ui wrapper package.
class MacosPage extends StatelessWidget {
  const MacosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return macos.MacosTheme(
      data: macos.MacosThemeData.light(),
      child: DemoPage(title: 'macOS UI', children: macosDemos()),
    );
  }
}

/// The demos on [FluentPage], also pumped one by one by the smoke test.
List<Widget> fluentDemos() => [
  TextDemo<String>(
    title: 'TextFormBox',
    replaces: 'reactive_fluent_ui (ReactiveFluentTextFormBox)',
    control: () => FormControl(validators: [Validators.required]),
    builder: (context, field) => fluent.InfoLabel(
      label: 'Name',
      child: fluent.TextBox(
        controller: field,
        focusNode: field.focusNode,
        highlightColor: field.errorText(context) != null
            ? fluent.Colors.red
            : null,
      ),
    ),
  ),
  TextDemo<String>(
    title: 'AutoSuggestBox',
    replaces: 'reactive_fluent_ui (ReactiveFluentAutoSuggestBox)',
    control: () => FormControl(),
    builder: (context, field) => fluent.AutoSuggestBox<String>(
      controller: field,
      focusNode: field.focusNode,
      items: [
        for (final size in _sizes)
          fluent.AutoSuggestBoxItem(value: size, label: size),
      ],
    ),
  ),
  ValueDemo<bool>(
    title: 'Checkbox',
    replaces: 'reactive_fluent_ui (ReactiveFluentCheckBox)',
    control: () => FormControl(value: false),
    builder: (context, field) => fluent.Checkbox(
      checked: field.value,
      focusNode: field.focusNode,
      onChanged: field.enabled ? field.onChanged : null,
      content: const Text('Remember me'),
    ),
  ),
  ValueDemo<bool>(
    title: 'ToggleSwitch',
    replaces: 'reactive_fluent_ui (ReactiveFluentToggleSwitch)',
    control: () => FormControl(value: true),
    builder: (context, field) => fluent.ToggleSwitch(
      checked: field.value ?? false,
      focusNode: field.focusNode,
      onChanged: field.enabled ? field.onChanged : null,
      content: const Text('Notifications'),
    ),
  ),
  ValueDemo<double>(
    title: 'Slider',
    replaces: 'reactive_fluent_ui (ReactiveFluentSlider)',
    control: () => FormControl(value: 30),
    builder: (context, field) => fluent.Slider(
      value: field.value ?? 0,
      max: 100,
      focusNode: field.focusNode,
      onChanged: field.enabled ? field.onChanged : null,
    ),
  ),
  ValueDemo<String>(
    title: 'ComboBox',
    replaces: 'reactive_fluent_ui (ReactiveFluentComboBox)',
    control: () => FormControl(value: 'Medium'),
    builder: (context, field) => fluent.ComboBox<String>(
      value: field.value,
      focusNode: field.focusNode,
      items: [
        for (final size in _sizes)
          fluent.ComboBoxItem(value: size, child: Text(size)),
      ],
      onChanged: field.enabled ? field.onChanged : null,
    ),
  ),
  ValueDemo<DateTime>(
    title: 'DatePicker',
    replaces: 'reactive_fluent_ui (ReactiveFluentDatePicker)',
    control: () => FormControl(value: DateTime(2026, 10, 17)),
    builder: (context, field) => fluent.DatePicker(
      selected: field.value,
      focusNode: field.focusNode,
      onChanged: field.onChanged,
    ),
  ),
  ValueDemo<DateTime>(
    title: 'TimePicker',
    replaces: 'reactive_fluent_ui (ReactiveFluentTimePicker)',
    control: () => FormControl(value: DateTime(2026, 10, 17, 9, 30)),
    builder: (context, field) => fluent.TimePicker(
      selected: field.value,
      focusNode: field.focusNode,
      onChanged: field.onChanged,
    ),
  ),
];

/// The demos on [MacosPage], also pumped one by one by the smoke test.
List<Widget> macosDemos() => [
  TextDemo<String>(
    title: 'MacosTextField',
    replaces: 'reactive_macos_ui (ReactiveMacosTextField)',
    control: () => FormControl(),
    builder: (context, field) => macos.MacosTextField(
      controller: field,
      focusNode: field.focusNode,
      placeholder: 'Name',
    ),
  ),
  ValueDemo<bool>(
    title: 'MacosCheckbox',
    replaces: 'reactive_macos_ui (ReactiveMacosCheckbox)',
    control: () => FormControl(value: true),
    builder: (context, field) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: macos.MacosCheckbox(
        value: field.value,
        onChanged: field.enabled ? field.onChanged : null,
      ),
    ),
  ),
  ValueDemo<bool>(
    title: 'MacosSwitch',
    replaces: 'reactive_macos_ui (ReactiveMacosSwitch)',
    control: () => FormControl(value: false),
    builder: (context, field) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: macos.MacosSwitch(
        value: field.value ?? false,
        onChanged: field.enabled ? field.onChanged : null,
      ),
    ),
  ),
  ValueDemo<String>(
    title: 'MacosRadioButton',
    replaces: 'reactive_macos_ui (ReactiveMacosRadioButton)',
    control: () => FormControl(value: 'Small'),
    builder: (context, field) => Row(
      children: [
        for (final size in _sizes) ...[
          macos.MacosRadioButton<String>(
            value: size,
            groupValue: field.value,
            onChanged: field.enabled ? field.onChanged : null,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 16),
            child: Text(size),
          ),
        ],
      ],
    ),
  ),
  ValueDemo<String>(
    title: 'MacosPopupButton',
    replaces: 'reactive_macos_ui (ReactiveMacosPopupButton)',
    control: () => FormControl(value: 'Medium'),
    builder: (context, field) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: macos.MacosPopupButton<String>(
        value: field.value,
        items: [
          for (final size in _sizes)
            macos.MacosPopupMenuItem(value: size, child: Text(size)),
        ],
        onChanged: field.enabled ? field.onChanged : null,
      ),
    ),
  ),
  ValueDemo<double>(
    title: 'CapacityIndicator',
    replaces: 'reactive_macos_ui (ReactiveCapacityIndicator)',
    control: () => FormControl(value: 40),
    builder: (context, field) => macos.CapacityIndicator(
      value: field.value ?? 0,
      onChanged: field.enabled ? field.onChanged : null,
    ),
  ),
  ValueDemo<double>(
    title: 'RatingIndicator',
    replaces: 'reactive_macos_ui (ReactiveRatingIndicator)',
    control: () => FormControl(value: 3),
    builder: (context, field) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: macos.RatingIndicator(
        value: field.value ?? 0,
        onChanged: field.enabled ? field.onChanged : null,
      ),
    ),
  ),
];
