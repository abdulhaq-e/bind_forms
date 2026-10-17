import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:bind_forms/bind_forms.dart';
import 'package:cart_stepper/cart_stepper.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:direct_select/direct_select.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:fancy_password_field/fancy_password_field.dart';
// extended_text_field still takes flutter/material's InputDecoration.
import 'package:flutter/material.dart'
    as legacy
    show InputDecoration, OutlineInputBorder;
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_native_text_input/flutter_native_text_input.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:language_picker/language_picker.dart';
import 'package:language_picker/languages.dart';
import 'package:languagetool_textfield/languagetool_textfield.dart';
import 'package:material_ui/material_ui.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:pinput/pinput.dart';
import 'package:signature/signature.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'demo.dart';

const _cities = ['Amsterdam', 'Berlin', 'Cairo', 'Lisbon', 'Tripoli'];

/// Third-party widgets, each of which has a reactive_forms_widgets wrapper
/// package that re-declares its constructor.
class ThirdPartyInputsPage extends StatelessWidget {
  const ThirdPartyInputsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoPage(
      title: 'Third-party inputs',
      children: thirdPartyInputDemos(),
    );
  }
}

/// MaterialPinField takes a PinInputController, which can wrap the text
/// controller and focus node the bind_forms controller already provides.
class _PinCodeDemo extends StatefulWidget {
  @override
  State<_PinCodeDemo> createState() => _PinCodeDemoState();
}

class _PinCodeDemoState extends State<_PinCodeDemo> {
  final _control = FormControl<String>(validators: [Validators.minLength(4)]);
  late final _field = FormControlTextEditingController(_control);
  late final _pin = PinInputController(
    textController: _field,
    focusNode: _field.focusNode,
  );

  @override
  void dispose() {
    _pin.dispose();
    _field.dispose();
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: 'MaterialPinField',
      replaces: 'reactive_pin_code_fields',
      control: _control,
      child: ListenableBuilder(
        listenable: _field,
        builder: (context, _) => MaterialPinField(
          length: 4,
          pinController: _pin,
          errorText: _field.errorText(context),
        ),
      ),
    );
  }
}

/// AdvancedSwitch reads its state from a `ValueNotifier<bool>`, so the
/// binding is two listeners: control -> notifier and notifier -> control.
class _AdvancedSwitchDemo extends StatefulWidget {
  @override
  State<_AdvancedSwitchDemo> createState() => _AdvancedSwitchDemoState();
}

class _AdvancedSwitchDemoState extends State<_AdvancedSwitchDemo> {
  final _control = FormControl<bool>(value: true);
  late final _switch = ValueNotifier<bool>(_control.value ?? false);

  @override
  void initState() {
    super.initState();
    _control.addListener((_) => _switch.value = _control.value ?? false);
    _switch.addListener(() => _control.value = _switch.value);
  }

  @override
  void dispose() {
    _switch.dispose();
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: 'AdvancedSwitch',
      replaces: 'reactive_advanced_switch',
      note: 'Controlled by a ValueNotifier<bool>, synced with two listeners.',
      control: _control,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: AdvancedSwitch(controller: _switch),
      ),
    );
  }
}

/// TextFieldTags keeps tags in its own controller, so tag changes are
/// written to the control by hand.
class _TagsDemo extends StatefulWidget {
  @override
  State<_TagsDemo> createState() => _TagsDemoState();
}

class _TagsDemoState extends State<_TagsDemo> {
  final _control = FormControl<List<String>>(value: const ['flutter']);
  final _tags = StringTagController();

  @override
  void initState() {
    super.initState();
    _tags.addListener(() {
      final tags = _tags.getTags ?? const [];
      if (!_sameTags(tags, _control.value)) _control.value = List.of(tags);
    });
    _control.addListener((changes) {
      final tags = _control.value ?? const [];
      if (changes.value && !_sameTags(tags, _tags.getTags)) {
        _tags.clearTags();
        tags.forEach(_tags.addTag);
      }
    });
  }

  static bool _sameTags(List<String> a, List<String>? b) =>
      b != null && a.length == b.length && a.every(b.contains);

  @override
  void dispose() {
    _tags.dispose();
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: 'TextFieldTags',
      replaces: 'reactive_textfield_tags',
      note: 'Type a word and press space or enter to add a tag.',
      control: _control,
      child: TextFieldTags<String>(
        textfieldTagsController: _tags,
        initialTags: _control.value,
        textSeparators: const [' ', ','],
        inputFieldBuilder: (context, values) => TextField(
          controller: values.textEditingController,
          focusNode: values.focusNode,
          onChanged: values.onTagChanged,
          onSubmitted: values.onTagSubmitted,
          decoration: InputDecoration(
            labelText: 'Tags',
            border: const OutlineInputBorder(),
            prefixIcon: values.tags.isEmpty
                ? null
                : Padding(
                    padding: const EdgeInsets.all(8),
                    child: Wrap(
                      spacing: 4,
                      children: [
                        for (final tag in values.tags)
                          InputChip(
                            label: Text(tag),
                            onDeleted: () => values.onTagRemoved(tag),
                          ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// PhoneFormField uses its own PhoneController (a ChangeNotifier), synced
/// with the control by two listeners.
class _PhoneDemo extends StatefulWidget {
  @override
  State<_PhoneDemo> createState() => _PhoneDemoState();
}

class _PhoneDemoState extends State<_PhoneDemo> {
  final _control = FormControl<PhoneNumber>(
    value: const PhoneNumber(isoCode: IsoCode.LY, nsn: '912345678'),
  );
  late final _phone = PhoneController(initialValue: _control.value!);

  @override
  void initState() {
    super.initState();
    _phone.addListener(() {
      if (_phone.value != _control.value) _control.value = _phone.value;
    });
    _control.addListener((_) {
      final value = _control.value;
      if (value != null && value != _phone.value) _phone.value = value;
    });
  }

  @override
  void dispose() {
    _phone.dispose();
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: 'PhoneFormField',
      replaces: 'reactive_phone_form_field',
      control: _control,
      child: PhoneFormField(
        controller: _phone,
        decoration: const InputDecoration(
          labelText: 'Phone',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

/// The control holds PNG bytes; the canvas can export strokes to PNG but
/// can't load them back, so this binding (like the wrapper's) only goes
/// from the canvas to the control.
class _SignatureDemo extends StatefulWidget {
  @override
  State<_SignatureDemo> createState() => _SignatureDemoState();
}

class _SignatureDemoState extends State<_SignatureDemo> {
  final _control = FormControl<Uint8List>();
  late final SignatureController _signature = SignatureController(
    penStrokeWidth: 2,
    onDrawEnd: () async => _control.value = await _signature.toPngBytes(),
  );

  @override
  void initState() {
    super.initState();
    _control.addListener((changes) {
      if (changes.value && _control.value == null) _signature.clear();
    });
  }

  @override
  void dispose() {
    _signature.dispose();
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: 'Signature',
      replaces: 'reactive_signature',
      note: 'Draw below. Reset clears the canvas.',
      control: _control,
      child: Signature(
        controller: _signature,
        height: 160,
        backgroundColor: Colors.grey.shade200,
      ),
    );
  }
}

/// SfSignaturePad has no controller: its state is reached through a
/// GlobalKey, the same way the wrapper does it.
class _SfSignaturePadDemo extends StatefulWidget {
  @override
  State<_SfSignaturePadDemo> createState() => _SfSignaturePadDemoState();
}

class _SfSignaturePadDemoState extends State<_SfSignaturePadDemo> {
  final _control = FormControl<Uint8List>();
  final _pad = GlobalKey<SfSignaturePadState>();

  @override
  void initState() {
    super.initState();
    _control.addListener((changes) {
      if (changes.value && _control.value == null) _pad.currentState?.clear();
    });
  }

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    final image = await _pad.currentState!.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    _control.value = bytes?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: 'SfSignaturePad',
      replaces: 'reactive_sf_signaturepad',
      note: 'Draw below. Reset clears the pad.',
      control: _control,
      child: SizedBox(
        height: 160,
        child: SfSignaturePad(
          key: _pad,
          backgroundColor: Colors.grey.shade200,
          onDrawEnd: _export,
        ),
      ),
    );
  }
}

/// The demos on [ThirdPartyInputsPage], also pumped one by one by the smoke test.
List<Widget> thirdPartyInputDemos() => [
  // --- Text input ----------------------------------------------------
  TextDemo<String>(
    title: 'ExtendedTextField',
    legacyMaterial: true,
    replaces: 'reactive_extended_text_field',
    control: () => FormControl(),
    note: "Its decoration is flutter/material's InputDecoration.",
    builder: (context, field) => ExtendedTextField(
      controller: field,
      focusNode: field.focusNode,
      decoration: const legacy.InputDecoration(
        labelText: 'Extended text',
        border: legacy.OutlineInputBorder(),
      ),
    ),
  ),
  TextDemo<String>(
    title: 'FancyPasswordField',
    replaces: 'reactive_fancy_password_field',
    control: () => FormControl(validators: [Validators.minLength(8)]),
    builder: (context, field) => FancyPasswordField(
      controller: field,
      focusNode: field.focusNode,
      decoration: InputDecoration(
        labelText: 'Password',
        errorText: field.errorText(context),
      ),
      validationRules: {
        DigitValidationRule(),
        UppercaseValidationRule(),
        MinCharactersValidationRule(8),
      },
    ),
  ),
  TextDemo<String>(
    title: 'NativeTextInput',
    replaces: 'reactive_flutter_native_text_input',
    note: 'A native iOS text view; other platforms fall back to a Text.',
    control: () => FormControl(),
    builder: (context, field) => SizedBox(
      height: 48,
      child: NativeTextInput(
        controller: field,
        focusNode: field.focusNode,
        placeholder: 'Native text',
      ),
    ),
  ),
  TextDemo<String>(
    title: 'TypeAheadField',
    replaces: 'reactive_flutter_typeahead',
    control: () => FormControl(),
    builder: (context, field) => TypeAheadField<String>(
      controller: field,
      focusNode: field.focusNode,
      suggestionsCallback: (search) => _cities
          .where((c) => c.toLowerCase().contains(search.toLowerCase()))
          .toList(),
      itemBuilder: (context, city) => ListTile(title: Text(city)),
      onSelected: (city) => field.text = city,
      builder: (context, controller, focusNode) => TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: const InputDecoration(
          labelText: 'City',
          border: OutlineInputBorder(),
        ),
      ),
    ),
  ),
  BindingDemo<String, CodeController>(
    title: 'CodeField',
    legacyMaterial: true,
    replaces: 'reactive_code_text_field',
    note:
        'CodeField needs its own CodeController, a TextEditingController '
        'subclass, so the control is bound to it with '
        'FormControlTextBinding.',
    control: () => FormControl(value: 'void main() => print("hi");'),
    textController: CodeController.new,
    builder: (context, code, field) =>
        CodeField(controller: code, focusNode: field.focusNode, minLines: 3),
  ),
  BindingDemo<String, LanguageToolController>(
    title: 'LanguageToolTextField',
    legacyMaterial: true,
    replaces: 'reactive_languagetool_textfield',
    note:
        'Same as CodeField: its LanguageToolController is bound, not '
        'replaced. Spell checking calls the LanguageTool API.',
    control: () => FormControl(value: 'This is a exampel.'),
    textController: LanguageToolController.new,
    builder: (context, text, field) => LanguageToolTextField(
      controller: text,
      focusNode: field.focusNode,
      language: 'en-US',
    ),
  ),
  _PinCodeDemo(),
  TextDemo<String>(
    title: 'PinInputTextField',
    legacyMaterial: true,
    replaces: 'reactive_pin_input_text_field',
    control: () => FormControl(),
    builder: (context, field) => PinInputTextField(
      controller: field,
      focusNode: field.focusNode,
      decoration: BoxLooseDecoration(
        strokeColorBuilder: FixedColorBuilder(Colors.blueGrey),
      ),
    ),
  ),
  TextDemo<String>(
    title: 'Pinput',
    replaces: 'reactive_pinput',
    control: () => FormControl(),
    builder: (context, field) =>
        Pinput(controller: field, focusNode: field.focusNode),
  ),
  _TagsDemo(),
  _PhoneDemo(),

  // --- Selection -----------------------------------------------------
  ValueDemo<String>(
    title: 'DropdownSearch',
    replaces: 'reactive_dropdown_search',
    control: () => FormControl(validators: [Validators.required]),
    builder: (context, field) => DropdownSearch<String>(
      items: (filter, _) => _cities,
      selectedItem: field.value,
      onSelected: field.enabled ? field.onChanged : null,
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: 'City',
          border: const OutlineInputBorder(),
          errorText: field.errorText(context),
        ),
      ),
      popupProps: const PopupProps.menu(showSearchBox: true),
    ),
  ),
  ValueDemo<String>(
    title: 'DirectSelect',
    replaces: 'reactive_direct_select',
    note: 'Press and hold, then drag to choose.',
    control: () => FormControl(value: _cities.first),
    builder: (context, field) => DirectSelect(
      itemExtent: 48,
      selectedIndex: _cities.indexOf(field.value ?? _cities.first),
      items: [for (final city in _cities) Text(city)],
      onSelectedItemChanged: (index) => field.onChanged(_cities[index ?? 0]),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'City',
          border: OutlineInputBorder(),
        ),
        child: Text(field.value ?? ''),
      ),
    ),
  ),
  ValueDemo<List<String>>(
    title: 'MultiSelectChipField',
    legacyMaterial: true,
    replaces: 'reactive_multi_select_flutter',
    control: () => FormControl(value: const ['Berlin']),
    // Keeps its own selection state; keyed so changes from code show.
    builder: (context, field) => KeyedSubtree(
      key: ValueKey(field.value),
      child: MultiSelectChipField<String>(
        items: [for (final city in _cities) MultiSelectItem(city, city)],
        initialValue: field.value ?? const [],
        // Declared as taking List<V> but called with a List<V?>, so accept
        // the wider type.
        onTap: (List<String?> selected) =>
            field.onChanged(selected.nonNulls.toList()),
      ),
    ),
  ),
  ValueDemo<List<String>>(
    title: 'MultiSelectDialogField',
    legacyMaterial: true,
    replaces: 'reactive_multi_select_flutter',
    control: () => FormControl(value: const []),
    builder: (context, field) => KeyedSubtree(
      key: ValueKey(field.value),
      child: MultiSelectDialogField<String>(
        items: [for (final city in _cities) MultiSelectItem(city, city)],
        initialValue: field.value ?? const [],
        onConfirm: (selected) => field.onChanged(List.of(selected)),
      ),
    ),
  ),
  ValueDemo<Language>(
    title: 'LanguagePickerDropdown',
    legacyMaterial: true,
    replaces: 'reactive_language_picker',
    control: () => FormControl(value: Languages.english),
    builder: (context, field) => KeyedSubtree(
      key: ValueKey(field.value),
      child: LanguagePickerDropdown(
        initialValue: field.value,
        onValuePicked: field.onChanged,
      ),
    ),
  ),

  // --- Toggles and steppers ------------------------------------------
  _AdvancedSwitchDemo(),
  ValueDemo<bool>(
    title: 'AnimatedToggleSwitch.dual',
    replaces: 'reactive_animated_toggle_switch',
    control: () => FormControl(value: false),
    builder: (context, field) => AnimatedToggleSwitch<bool>.dual(
      current: field.value ?? false,
      first: false,
      second: true,
      onChanged: field.onChanged,
      iconBuilder: (on) => Icon(on ? Icons.light_mode : Icons.dark_mode),
    ),
  ),
  ValueDemo<int>(
    title: 'AnimatedToggleSwitch.size',
    replaces: 'reactive_animated_toggle_switch',
    control: () => FormControl(value: 1),
    builder: (context, field) => AnimatedToggleSwitch<int>.size(
      current: field.value ?? 0,
      values: const [0, 1, 2],
      onChanged: field.onChanged,
      iconBuilder: (value) => Text('${value + 1}'),
    ),
  ),
  ValueDemo<int>(
    title: 'ToggleSwitch',
    replaces: 'reactive_toggle_switch',
    control: () => FormControl(value: 0),
    builder: (context, field) => ToggleSwitch(
      initialLabelIndex: field.value,
      totalSwitches: 3,
      labels: const ['Small', 'Medium', 'Large'],
      onToggle: field.onChanged,
    ),
  ),
  ValueDemo<int>(
    title: 'CartStepper',
    legacyMaterial: true,
    replaces: 'reactive_cart_stepper',
    control: () => FormControl(value: 1),
    builder: (context, field) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: CartStepperInt(
        value: field.value ?? 0,
        didChangeCount: field.onChanged,
      ),
    ),
  ),

  // --- Sliders and ratings -------------------------------------------
  ValueDemo<double>(
    title: 'RatingBar',
    replaces: 'reactive_flutter_rating_bar',
    control: () => FormControl(value: 3),
    builder: (context, field) => RatingBar(
      initialRating: field.value ?? 0,
      allowHalfRating: true,
      ratingWidget: RatingWidget(
        full: const Icon(Icons.star, color: Colors.amber),
        half: const Icon(Icons.star_half, color: Colors.amber),
        empty: const Icon(Icons.star_border, color: Colors.amber),
      ),
      onRatingUpdate: field.onChanged,
    ),
  ),
  ValueDemo<double>(
    title: 'RatingBar.builder',
    replaces: 'reactive_flutter_rating_bar',
    control: () => FormControl(value: 2),
    builder: (context, field) => RatingBar.builder(
      initialRating: field.value ?? 0,
      itemBuilder: (context, _) =>
          const Icon(Icons.favorite, color: Colors.red),
      onRatingUpdate: field.onChanged,
    ),
  ),
  ValueDemo<double>(
    title: 'SleekCircularSlider',
    replaces: 'reactive_sleek_circular_slider',
    control: () => FormControl(value: 40),
    builder: (context, field) => SleekCircularSlider(
      initialValue: field.value ?? 0,
      onChangeEnd: field.onChanged,
    ),
  ),

  // --- Colors --------------------------------------------------------
  ValueDemo<Color>(
    title: 'ColorPicker',
    legacyMaterial: true,
    replaces: 'reactive_color_picker',
    control: () => FormControl(value: Colors.teal),
    builder: (context, field) => ColorPicker(
      pickerColor: field.value ?? Colors.white,
      onColorChanged: field.onChanged,
      pickerAreaHeightPercent: 0.5,
    ),
  ),
  ValueDemo<Color>(
    title: 'SlidePicker',
    replaces: 'reactive_color_picker',
    control: () => FormControl(value: Colors.orange),
    builder: (context, field) => SlidePicker(
      pickerColor: field.value ?? Colors.white,
      onColorChanged: field.onChanged,
    ),
  ),
  ValueDemo<Color>(
    title: 'MaterialPicker',
    replaces: 'reactive_color_picker',
    control: () => FormControl(value: Colors.blue),
    builder: (context, field) => SizedBox(
      height: 360,
      child: MaterialPicker(
        pickerColor: field.value ?? Colors.white,
        onColorChanged: field.onChanged,
      ),
    ),
  ),
  ValueDemo<Color>(
    title: 'BlockPicker',
    replaces: 'reactive_color_picker',
    control: () => FormControl(value: Colors.red),
    builder: (context, field) => BlockPicker(
      pickerColor: field.value ?? Colors.white,
      onColorChanged: field.onChanged,
    ),
  ),

  // --- Signatures ----------------------------------------------------
  _SignatureDemo(),
  _SfSignaturePadDemo(),
];
