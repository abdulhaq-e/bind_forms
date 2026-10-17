// Copyright 2020 Joan Pablo Jimenez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:bind_forms_core/bind_forms_core.dart';

/// Computes the validation message a UI should show for a control.
extension ControlErrorText<T> on FormControl<T> {
  /// The message for the control's first error, or `null` if no error
  /// should be shown right now.
  ///
  /// Errors are shown when [showErrors] returns true, by default when the
  /// control is invalid and touched. The message comes from
  /// [validationMessages], then [fallbackMessages] (e.g. app-wide
  /// messages), and is the error key itself if neither has one.
  String? errorText({
    Map<String, ValidationMessageFunction>? validationMessages,
    Map<String, ValidationMessageFunction>? fallbackMessages,
    ShowErrorsFunction<T>? showErrors,
  }) {
    final shouldShowErrors = showErrors?.call(this) ?? (invalid && touched);
    if (!hasErrors || !shouldShowErrors) {
      return null;
    }

    final errorKey = errors.keys.first;
    final message =
        validationMessages?[errorKey] ?? fallbackMessages?[errorKey];

    return message != null ? message(getError(errorKey)!) : errorKey;
  }
}
