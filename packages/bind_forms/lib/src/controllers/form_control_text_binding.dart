import 'package:bind_forms/bind_forms.dart';
import 'package:flutter/widgets.dart';

import 'text_control_sync.dart';

/// Binds a [TextEditingController] you already have to a [FormControl].
///
/// Use this instead of [FormControlTextEditingController] when the widget
/// needs its own controller subclass, such as a syntax-highlighting
/// `CodeController` or a spell-checking `LanguageToolController`. Dart has
/// no multiple inheritance, so a controller can't be both; binding
/// composes instead.
///
/// The control's value wins at creation: [textController]'s text is
/// replaced with it. Listeners are notified when the control's value,
/// status, or touched state changes.
///
/// ```dart
/// final code = CodeController(language: dart);
/// final binding = FormControlTextBinding(control, code);
///
/// // ... in build():
/// ListenableBuilder(
///   listenable: binding,
///   builder: (context, _) => CodeField(
///     controller: code,
///     focusNode: binding.focusNode,
///     decoration: BoxDecoration(
///       border: binding.errorText(context) != null ? errorBorder : null,
///     ),
///   ),
/// );
///
/// // ... in dispose():
/// binding.dispose();
/// code.dispose();
/// ```
class FormControlTextBinding<T> extends ChangeNotifier
    with FormControlErrorTextMixin<T>, FormControlFocusMixin<T> {
  /// The control this binding is bound to.
  @override
  final FormControl<T> control;

  /// The controller kept in sync with [control]. Not owned: dispose it
  /// yourself, after this binding.
  final TextEditingController textController;

  @override
  final Map<String, ValidationMessageFunction>? validationMessages;

  @override
  final ShowErrorsFunction<T>? showErrors;

  late final TextControlSync<T> _sync;

  /// Binds [textController] to [control].
  ///
  /// [valueAccessor] and [focusNode] work as in
  /// [FormControlTextEditingController.new].
  FormControlTextBinding(
    this.control,
    this.textController, {
    ControlValueAccessor<T, String>? valueAccessor,
    this.validationMessages,
    this.showErrors,
    FocusNode? focusNode,
  }) {
    useFocusNode(focusNode);
    _sync = TextControlSync(
      control: control,
      textController: textController,
      valueAccessor: valueAccessor,
      onControlChanged: _onControlChanged,
    );
  }

  void _onControlChanged(ControlChanges changes, {required bool textNotified}) {
    // The text controller's own notification doesn't reach listeners of this
    // binding, so notify regardless of [textNotified].
    if (changes.value || changes.status || changes.touched) {
      notifyListeners();
    }
  }

  /// Stops syncing. Doesn't dispose [textController].
  @override
  void dispose() {
    _sync.dispose();
    disposeFocusController();
    super.dispose();
  }
}
