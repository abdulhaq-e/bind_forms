// Copyright 2020 Joan Pablo Jimenez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:bind_forms/bind_forms.dart';
import 'package:flutter/widgets.dart';

/// A [TextEditingController] that stays in sync with a [FormControl].
///
/// It doesn't wrap `TextField` or any other text-editing widget. It only
/// owns the value binding, so it can be handed straight to a real
/// `TextField`, `TextFormField`, `CupertinoTextField`, or any third-party
/// widget that accepts a [TextEditingController]. None of that widget's own
/// parameters need to be known here, so this controller never goes stale
/// when the widget's API changes.
///
/// Listeners are notified once per change: when the text changes (from
/// typing or from the control), and when the control's status or touched
/// state changes (so [errorText] stays current).
///
/// "Touched" is driven by focus, not typing, so register a
/// [FocusNodeController] with the same [control] if you want errors to
/// appear on blur:
///
/// ```dart
/// final controller = FormControlTextEditingController<String>(
///   form.control('email') as FormControl<String>,
/// );
/// final focusController = FocusNodeController();
/// controller.control.registerFocusController(focusController);
///
/// // ... in build():
/// ListenableBuilder(
///   listenable: controller,
///   builder: (context, _) => TextField(
///     controller: controller,
///     focusNode: focusController.focusNode,
///     decoration: InputDecoration(errorText: controller.errorText(context)),
///   ),
/// );
///
/// // ... in dispose():
/// controller.control.unregisterFocusController(focusController);
/// focusController.dispose();
/// controller.dispose();
/// ```
class FormControlTextEditingController<T> extends TextEditingController
    with FormControlErrorTextMixin<T> {
  /// The control this controller is bound to.
  @override
  final FormControl<T> control;

  @override
  final Map<String, ValidationMessageFunction>? validationMessages;

  @override
  final ShowErrorsFunction<T>? showErrors;

  final ControlValueAccessor<T, String> _valueAccessor;
  bool _updatingFromControl = false;
  bool _updatingFromView = false;
  bool _textSetFromControl = false;

  /// The text last synced with the control, in either direction. Listeners
  /// also fire for selection changes and for [notifyListeners] calls made
  /// for status changes, so only a different text is a user edit.
  late String _syncedText;

  /// Creates a controller bound to [control].
  ///
  /// [valueAccessor] converts between the control's value and the text. If
  /// omitted, one is picked from the control's type: [IntValueAccessor],
  /// [DoubleValueAccessor], [DateTimeValueAccessor], or
  /// [DefaultValueAccessor] for anything else.
  FormControlTextEditingController(
    this.control, {
    ControlValueAccessor<T, String>? valueAccessor,
    this.validationMessages,
    this.showErrors,
  }) : _valueAccessor = valueAccessor ?? _defaultValueAccessorFor<T>(control) {
    text = _syncedText = _valueAccessor.modelToViewValue(control.value) ?? '';
    // Registered before [_onControlChanged], so that on a value change from
    // the control the text is already updated when [_onControlChanged] runs.
    _valueAccessor.registerControl(control, onChange: _onControlValueChanged);
    control.addListener(_onControlChanged);
    addListener(_onTextChanged);
  }

  void _onTextChanged() {
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
    final newValue = value.copyWith(
      text: effectiveValue,
      selection: TextSelection.collapsed(offset: effectiveValue.length),
      composing: TextRange.empty,
    );
    if (newValue == value) return;

    _updatingFromControl = true;
    _textSetFromControl = true;
    _syncedText = effectiveValue;
    value = newValue;
    _updatingFromControl = false;
  }

  void _onControlChanged(ControlChanges changes) {
    // Listeners were already notified by the text change: either the edit
    // that caused this control change, or the text update that followed it.
    if (_updatingFromView || _textSetFromControl) {
      _textSetFromControl = false;
      return;
    }

    if (changes.status || changes.touched) {
      notifyListeners();
    }
  }

  static ControlValueAccessor<K, String> _defaultValueAccessorFor<K>(
    FormControl<K> control,
  ) {
    if (control is FormControl<int>) {
      return IntValueAccessor() as ControlValueAccessor<K, String>;
    } else if (control is FormControl<double>) {
      return DoubleValueAccessor() as ControlValueAccessor<K, String>;
    } else if (control is FormControl<DateTime>) {
      return DateTimeValueAccessor() as ControlValueAccessor<K, String>;
    }

    return DefaultValueAccessor<K, String>();
  }

  @override
  void dispose() {
    removeListener(_onTextChanged);
    control.removeListener(_onControlChanged);
    _valueAccessor.dispose();
    super.dispose();
  }
}
