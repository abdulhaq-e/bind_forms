import 'package:bind_forms_core/bind_forms_core.dart';

/// This exception is thrown by the typed lookups of a [FormGroup] or a
/// [FormArray] (such as [FormControlCollection.formControl]) when the control
/// found by name isn't of the requested type.
class FormControlTypeException extends BindFormsException {
  /// The name or path of the control.
  final String controlName;

  /// The type that was requested.
  final Type expectedType;

  /// The control that was found.
  final AbstractControl<dynamic> control;

  /// Creates an instance of the exception.
  FormControlTypeException({
    required this.controlName,
    required this.expectedType,
    required this.control,
  });

  @override
  String toString() =>
      'FormControlTypeException: control with name: \'$controlName\' is a '
      '${control.runtimeType}, not a $expectedType.';
}
