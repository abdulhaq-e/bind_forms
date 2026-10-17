// Copyright 2020 Joan Pablo Jimenez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:bind_forms_core/bind_forms_core.dart';
import 'package:meta/meta.dart';

/// Type of the function to be called when the control emits a value changes
/// event.
typedef ChangeFunction<K> = dynamic Function(K? value);

/// Defines an interface that acts as a bridge between a [FormControl] and a
/// UI element whose value has a different data type (e.g. an `int` control
/// edited through a text field's `String`).
abstract class ControlValueAccessor<ModelDataType, ViewDataType> {
  FormControl<ModelDataType>? _control;
  ChangeFunction<ViewDataType>? _onChange;
  bool _viewToModelChange = false;

  /// Gets the control bind to this value accessor.
  FormControl<ModelDataType>? get control => _control;

  /// Returns the value that must be supplied to the [control].
  ///
  /// Converts value from UI data type to [control] data type.
  ModelDataType? viewToModelValue(ViewDataType? viewValue);

  /// Returns the value that must be supplied to the UI widget.
  ///
  /// Converts value from [control] data type to UI data type.
  ViewDataType? modelToViewValue(ModelDataType? modelValue);

  /// Updates the [control] with the provided value.
  ///
  /// Marks the control as dirty if the [viewValue] is different from the
  /// [control] value.
  ///
  /// Throws [ValueAccessorException] if no control is registered with this
  /// value accessor.
  ///
  /// See also [registerControl].
  void updateModel(ViewDataType? viewValue) {
    if (_control == null) {
      throw ValueAccessorException(
        'No control registered. Call [ControlValueAccessor.registerControl] to register a control first.',
      );
    }

    _viewToModelChange = true;

    final modelValue = viewToModelValue(viewValue);
    if (_control?.value != modelValue) {
      _control?.markAsDirty(emitEvent: false);
      _control?.updateValue(modelValue);
    } else {
      _viewToModelChange = false;
    }
  }

  /// Registers a the [control] with the value accessor.
  ///
  /// The argument [onChange] is optional and will be called, synchronously,
  /// every time the [control]'s value changes from anywhere other than
  /// [updateModel].
  void registerControl(
    FormControl<ModelDataType> control, {
    ChangeFunction<ViewDataType>? onChange,
  }) {
    _control?.removeListener(_onControlChanged);
    _control = control;
    _onChange = onChange;
    control.addListener(_onControlChanged);
  }

  /// Disposes the value accessors.
  @mustCallSuper
  void dispose() {
    _control?.removeListener(_onControlChanged);
  }

  void _onControlChanged(ControlChanges changes) {
    if (!changes.value) {
      return;
    }

    // The control is notified synchronously, so this is the change that
    // [updateModel] just made; the view already shows it.
    if (_viewToModelChange) {
      _viewToModelChange = false;
      return;
    }

    _onChange?.call(modelToViewValue(_control?.value));
  }
}
