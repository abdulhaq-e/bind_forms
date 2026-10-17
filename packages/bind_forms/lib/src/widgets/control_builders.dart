import 'package:bind_forms/bind_forms.dart';
import 'package:flutter/widgets.dart';

/// Builds a widget from a [FormControlTextEditingController] that this
/// widget creates, rebuilds on, and disposes.
///
/// It wraps no input widget: [builder] builds the real one with the
/// controller, so every parameter is that widget's own. It only takes care
/// of the adapter's lifecycle, which otherwise needs a `StatefulWidget`, a
/// `ListenableBuilder` and a `dispose`:
///
/// ```dart
/// TextControlBuilder(
///   control: form.formControl<String>('email'),
///   validationMessages: {ValidationMessage.email: (_) => 'Not an email'},
///   builder: (context, field) => TextField(
///     controller: field,
///     focusNode: field.focusNode,
///     decoration: InputDecoration(errorText: field.errorText(context)),
///   ),
/// );
/// ```
///
/// A new controller is created when [control] or [focusNode] changes.
/// [valueAccessor] is only read when the controller is created. Changes to
/// [validationMessages] and [showErrors] apply on the next build.
class TextControlBuilder<T> extends StatefulWidget {
  /// Creates a builder bound to [control].
  const TextControlBuilder({
    super.key,
    required this.control,
    required this.builder,
    this.valueAccessor,
    this.validationMessages,
    this.showErrors,
    this.focusNode,
  });

  /// The control to bind.
  final FormControl<T> control;

  /// Builds the input widget. Called whenever the text, or the control's
  /// value, status, or touched state change.
  final Widget Function(
    BuildContext context,
    FormControlTextEditingController<T> controller,
  )
  builder;

  /// See [FormControlTextEditingController.new].
  final ControlValueAccessor<T, String>? valueAccessor;

  /// See [FormControlErrorTextMixin.validationMessages].
  final Map<String, ValidationMessageFunction>? validationMessages;

  /// See [FormControlErrorTextMixin.showErrors].
  final ShowErrorsFunction<T>? showErrors;

  /// See [FormControlTextEditingController.new].
  final FocusNode? focusNode;

  @override
  State<TextControlBuilder<T>> createState() => _TextControlBuilderState<T>();
}

class _TextControlBuilderState<T> extends State<TextControlBuilder<T>> {
  late FormControlTextEditingController<T> _controller = _create();

  FormControlTextEditingController<T> _create() =>
      FormControlTextEditingController<T>(
        widget.control,
        valueAccessor: widget.valueAccessor,
        validationMessages: widget.validationMessages,
        showErrors: widget.showErrors,
        focusNode: widget.focusNode,
      );

  @override
  void didUpdateWidget(TextControlBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.control != oldWidget.control ||
        widget.focusNode != oldWidget.focusNode) {
      _disposeAfterFrame(_controller);
      _controller = _create();
    } else {
      _controller
        ..validationMessages = widget.validationMessages
        ..showErrors = widget.showErrors;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) => widget.builder(context, _controller),
  );
}

/// Builds a widget from a [FormControlValueNotifier] that this widget
/// creates, rebuilds on, and disposes.
///
/// For widgets that take a `value` and an `onChanged` (`Checkbox`,
/// `Switch`, `Slider`, `DropdownButton`, ...). Like [TextControlBuilder], it
/// wraps no input widget:
///
/// ```dart
/// ValueControlBuilder(
///   control: form.formControl<bool>('acceptTerms'),
///   builder: (context, field) => Checkbox(
///     value: field.value ?? false,
///     focusNode: field.focusNode,
///     isError: field.errorText(context) != null,
///     onChanged: field.enabled ? field.onChanged : null,
///   ),
/// );
/// ```
///
/// A new notifier is created when [control] or [focusNode] changes. Changes
/// to [validationMessages] and [showErrors] apply on the next build.
class ValueControlBuilder<T> extends StatefulWidget {
  /// Creates a builder bound to [control].
  const ValueControlBuilder({
    super.key,
    required this.control,
    required this.builder,
    this.validationMessages,
    this.showErrors,
    this.focusNode,
  });

  /// The control to bind.
  final FormControl<T> control;

  /// Builds the input widget. Called whenever the control's value, status,
  /// or touched state change.
  final Widget Function(BuildContext context, FormControlValueNotifier<T> field)
  builder;

  /// See [FormControlErrorTextMixin.validationMessages].
  final Map<String, ValidationMessageFunction>? validationMessages;

  /// See [FormControlErrorTextMixin.showErrors].
  final ShowErrorsFunction<T>? showErrors;

  /// See [FormControlValueNotifier.new].
  final FocusNode? focusNode;

  @override
  State<ValueControlBuilder<T>> createState() => _ValueControlBuilderState<T>();
}

class _ValueControlBuilderState<T> extends State<ValueControlBuilder<T>> {
  late FormControlValueNotifier<T> _notifier = _create();

  FormControlValueNotifier<T> _create() => FormControlValueNotifier<T>(
    widget.control,
    validationMessages: widget.validationMessages,
    showErrors: widget.showErrors,
    focusNode: widget.focusNode,
  );

  @override
  void didUpdateWidget(ValueControlBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.control != oldWidget.control ||
        widget.focusNode != oldWidget.focusNode) {
      _disposeAfterFrame(_notifier);
      _notifier = _create();
    } else {
      _notifier
        ..validationMessages = widget.validationMessages
        ..showErrors = widget.showErrors;
    }
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _notifier,
    builder: (context, _) => widget.builder(context, _notifier),
  );
}

/// Rebuilds whenever [control] changes: its value, status, touched or
/// focus state, or its children.
///
/// For anything that reads a control without editing it, such as a submit
/// button that is enabled while the form is valid:
///
/// ```dart
/// ControlBuilder(
///   control: form,
///   builder: (context, form) => FilledButton(
///     onPressed: form.valid ? submit : null,
///     child: const Text('Submit'),
///   ),
/// );
/// ```
///
/// The same as a `ListenableBuilder` on `control.listenable`, with the
/// control handed to [builder].
class ControlBuilder<C extends AbstractControl<Object?>>
    extends StatelessWidget {
  /// Creates a builder that rebuilds when [control] changes.
  const ControlBuilder({
    super.key,
    required this.control,
    required this.builder,
  });

  /// The control to listen to.
  final C control;

  /// Builds the widget from [control].
  final Widget Function(BuildContext context, C control) builder;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: control.listenable,
    builder: (context, _) => builder(context, control),
  );
}

/// Disposes an adapter that was just replaced only after the frame: until
/// the rebuild, the input widget still holds it.
void _disposeAfterFrame(ChangeNotifier adapter) {
  WidgetsBinding.instance.addPostFrameCallback((_) => adapter.dispose());
}
