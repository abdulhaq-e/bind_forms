import 'package:bind_forms/bind_forms.dart';
import 'package:flutter/foundation.dart';

final _listenables = Expando<_ControlListenable>();

/// Exposes any control as a Flutter [Listenable].
extension ControlListenableExtension on AbstractControl<Object?> {
  /// A [Listenable] that notifies once per operation that changes this
  /// control (value, status, touched, focus, or children).
  ///
  /// Use it with `ListenableBuilder`, `AnimatedBuilder`, or anything else
  /// that takes a [Listenable]. The same instance is returned every time and
  /// it holds no resources of its own, so there is nothing to dispose:
  ///
  /// ```dart
  /// ListenableBuilder(
  ///   listenable: form.listenable,
  ///   builder: (context, _) => ElevatedButton(
  ///     onPressed: form.valid ? submit : null,
  ///     child: const Text('Submit'),
  ///   ),
  /// );
  /// ```
  Listenable get listenable => _listenables[this] ??= _ControlListenable(this);
}

class _ControlListenable implements Listenable {
  _ControlListenable(this._control);

  final AbstractControl<Object?> _control;

  // A listener may be added more than once, and is then called once per
  // registration, like [ChangeNotifier].
  final Map<VoidCallback, List<ControlListener>> _registrations = {};

  @override
  void addListener(VoidCallback listener) {
    void registration(ControlChanges _) => listener();
    _registrations.putIfAbsent(listener, () => []).add(registration);
    _control.addListener(registration);
  }

  @override
  void removeListener(VoidCallback listener) {
    final registrations = _registrations[listener];
    if (registrations == null) return;

    _control.removeListener(registrations.removeLast());
    if (registrations.isEmpty) {
      _registrations.remove(listener);
    }
  }
}
