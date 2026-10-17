import 'package:bind_forms/bind_forms.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('blurring the focus node marks the control touched', (
    tester,
  ) async {
    final control = FormControl<String>();
    final focus = FocusNodeController();
    control.registerFocusController(focus);
    addTearDown(focus.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Focus(focusNode: focus.focusNode, child: const SizedBox()),
      ),
    );

    control.focus();
    await tester.pump();
    expect(focus.focusNode.hasFocus, true);
    expect(control.touched, false);

    focus.focusNode.unfocus();
    await tester.pump();
    expect(control.hasFocus, false);
    expect(control.touched, true);
  });
}
