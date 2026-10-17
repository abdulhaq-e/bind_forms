// Copyright 2020 Joan Pablo Jimenez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:bind_forms/bind_forms.dart';
import 'package:flutter/widgets.dart';

import 'text_control_sync.dart';

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
/// "Touched" is driven by focus, not typing, so pass [focusNode] to the
/// widget if you want errors to appear on blur:
///
/// ```dart
/// final controller = FormControlTextEditingController<String>(
///   form.control('email') as FormControl<String>,
/// );
///
/// // ... in build():
/// ListenableBuilder(
///   listenable: controller,
///   builder: (context, _) => TextField(
///     controller: controller,
///     focusNode: controller.focusNode,
///     decoration: InputDecoration(errorText: controller.errorText(context)),
///   ),
/// );
///
/// // ... in dispose():
/// controller.dispose();
/// ```
class FormControlTextEditingController<T> extends TextEditingController
    with FormControlErrorTextMixin<T>, FormControlFocusMixin<T> {
  /// The control this controller is bound to.
  @override
  final FormControl<T> control;

  @override
  final Map<String, ValidationMessageFunction>? validationMessages;

  @override
  final ShowErrorsFunction<T>? showErrors;

  late final TextControlSync<T> _sync;

  /// Creates a controller bound to [control].
  ///
  /// [valueAccessor] converts between the control's value and the text. If
  /// omitted, one is picked from the control's type: [IntValueAccessor],
  /// [DoubleValueAccessor], [DateTimeValueAccessor], [TimeOfDayValueAccessor],
  /// or [DefaultValueAccessor] for anything else.
  ///
  /// If [focusNode] is provided, [this.focusNode] returns it instead of a
  /// node owned by this controller.
  FormControlTextEditingController(
    this.control, {
    ControlValueAccessor<T, String>? valueAccessor,
    this.validationMessages,
    this.showErrors,
    FocusNode? focusNode,
  }) {
    useFocusNode(focusNode);
    _sync = TextControlSync(
      control: control,
      textController: this,
      valueAccessor: valueAccessor,
      onControlChanged: _onControlChanged,
    );
  }

  void _onControlChanged(ControlChanges changes, {required bool textNotified}) {
    if (!textNotified && (changes.status || changes.touched)) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sync.dispose();
    disposeFocusController();
    super.dispose();
  }
}
