import 'package:bind_forms/bind_forms.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) =>
    Directionality(textDirection: TextDirection.ltr, child: child);

void main() {
  group('TextControlBuilder', () {
    testWidgets('binds the text and rebuilds on control changes', (
      tester,
    ) async {
      final control = FormControl<String>(
        value: 'a',
        validators: [Validators.required],
      );
      addTearDown(control.dispose);
      late FormControlTextEditingController<String> controller;

      await tester.pumpWidget(
        _app(
          TextControlBuilder(
            control: control,
            validationMessages: {ValidationMessage.required: (_) => 'Needed'},
            builder: (context, field) {
              controller = field;
              return Text(field.errorText(context) ?? 'ok');
            },
          ),
        ),
      );
      expect(controller.text, 'a');
      expect(find.text('ok'), findsOneWidget);

      control.markAsTouched();
      control.value = '';
      await tester.pump();

      expect(controller.text, '');
      expect(find.text('Needed'), findsOneWidget);
    });

    testWidgets('keeps the controller across rebuilds, picking up messages', (
      tester,
    ) async {
      final control = FormControl<String>(
        validators: [Validators.required],
        touched: true,
      );
      addTearDown(control.dispose);
      final controllers = <FormControlTextEditingController<String>>{};

      Widget build(String message) => _app(
        TextControlBuilder(
          control: control,
          validationMessages: {ValidationMessage.required: (_) => message},
          builder: (context, field) {
            controllers.add(field);
            return Text(field.errorText(context) ?? 'ok');
          },
        ),
      );

      await tester.pumpWidget(build('first'));
      expect(find.text('first'), findsOneWidget);

      await tester.pumpWidget(build('second'));
      expect(find.text('second'), findsOneWidget);
      expect(controllers, hasLength(1));
    });

    testWidgets(
      'a new control gets a new controller; the old one is disposed',
      (tester) async {
        final first = FormControl<String>(value: 'first');
        final second = FormControl<String>(value: 'second');
        addTearDown(first.dispose);
        addTearDown(second.dispose);

        Widget build(FormControl<String> control) => _app(
          TextControlBuilder(
            control: control,
            builder: (context, field) => Text(field.text),
          ),
        );

        await tester.pumpWidget(build(first));
        await tester.pumpWidget(build(second));
        expect(find.text('second'), findsOneWidget);

        // The old controller no longer follows its control.
        first.value = 'changed';
        await tester.pump();
        expect(find.text('second'), findsOneWidget);
      },
    );

    testWidgets('disposes the controller with the widget', (tester) async {
      final control = FormControl<String>();
      addTearDown(control.dispose);

      await tester.pumpWidget(
        _app(
          TextControlBuilder(
            control: control,
            builder: (context, field) =>
                Focus(focusNode: field.focusNode, child: const SizedBox()),
          ),
        ),
      );
      expect(control.focusControllers, hasLength(1));

      await tester.pumpWidget(const SizedBox());

      expect(control.focusControllers, isEmpty);
    });
  });

  group('ValueControlBuilder', () {
    testWidgets('exposes the value and updates the control', (tester) async {
      final control = FormControl<bool>(value: false);
      addTearDown(control.dispose);
      late FormControlValueNotifier<bool> notifier;

      await tester.pumpWidget(
        _app(
          ValueControlBuilder(
            control: control,
            builder: (context, field) {
              notifier = field;
              return Text('${field.value}');
            },
          ),
        ),
      );
      expect(find.text('false'), findsOneWidget);

      notifier.onChanged(true);
      await tester.pump();

      expect(control.value, true);
      expect(control.dirty, true);
      expect(find.text('true'), findsOneWidget);
    });
  });

  group('ControlBuilder', () {
    testWidgets('rebuilds when any child of a group changes', (tester) async {
      final form = FormGroup({
        'name': FormControl<String>(validators: [Validators.required]),
      });
      addTearDown(form.dispose);

      await tester.pumpWidget(
        _app(
          ControlBuilder(
            control: form,
            builder: (context, form) => Text(form.valid ? 'valid' : 'invalid'),
          ),
        ),
      );
      expect(find.text('invalid'), findsOneWidget);

      form.formControl<String>('name').value = 'John';
      await tester.pump();

      expect(find.text('valid'), findsOneWidget);
    });
  });

  group('BindFormsConfig', () {
    testWidgets('error texts rebuild when the config changes', (tester) async {
      final control = FormControl<String>(
        validators: [Validators.required],
        touched: true,
      );
      addTearDown(control.dispose);
      // The same instance every time, so only its dependency on the config
      // can rebuild it.
      final child = _ErrorText(control);

      Widget build(String message) => _app(
        BindFormsConfig(
          validationMessages: {ValidationMessage.required: (_) => message},
          child: child,
        ),
      );

      await tester.pumpWidget(build('English'));
      expect(find.text('English'), findsOneWidget);

      await tester.pumpWidget(build('Deutsch'));
      expect(find.text('Deutsch'), findsOneWidget);
    });
  });

  group('several adapters on one control', () {
    testWidgets('each focus node marks the control touched on blur', (
      tester,
    ) async {
      final control = FormControl<double>(value: 1);
      addTearDown(control.dispose);
      final slider = FormControlValueNotifier(control);
      final field = FormControlTextEditingController(control);
      addTearDown(slider.dispose);
      addTearDown(field.dispose);

      await tester.pumpWidget(
        Column(
          children: [
            Focus(focusNode: slider.focusNode, child: const SizedBox()),
            Focus(focusNode: field.focusNode, child: const SizedBox()),
          ],
        ),
      );
      expect(control.focusControllers, hasLength(2));

      slider.focusNode.requestFocus();
      await tester.pump();
      expect(control.hasFocus, true);

      field.focusNode.requestFocus();
      await tester.pump();
      expect(control.touched, true);
      expect(control.hasFocus, true);

      control.markAsUntouched();
      field.focusNode.unfocus();
      await tester.pump();
      expect(control.touched, true);
      expect(control.hasFocus, false);
    });
  });
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.control);

  final FormControl<String> control;

  @override
  Widget build(BuildContext context) => Text(
    control.errorText(
          fallbackMessages: BindFormsConfig.of(context)?.validationMessages,
        ) ??
        '',
  );
}
