import 'package:bind_forms/bind_forms.dart';
import 'package:bind_forms_signals/bind_forms_signals.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// The login form again, observed with signals instead of `Listenable`s.
///
/// The widgets still bind through the bind_forms adapters (a text field
/// needs a `TextEditingController` whatever you observe it with). Only the
/// rebuilds change: `SignalBuilder` tracks whichever signals its builder
/// reads.
class SignalsPage extends StatefulWidget {
  const SignalsPage({super.key});

  @override
  State<SignalsPage> createState() => _SignalsPageState();
}

class _SignalsPageState extends State<SignalsPage> {
  final form = FormGroup({
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    'password': FormControl<String>(
      validators: [Validators.required, Validators.minLength(8)],
    ),
  });

  late final _email = FormControlTextEditingController<String>(
    form.formControl<String>('email'),
  );
  late final _password = FormControlTextEditingController<String>(
    form.formControl<String>('password'),
  );

  // Computeds: created once, recomputed only when what they read changes.
  late final _emailError = _email.control.signals.errorText(
    validationMessages: {
      ValidationMessage.required: (_) => 'The email must not be empty',
      ValidationMessage.email: (_) => 'The email value must be a valid email',
    },
  );
  late final _passwordError = _password.control.signals.errorText(
    validationMessages: {
      ValidationMessage.required: (_) => 'The password must not be empty',
      ValidationMessage.minLength: (error) =>
          'At least ${(error as Map)['requiredLength']} characters',
    },
  );
  late final _summary = computed(() {
    final email = _email.control.signals.value.value ?? '';
    final length = _password.control.signals.value.value?.length ?? 0;
    return email.isEmpty ? 'Nothing typed yet' : '$email · $length characters';
  });

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    form.dispose();
    super.dispose();
  }

  void _login() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged in as ${_email.control.value}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signals')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Rebuilds when the email's error text changes, and only then.
          SignalBuilder(
            builder: (context) => TextField(
              controller: _email,
              focusNode: _email.focusNode,
              decoration: InputDecoration(
                labelText: 'Email',
                border: const OutlineInputBorder(),
                errorText: _emailError.value,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 16),
          SignalBuilder(
            builder: (context) => TextField(
              controller: _password,
              focusNode: _password.focusNode,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                errorText: _passwordError.value,
              ),
              obscureText: true,
            ),
          ),
          const SizedBox(height: 16),
          SignalBuilder(builder: (context) => Text(_summary.value)),
          const SizedBox(height: 24),
          // The whole form's validity as a signal.
          SignalBuilder(
            builder: (context) => ElevatedButton(
              onPressed: form.signals.valid.value ? _login : null,
              child: const Text('Login (enabled when valid)'),
            ),
          ),
        ],
      ),
    );
  }
}
