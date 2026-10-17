import 'package:bind_forms/bind_forms.dart';
import 'package:flutter/widgets.dart';

/// Gives a `FormControl*` adapter its own [focusNode], wired to [control].
///
/// Hand [focusNode] to the widget and losing focus marks the control as
/// touched, while `control.focus()` / `control.unfocus()` move UI focus. No
/// separate [FocusNodeController] to create, register, or dispose.
///
/// The focus controller is created and registered with [control] the first
/// time [focusNode] is read, so an adapter whose [focusNode] is never used
/// doesn't track focus at all. A control has a single focus controller, so
/// reading [focusNode] replaces any focus controller registered with
/// [control] before.
mixin FormControlFocusMixin<T> {
  /// The control this adapter is bound to.
  FormControl<T> get control;

  FocusNode? _providedFocusNode;
  FocusNodeController? _focusController;

  /// The focus node to pass to the widget's `focusNode` parameter.
  FocusNode get focusNode =>
      (_focusController ??= _registerFocusController()).focusNode;

  /// Uses [focusNode] instead of creating one. A provided node is not
  /// disposed by the adapter. Call from the constructor.
  @protected
  void useFocusNode(FocusNode? focusNode) => _providedFocusNode = focusNode;

  /// Unregisters and disposes the focus controller, if one was created. Call
  /// from `dispose`.
  @protected
  void disposeFocusController() {
    final focusController = _focusController;
    if (focusController != null) {
      control.unregisterFocusController(focusController);
      focusController.dispose();
      _focusController = null;
    }
  }

  FocusNodeController _registerFocusController() {
    final focusController = FocusNodeController(focusNode: _providedFocusNode);
    control.registerFocusController(focusController);
    return focusController;
  }
}
