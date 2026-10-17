import 'package:bind_forms_core/bind_forms_core.dart';
import 'package:signals_core/signals_core.dart';

final _signals = Expando<ControlSignals<Object?>>();

/// Exposes any control's state as signals.
extension ControlSignalsExtension<T> on AbstractControl<T> {
  /// This control's state as signals.
  ///
  /// The same instance is returned every time. It subscribes to the control
  /// on first access and lives as long as the control, so there is nothing
  /// to dispose.
  ControlSignals<T> get signals =>
      (_signals[this] ??= ControlSignals<T>._(this)) as ControlSignals<T>;
}

/// A control's state as read-only signals.
///
/// Every operation on a control notifies once, after it completes, and
/// every signal that changed is updated inside a single [batch]. Effects and
/// computeds therefore run once per operation and never see a
/// half-updated control: no value from after an update next to a status
/// from before it.
///
/// The signals are read-only. Change the control itself (`control.value =`,
/// `markAsTouched()`, ...) so that validation, dirty tracking, and parents
/// stay in charge.
final class ControlSignals<T> {
  ControlSignals._(this.control)
    : _value = Signal(control.value),
      _status = Signal(control.status),
      _errors = Signal(control.errors),
      _touched = Signal(control.touched),
      _dirty = Signal(control.dirty),
      _focused = Signal(_hasFocus(control)),
      _children = Signal(_childrenOf(control)) {
    control.addListener(_onControlChanged);
  }

  /// The control these signals mirror.
  final AbstractControl<T> control;

  final Signal<T?> _value;
  final Signal<ControlStatus> _status;
  final Signal<Map<String, dynamic>> _errors;
  final Signal<bool> _touched;
  final Signal<bool> _dirty;
  final Signal<bool> _focused;
  final Signal<List<AbstractControl<Object?>>> _children;

  /// The control's value.
  ReadonlySignal<T?> get value => _value;

  /// The control's validation status.
  ReadonlySignal<ControlStatus> get status => _status;

  /// The control's errors. For groups and arrays, includes the children's.
  ReadonlySignal<Map<String, dynamic>> get errors => _errors;

  /// Whether the control has been touched (focused and then blurred).
  ReadonlySignal<bool> get touched => _touched;

  /// Whether the user has changed the control's value.
  ReadonlySignal<bool> get dirty => _dirty;

  /// Whether the control has focus. Always false for groups and arrays.
  ReadonlySignal<bool> get focused => _focused;

  /// The children of a group or array; empty for a [FormControl].
  ReadonlySignal<List<AbstractControl<Object?>>> get children => _children;

  /// Whether [status] is [ControlStatus.valid].
  late final ReadonlySignal<bool> valid = computed(
    () => _status.value == ControlStatus.valid,
  );

  /// Whether [status] is [ControlStatus.invalid].
  late final ReadonlySignal<bool> invalid = computed(
    () => _status.value == ControlStatus.invalid,
  );

  /// Whether [status] is [ControlStatus.pending].
  late final ReadonlySignal<bool> pending = computed(
    () => _status.value == ControlStatus.pending,
  );

  /// Whether [status] is anything but [ControlStatus.disabled].
  late final ReadonlySignal<bool> enabled = computed(
    () => _status.value != ControlStatus.disabled,
  );

  void _onControlChanged(ControlChanges changes) {
    // Refresh everything rather than trusting each change flag: signals skip
    // unchanged values, so this costs a few comparisons and can't go stale.
    batch(() {
      _set(_value, control.value);
      _set(_status, control.status);
      _set(_errors, control.errors);
      _set(_touched, control.touched);
      _set(_dirty, control.dirty);
      _set(_focused, _hasFocus(control));
      if (changes.collection) {
        _children.value = _childrenOf(control);
      }
    });
  }

  /// Groups and arrays build a new value and errors map on every read, so
  /// compare structurally, not with `==`.
  static void _set<V>(Signal<V> signal, V value) {
    if (!_deepEquals(signal.peek(), value)) {
      signal.value = value;
    }
  }

  static bool _hasFocus(AbstractControl<Object?> control) =>
      control is FormControl<Object?> && control.hasFocus;

  static List<AbstractControl<Object?>> _childrenOf(
    AbstractControl<Object?> control,
  ) => switch (control) {
    FormGroup() => List.unmodifiable(control.controls.values),
    FormArray<Object?>() => List.unmodifiable(control.controls),
    _ => const [],
  };
}

/// Signals that only make sense for a [FormControl].
extension FormControlSignals<T> on ControlSignals<T> {
  /// The message a UI should show for the control's first error, or `null`.
  ///
  /// Recomputes when the errors, status, touched or dirty state change. See
  /// [ControlErrorText.errorText] for [validationMessages],
  /// [fallbackMessages] and [showErrors].
  ///
  /// Each call creates a new computed, so create it once (e.g. in
  /// `initState` or a field) rather than in `build`.
  ReadonlySignal<String?> errorText({
    Map<String, ValidationMessageFunction>? validationMessages,
    Map<String, ValidationMessageFunction>? fallbackMessages,
    ShowErrorsFunction<T>? showErrors,
  }) {
    final control = this.control as FormControl<T>;
    return computed(() {
      // Read the signals the result depends on, so the computed tracks them.
      _errors.value;
      _status.value;
      _touched.value;
      _dirty.value;
      return control.errorText(
        validationMessages: validationMessages,
        fallbackMessages: fallbackMessages,
        showErrors: showErrors,
      );
    });
  }
}

bool _deepEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a is Map && b is Map) {
    return a.length == b.length &&
        a.keys.every(
          (key) => b.containsKey(key) && _deepEquals(a[key], b[key]),
        );
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_deepEquals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}
