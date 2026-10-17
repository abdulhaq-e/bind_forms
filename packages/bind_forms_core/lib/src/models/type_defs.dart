// Copyright 2020 Joan Pablo Jimenez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:bind_forms_core/bind_forms_core.dart';

/// Signature of the function that determines whether the validation errors
/// of a [control] should be shown.
typedef ShowErrorsFunction<T> = bool Function(FormControl<T> control);

/// Signature of the function that returns a validation message for an
/// [error] object.
typedef ValidationMessageFunction = String Function(Object error);
