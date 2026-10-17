import 'dart:async';

import 'package:bind_forms_core/bind_forms_core.dart';

final _streams = Expando<_ControlStreams<Object?>>();

_ControlStreams<T> _streamsOf<T>(AbstractControl<T> control) =>
    (_streams[control] ??= _ControlStreams<T>(control)) as _ControlStreams<T>;

/// Exposes any control's changes as streams.
///
/// Each stream emits once per control operation that changed what it
/// reports, with the control's state after the operation. Events are
/// delivered asynchronously, like any broadcast stream; use
/// [AbstractControl.addListener] to react synchronously.
///
/// The streams are broadcast streams. A stream only listens to the control
/// while it has subscribers, and closes when the control is disposed, so
/// there is nothing to dispose.
extension ControlStreamsExtension<T> on AbstractControl<T> {
  /// Emits the control's value every time it changes.
  Stream<T?> get valueChanges => _streamsOf(this).valueChanges;

  /// Emits the control's status every time its status, errors, or
  /// dirty/pristine state change.
  Stream<ControlStatus> get statusChanged => _streamsOf(this).statusChanged;

  /// Emits the control's touched state every time it is marked touched or
  /// untouched.
  Stream<bool> get touchChanges => _streamsOf(this).touchChanges;
}

/// Streams that only make sense for a [FormControl].
extension FormControlStreamsExtension<T> on FormControl<T> {
  /// Emits whether the control has focus every time that changes.
  Stream<bool> get focusChanges => _streamsOf(this).focusChanges;
}

/// Streams that only make sense for a [FormGroup] or a [FormArray].
extension FormControlCollectionStreamsExtension<T> on FormControlCollection<T> {
  /// Emits the collection's children every time a control is added or
  /// removed.
  Stream<List<AbstractControl<Object?>>> get collectionChanges =>
      _streamsOf(this).collectionChanges;
}

class _ControlStreams<T> {
  _ControlStreams(this.control);

  final AbstractControl<T> control;

  late final Stream<T?> valueChanges = _stream(
    (changes) => changes.value,
    () => control.value,
  );

  late final Stream<ControlStatus> statusChanged = _stream(
    (changes) => changes.status,
    () => control.status,
  );

  late final Stream<bool> touchChanges = _stream(
    (changes) => changes.touched,
    () => control.touched,
  );

  late final Stream<bool> focusChanges = _stream(
    (changes) => changes.focus,
    () => (control as FormControl<T>).hasFocus,
  );

  late final Stream<List<AbstractControl<Object?>>> collectionChanges = _stream(
    (changes) => changes.collection,
    () => switch (control) {
      FormGroup(:final controls) => List.unmodifiable(controls.values),
      FormArray<Object?>(:final controls) => List.unmodifiable(controls),
      _ => const <AbstractControl<Object?>>[],
    },
  );

  /// A broadcast stream that listens to [control] only while it has
  /// subscribers, emits [read] after every change [reports], and closes when
  /// [control] is disposed.
  Stream<E> _stream<E>(
    bool Function(ControlChanges changes) reports,
    E Function() read,
  ) {
    late final StreamController<E> controller;
    void listener(ControlChanges changes) {
      if (reports(changes)) {
        controller.add(read());
      }
    }

    controller = StreamController<E>.broadcast(
      onListen: () => control.addListener(listener),
      onCancel: () => control.removeListener(listener),
    );
    control.whenDisposed.then((_) => controller.close());
    return controller.stream;
  }
}
