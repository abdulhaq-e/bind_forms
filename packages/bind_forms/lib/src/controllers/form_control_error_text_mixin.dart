// Copyright 2020 Joan Pablo Jimenez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:bind_forms/bind_forms.dart';
import 'package:flutter/widgets.dart';

/// Shared by the `FormControl*` adapters (e.g.
/// [FormControlTextEditingController], [FormControlValueNotifier]) that
/// bind a real widget to a [FormControl] without wrapping that widget.
///
/// All adapters compute "which error message, if any, should be visible
/// right now" the same way, instead of every adapter re-implementing it.
mixin FormControlErrorTextMixin<T> on Listenable {
  /// The control this adapter is bound to.
  FormControl<T> get control;

  /// A function that returns the [Map] that stores custom validation
  /// messages for each error. Falls back to [BindFormsConfig] when a key
  /// isn't found here.
  Map<String, ValidationMessageFunction>? get validationMessages;

  /// Customizes when [errorText] returns a message. Defaults to
  /// `control.invalid && control.touched`.
  ShowErrorsFunction<T>? get showErrors;

  /// The first validation error message, or `null` if none should be shown
  /// right now.
  ///
  /// Requires a [BuildContext] only to fall back to app-wide
  /// [BindFormsConfig.validationMessages]; nothing else here needs one.
  String? errorText(BuildContext context) => control.errorText(
    validationMessages: validationMessages,
    fallbackMessages: BindFormsConfig.of(context)?.validationMessages,
    showErrors: showErrors,
  );
}
