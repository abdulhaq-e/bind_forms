// Copyright 2020 Joan Pablo Jimenez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:bind_forms_core/bind_forms_core.dart';
import 'package:flutter/widgets.dart';

/// Exposes app-wide form configuration to all descendant widgets.
///
/// ### Example:
/// ```dart
/// BindFormsConfig(
///   validationMessages: {
///     ValidationMessage.required: (_) => 'Field must not be empty',
///   },
///   child: MaterialApp(...),
/// );
/// ```
class BindFormsConfig extends InheritedWidget {
  /// Validation messages for each error key, used when an adapter has no
  /// message of its own for that key.
  final Map<String, ValidationMessageFunction> validationMessages;

  /// Creates an instance of [BindFormsConfig].
  const BindFormsConfig({
    required super.child,
    required this.validationMessages,
    super.key,
  });

  @override
  bool updateShouldNotify(covariant BindFormsConfig oldWidget) {
    return oldWidget.validationMessages != validationMessages;
  }

  /// Returns the nearest [BindFormsConfig] up the widget tree, or `null` if
  /// there is none.
  ///
  /// [context] depends on it, so it rebuilds when the configuration changes
  /// (e.g. new messages after a locale change).
  static BindFormsConfig? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BindFormsConfig>();
}
