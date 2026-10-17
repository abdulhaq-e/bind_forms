import 'package:bind_forms_core/bind_forms_core.dart';

/// Represents a control value accessor that converts from Iso8601 string value
/// to a [DateTime] data type.
///
/// Useful for date pickers bound to a control of type [String].
class Iso8601DateTimeValueAccessor
    extends ControlValueAccessor<String, DateTime> {
  @override
  DateTime? modelToViewValue(String? modelValue) {
    return modelValue == null || modelValue.trim().isEmpty
        ? null
        : DateTime.parse(modelValue);
  }

  @override
  String? viewToModelValue(DateTime? viewValue) {
    return viewValue?.toIso8601String();
  }
}
