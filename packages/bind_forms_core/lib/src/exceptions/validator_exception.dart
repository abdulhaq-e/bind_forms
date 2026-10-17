import 'package:bind_forms_core/bind_forms_core.dart';

/// Represents an exception thrown by a validator
class ValidatorException extends BindFormsException {
  final String message;

  /// Constructs an instance of the exception with the provided [message].
  ValidatorException(this.message);

  @override
  String toString() {
    return 'ValidatorException: $message';
  }
}
