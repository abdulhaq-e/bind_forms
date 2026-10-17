// Copyright 2020 Joan Pablo Jimenez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:bind_forms/bind_forms.dart';
import 'package:flutter/widgets.dart';

/// A [ChangeNotifier] that stays in sync with a [FormControl], for widgets
/// that take a plain `value` + `onChanged` pair instead of a controller
/// (e.g. `Checkbox`, `Switch`, `Slider`, `DropdownButton`).
///
/// These widgets have no "controller" object, so there's nothing to hand
/// them beyond [value] and [onChanged]. Like
/// [FormControlTextEditingController], this never re-declares the target
/// widget's constructor, so it never goes stale when that widget's API
/// changes.
///
/// Listeners are notified once per control operation that changes the
/// control's value, status, or touched state.
///
/// "Touched" is driven by focus, not by toggling, so pass [focusNode] to
/// the widget if you want errors to appear on blur:
///
/// ```dart
/// final notifier = FormControlValueNotifier<bool>(
///   form.control('accept') as FormControl<bool>,
/// );
///
/// // ... in build():
/// ListenableBuilder(
///   listenable: notifier,
///   builder: (context, _) => Checkbox(
///     value: notifier.value ?? false,
///     focusNode: notifier.focusNode,
///     isError: notifier.errorText(context) != null,
///     onChanged: notifier.enabled ? notifier.onChanged : null,
///   ),
/// );
///
/// // ... in dispose():
/// notifier.dispose();
/// ```
class FormControlValueNotifier<T> extends ChangeNotifier
    with FormControlErrorTextMixin<T>, FormControlFocusMixin<T> {
  @override
  final FormControl<T> control;

  @override
  final Map<String, ValidationMessageFunction>? validationMessages;

  @override
  final ShowErrorsFunction<T>? showErrors;

  /// Creates a notifier bound to [control].
  ///
  /// If [focusNode] is provided, [this.focusNode] returns it instead of a
  /// node owned by this notifier.
  FormControlValueNotifier(
    this.control, {
    this.validationMessages,
    this.showErrors,
    FocusNode? focusNode,
  }) {
    useFocusNode(focusNode);
    control.addListener(_onControlChanged);
  }

  void _onControlChanged(ControlChanges changes) {
    if (changes.value || changes.status || changes.touched) {
      notifyListeners();
    }
  }

  /// The control's current value. Pass this straight to the target widget's
  /// `value` parameter.
  T? get value => control.value;

  /// Whether the control accepts input. Widgets take `null` (not `false`)
  /// as "disabled" for their `onChanged` parameter, so check this before
  /// passing [onChanged] through:
  /// `onChanged: notifier.enabled ? notifier.onChanged : null`.
  bool get enabled => control.enabled;

  /// Updates the control's value, marking it dirty if the value changed.
  /// Pass this straight to the target widget's `onChanged` parameter.
  void onChanged(T? value) {
    if (control.value != value) {
      control.markAsDirty(emitEvent: false);
      control.updateValue(value);
    }
  }

  @override
  void dispose() {
    control.removeListener(_onControlChanged);
    disposeFocusController();
    super.dispose();
  }
}
