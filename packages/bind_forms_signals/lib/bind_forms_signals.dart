/// Signals for bind_forms controls, built on the `signals` package.
///
/// ```dart
/// final email = form.control('email').signals;
///
/// effect(() => print('${email.value.value} is ${email.status.value}'));
/// ```
library;

export 'src/control_signals.dart';
