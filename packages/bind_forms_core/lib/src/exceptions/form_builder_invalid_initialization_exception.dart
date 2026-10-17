// Copyright 2020 Joan Pablo Jimenez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:bind_forms_core/bind_forms_core.dart';

/// This exception is thrown by [FormBuilder] when trying to create
/// controls with bad initialization params.
class FormBuilderInvalidInitializationException extends BindFormsException {
  final String message;

  /// Create an instance of the exception with the specified [message]
  FormBuilderInvalidInitializationException(this.message);

  /// Returns the string representation of the exception.
  @override
  String toString() {
    return 'FormBuilderInvalidInitializationException: $message';
  }
}
