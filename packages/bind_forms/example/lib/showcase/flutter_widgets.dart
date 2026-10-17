import 'package:bind_forms/bind_forms.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'demo.dart';

const _fruits = ['Apple', 'Banana', 'Cherry', 'Mango'];

/// Flutter's own Material and Cupertino widgets, each of which has a
/// reactive_forms_widgets wrapper package.
class FlutterWidgetsPage extends StatelessWidget {
  const FlutterWidgetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(title: 'Flutter widgets', children: flutterWidgetDemos());
  }
}

String _date(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// The demos on [FlutterWidgetsPage], also pumped one by one by the smoke test.
List<Widget> flutterWidgetDemos() => [
  TextDemo<String>(
    title: 'TextField',
    replaces: 'reactive_text_field',
    control: () => FormControl(validators: [Validators.required]),
    builder: (context, field) => TextField(
      controller: field,
      focusNode: field.focusNode,
      decoration: InputDecoration(
        labelText: 'Name',
        border: const OutlineInputBorder(),
        errorText: field.errorText(context),
      ),
    ),
  ),
  ValueDemo<bool>(
    title: 'Checkbox',
    replaces: 'reactive_checkbox',
    control: () => FormControl(value: false),
    builder: (context, field) => Checkbox(
      value: field.value ?? false,
      focusNode: field.focusNode,
      onChanged: field.enabled ? field.onChanged : null,
    ),
  ),
  ValueDemo<bool>(
    title: 'CheckboxListTile',
    replaces: 'reactive_checkbox_list_tile',
    control: () =>
        FormControl(value: false, validators: [Validators.requiredTrue]),
    builder: (context, field) => CheckboxListTile(
      value: field.value ?? false,
      focusNode: field.focusNode,
      onChanged: field.enabled ? field.onChanged : null,
      isError: field.errorText(context) != null,
      title: const Text('Subscribe to the newsletter'),
    ),
  ),
  ValueDemo<String>(
    title: 'DropdownButtonFormField',
    replaces: 'reactive_dropdown_field',
    control: () => FormControl(validators: [Validators.required]),
    builder: (context, field) => DropdownButtonFormField<String>(
      // A FormField keeps its own state after the first build, so key
      // it on the value for changes from code (like reset) to show.
      key: ValueKey(field.value),
      initialValue: field.value,
      focusNode: field.focusNode,
      items: [
        for (final fruit in _fruits)
          DropdownMenuItem(value: fruit, child: Text(fruit)),
      ],
      onChanged: field.enabled ? field.onChanged : null,
      decoration: InputDecoration(
        labelText: 'Fruit',
        border: const OutlineInputBorder(),
        errorText: field.errorText(context),
      ),
    ),
  ),
  TextDemo<String>(
    title: 'DropdownMenu',
    replaces: 'reactive_dropdown_menu',
    note:
        'DropdownMenu writes the selected label into its text '
        'controller, so a text controller is the whole binding.',
    control: () => FormControl(),
    builder: (context, field) => DropdownMenu<String>(
      controller: field,
      focusNode: field.focusNode,
      label: const Text('Fruit'),
      errorText: field.errorText(context),
      dropdownMenuEntries: [
        for (final fruit in _fruits)
          DropdownMenuEntry(value: fruit, label: fruit),
      ],
    ),
  ),
  ValueDemo<RangeValues>(
    title: 'RangeSlider',
    replaces: 'reactive_range_slider',
    control: () => FormControl(value: const RangeValues(20, 80)),
    builder: (context, field) => RangeSlider(
      values: field.value ?? const RangeValues(0, 100),
      max: 100,
      divisions: 20,
      labels: RangeLabels(
        '${field.value?.start.round()}',
        '${field.value?.end.round()}',
      ),
      onChanged: field.enabled ? field.onChanged : null,
    ),
  ),
  TextDemo<String>(
    title: 'RawAutocomplete',
    replaces: 'reactive_raw_autocomplete',
    note:
        'RawAutocomplete takes a controller and a focus node together, '
        'which the text controller provides.',
    control: () => FormControl(),
    builder: (context, field) => RawAutocomplete<String>(
      textEditingController: field,
      focusNode: field.focusNode,
      optionsBuilder: (value) => _fruits.where(
        (fruit) => fruit.toLowerCase().contains(value.text.toLowerCase()),
      ),
      fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
          TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Fruit',
              border: OutlineInputBorder(),
            ),
          ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: AlignmentDirectional.topStart,
        child: Material(
          elevation: 4,
          child: SizedBox(
            width: 240,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final option in options)
                  ListTile(
                    title: Text(option),
                    onTap: () => onSelected(option),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
  ValueDemo<double>(
    title: 'InputDecorator',
    replaces: 'reactive_input_decorator',
    note:
        'InputDecorator gives any widget a label and error text; here '
        'it decorates a Slider.',
    control: () => FormControl(value: 2, validators: [Validators.min(3)]),
    builder: (context, field) => InputDecorator(
      decoration: InputDecoration(
        labelText: 'Rooms (at least 3)',
        border: const OutlineInputBorder(),
        errorText: field.errorText(context),
      ),
      child: Slider(
        value: field.value ?? 0,
        max: 10,
        divisions: 10,
        label: '${field.value?.round()}',
        onChanged: field.enabled ? field.onChanged : null,
      ),
    ),
  ),
  ValueDemo<DateTimeRange>(
    title: 'showDateRangePicker',
    replaces: 'reactive_date_range_picker',
    control: () => FormControl(),
    builder: (context, field) => PickerButton<DateTimeRange>(
      field: field,
      icon: Icons.date_range,
      label: field.value == null
          ? 'Pick a date range'
          : '${_date(field.value!.start)} – ${_date(field.value!.end)}',
      pick: () => showDateRangePicker(
        context: context,
        initialDateRange: field.value,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      ),
    ),
  ),
  ValueDemo<DateTime>(
    title: 'showDatePicker + showTimePicker',
    replaces: 'reactive_date_time_picker',
    control: () => FormControl(),
    builder: (context, field) => PickerButton<DateTime>(
      field: field,
      icon: Icons.event,
      label: field.value == null
          ? 'Pick a date and time'
          : '${_date(field.value!)} '
                '${TimeOfDay.fromDateTime(field.value!).format(context)}',
      pick: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: field.value,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (date == null || !context.mounted) return null;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(field.value ?? date),
        );
        if (time == null) return null;
        return date.copyWith(hour: time.hour, minute: time.minute);
      },
    ),
  ),
  ValueDemo<double>(
    title: 'CupertinoSlider',
    replaces: 'reactive_cupertino_slider',
    control: () => FormControl(value: 30),
    builder: (context, field) => CupertinoSlider(
      value: field.value ?? 0,
      max: 100,
      onChanged: field.enabled ? field.onChanged : null,
    ),
  ),
  ValueDemo<bool>(
    title: 'CupertinoSwitch',
    replaces: 'reactive_cupertino_switch',
    control: () => FormControl(value: true),
    builder: (context, field) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: CupertinoSwitch(
        value: field.value ?? false,
        focusNode: field.focusNode,
        onChanged: field.enabled ? field.onChanged : null,
      ),
    ),
  ),
  TextDemo<String>(
    title: 'CupertinoTextField',
    replaces: 'reactive_cupertino_text_field',
    control: () => FormControl(),
    builder: (context, field) => CupertinoTextField(
      controller: field,
      focusNode: field.focusNode,
      placeholder: 'Name',
    ),
  ),
  ValueDemo<String>(
    title: 'CupertinoSlidingSegmentedControl',
    replaces: 'reactive_sliding_segmented, reactive_cup_slide_segmented',
    note:
        'Two wrapper packages exist for this same widget; neither is '
        'needed.',
    control: () => FormControl(value: 'day'),
    builder: (context, field) => CupertinoSlidingSegmentedControl<String>(
      groupValue: field.value,
      children: const {
        'day': Text('Day'),
        'week': Text('Week'),
        'month': Text('Month'),
      },
      onValueChanged: field.onChanged,
    ),
  ),
  ValueDemo<String>(
    title: 'CupertinoSegmentedControl',
    replaces: 'reactive_segmented_control',
    control: () => FormControl(value: 'list'),
    builder: (context, field) => CupertinoSegmentedControl<String>(
      groupValue: field.value,
      children: const {
        'list': Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('List'),
        ),
        'grid': Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Grid'),
        ),
      },
      onValueChanged: field.onChanged,
    ),
  ),
];
