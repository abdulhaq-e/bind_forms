// Copyright 2020 Joan Pablo Jimenez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:bind_forms/bind_forms.dart';
import 'package:flutter/widgets.dart';
import 'package:material_ui/material_ui.dart' show TimeOfDay;

/// Called after [control] changes. [textNotified] is true when the
/// [TextEditingController] already notified its listeners for this change:
/// either the edit that caused it, or the text update that followed it.
typedef TextControlChanged = void Function(
  ControlChanges changes, {
  required bool textNotified,
});

/// Keeps a [TextEditingController]'s text and a [FormControl]'s value in
/// sync, in both directions. Shared by [FormControlTextEditingController]
/// (which syncs itself) and [FormControlTextBinding] (which syncs a
/// controller it doesn't own).
class TextControlSync<T> {
  /// Starts syncing. The control's value wins: [textController]'s text is
  /// replaced with it.
  TextControlSync({
    required this.control,
    required this.textController,
    required this.onControlChanged,
    ControlValueAccessor<T, String>? valueAccessor,
  }) : _valueAccessor = valueAccessor ?? defaultValueAccessorFor<T>(control) {
    textController.text = _syncedText =
        _valueAccessor.modelToViewValue(control.value) ?? '';
    // Registered before [_onControlChanged], so that on a value change from
    // the control the text is already updated when [_onControlChanged] runs.
    _valueAccessor.registerControl(control, onChange: _onControlValueChanged);
    control.addListener(_onControlChanged);
    textController.addListener(_onTextChanged);
  }

  final FormControl<T> control;
  final TextEditingController textController;
  final TextControlChanged onControlChanged;

  final ControlValueAccessor<T, String> _valueAccessor;
  bool _updatingFromControl = false;
  bool _updatingFromView = false;
  bool _textSetFromControl = false;

  /// The text last synced with the control, in either direction. Listeners
  /// also fire for selection changes and for [ChangeNotifier.notifyListeners]
  /// calls made for status changes, so only a different text is a user edit.
  late String _syncedText;

  void _onTextChanged() {
    final text = textController.text;
    if (_updatingFromControl || text == _syncedText) return;
    _syncedText = text;
    _updatingFromView = true;
    try {
      _valueAccessor.updateModel(text);
    } finally {
      _updatingFromView = false;
    }
  }

  void _onControlValueChanged(String? viewValue) {
    final effectiveValue = viewValue ?? '';
    final value = textController.value;
    final newValue = value.copyWith(
      text: effectiveValue,
      selection: TextSelection.collapsed(offset: effectiveValue.length),
      composing: TextRange.empty,
    );
    if (newValue == value) return;

    _updatingFromControl = true;
    _textSetFromControl = true;
    _syncedText = effectiveValue;
    textController.value = newValue;
    _updatingFromControl = false;
  }

  void _onControlChanged(ControlChanges changes) {
    final textNotified = _updatingFromView || _textSetFromControl;
    _textSetFromControl = false;
    onControlChanged(changes, textNotified: textNotified);
  }

  /// Stops syncing. Doesn't dispose [textController].
  void dispose() {
    textController.removeListener(_onTextChanged);
    control.removeListener(_onControlChanged);
    _valueAccessor.dispose();
  }

  /// The value accessor used when none is given, picked from the control's
  /// type.
  static ControlValueAccessor<K, String> defaultValueAccessorFor<K>(
    FormControl<K> control,
  ) {
    if (control is FormControl<int>) {
      return IntValueAccessor() as ControlValueAccessor<K, String>;
    } else if (control is FormControl<double>) {
      return DoubleValueAccessor() as ControlValueAccessor<K, String>;
    } else if (control is FormControl<DateTime>) {
      return DateTimeValueAccessor() as ControlValueAccessor<K, String>;
    } else if (control is FormControl<TimeOfDay>) {
      return TimeOfDayValueAccessor() as ControlValueAccessor<K, String>;
    }

    return DefaultValueAccessor<K, String>();
  }
}
