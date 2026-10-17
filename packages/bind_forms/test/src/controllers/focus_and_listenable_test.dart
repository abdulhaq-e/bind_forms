import 'package:bind_forms/bind_forms.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormControlFocusMixin', () {
    testWidgets('blurring the adapter focusNode marks the control touched', (
      tester,
    ) async {
      final control = FormControl<String>();
      final controller = FormControlTextEditingController(control);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        Focus(focusNode: controller.focusNode, child: const SizedBox()),
      );

      control.focus();
      await tester.pump();
      expect(controller.focusNode.hasFocus, true);

      controller.focusNode.unfocus();
      await tester.pump();
      expect(control.touched, true);
    });

    test('no focus controller is registered until focusNode is read', () {
      final control = FormControl<bool>();
      final notifier = FormControlValueNotifier(control);
      addTearDown(notifier.dispose);

      expect(control.focusControllers, isEmpty);
      notifier.focusNode;
      expect(control.focusControllers.single, isA<FocusNodeController>());
    });

    test('dispose unregisters the focus controller', () {
      final control = FormControl<String>();
      final controller = FormControlTextEditingController(control);
      controller.focusNode;

      controller.dispose();

      expect(control.focusControllers, isEmpty);
    });

    test('a provided focus node is used and not disposed', () {
      final node = FocusNode();
      addTearDown(node.dispose);
      final control = FormControl<String>();
      final controller = FormControlTextEditingController(
        control,
        focusNode: node,
      );

      expect(controller.focusNode, same(node));
      controller.dispose();
      // Still usable: disposing a disposed node would throw.
      expect(() => node.addListener(() {}), returnsNormally);
    });
  });

  group('control.listenable', () {
    test('returns the same instance every time', () {
      final form = FormGroup({'name': FormControl<String>()});

      expect(form.listenable, same(form.listenable));
    });

    test('notifies once per operation, including child changes', () {
      final form = FormGroup({
        'a': FormControl<int>(),
        'b': FormControl<int>(),
      });
      var calls = 0;
      void listener() => calls++;
      form.listenable.addListener(listener);

      form.patchValue({'a': 1, 'b': 2});
      expect(calls, 1);

      form.control('a').value = 3;
      expect(calls, 2);

      form.listenable.removeListener(listener);
      form.control('a').value = 4;
      expect(calls, 2);
    });

    test(
      'a listener added twice is called twice and removed one at a time',
      () {
        final control = FormControl<int>();
        var calls = 0;
        void listener() => calls++;
        control.listenable
          ..addListener(listener)
          ..addListener(listener);

        control.value = 1;
        expect(calls, 2);

        control.listenable.removeListener(listener);
        control.value = 2;
        expect(calls, 3);
      },
    );
  });
}
