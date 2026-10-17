import 'package:test/test.dart';
import 'package:bind_forms_core/bind_forms_core.dart';

void main() {
  group('Min validator tests', () {
    test('FormControl with greater than value is valid', () {
      // Given: an invalid control
      final control = FormControl<int>(
        value: 20,
        validators: [Validators.min(10)],
      );

      // Expect: control is invalid
      expect(control.valid, true);
    });

    test('FormControl with equals value is valid', () {
      // Given: an invalid control
      final control = FormControl<int>(
        value: 10,
        validators: [Validators.min(10)],
      );

      // Expect: control is invalid
      expect(control.valid, true);
    });

    test('FormControl with lower value is invalid', () {
      // Given: an invalid control
      final control = FormControl<int>(
        value: 5,
        validators: [Validators.min(10)],
      );

      // Expect: control is invalid
      expect(control.valid, false);
    });

    test('FormControl with null value has error', () {
      // Given: an invalid control
      final control = FormControl<int>(validators: [Validators.min(10)]);

      // Expect: control is invalid
      expect(control.valid, false);
    });
  });
}
