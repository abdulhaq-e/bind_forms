// Copyright 2020 Joan Pablo Jimenez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:bind_forms_core/bind_forms_core.dart';

/// Exception that is raised by [ControlValueAccessor]
class ValueAccessorException extends BindFormsException {
  final String message;

  /// Constructs an instance of the exception with the provided [message].
  ValueAccessorException(this.message);

  @override
  String toString() {
    return 'ValueAccessorException: $message';
  }
}
