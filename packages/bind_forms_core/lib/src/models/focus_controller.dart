/// The UI side of a [FormControl]'s focus state.
///
/// [FormControl] is pure Dart and knows nothing about focus nodes, so a UI
/// layer implements this to connect its own focus primitive (e.g. a Flutter
/// `FocusNode`) to a control through [FormControl.registerFocusController].
///
/// The listener signature matches Flutter's `Listenable`, so a
/// `ChangeNotifier` subclass can implement this interface directly.
abstract interface class FocusController {
  /// Whether the UI element currently has focus.
  bool get hasFocus;

  /// Registers [listener] to be called when [hasFocus] changes from the UI.
  void addListener(void Function() listener);

  /// Removes a [listener] previously registered with [addListener].
  void removeListener(void Function() listener);

  /// Called by [FormControl] when its focus changes from the model side
  /// (`control.focus()` / `control.unfocus()`), so the UI can follow.
  void onControlFocusChanged(bool hasFocus);
}
