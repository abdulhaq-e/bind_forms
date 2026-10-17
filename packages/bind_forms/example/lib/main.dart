import 'package:bind_forms/bind_forms.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // App-wide fallback messages, used by any field that doesn't define its
    // own message for an error key.
    return BindFormsConfig(
      validationMessages: {
        ValidationMessage.required: (_) => 'This field must not be empty',
      },
      child: MaterialApp(
        title: 'bind_forms Login',
        theme: ThemeData(colorSchemeSeed: Colors.blue),
        home: const LoginPage(),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FormGroup form = FormGroup({
    'email': FormControl<String>(
      validators: [Validators.required, Validators.email],
    ),
    'password': FormControl<String>(
      validators: [Validators.required, Validators.minLength(8)],
    ),
    'acceptTerms': FormControl<bool>(
      value: false,
      validators: [Validators.requiredTrue],
    ),
  });

  // Each field is a real widget. These adapters are the only thing binding
  // it to its control, so every widget parameter (keyboardType,
  // obscureText, title, ...) is just that widget's own parameter.
  late final _email = FormControlTextEditingController<String>(
    form.control('email') as FormControl<String>,
    validationMessages: {
      ValidationMessage.email: (_) => 'The email value must be a valid email',
    },
  );
  late final _password = FormControlTextEditingController<String>(
    form.control('password') as FormControl<String>,
    validationMessages: {
      ValidationMessage.minLength: (error) =>
          'The password must be at least '
          '${(error as Map)['requiredLength']} characters long',
    },
  );
  late final _acceptTerms = FormControlValueNotifier<bool>(
    form.control('acceptTerms') as FormControl<bool>,
    // A checkbox is rarely focused and blurred, so show its error as soon
    // as the user has toggled it or tried to submit.
    showErrors: (control) =>
        control.invalid && (control.dirty || control.touched),
  );

  // "Touched" comes from focus loss, so text fields need a focus controller
  // registered with their control for errors to appear on blur.
  final _emailFocus = FocusNodeController();
  final _passwordFocus = FocusNodeController();

  @override
  void initState() {
    super.initState();
    _email.control.registerFocusController(_emailFocus);
    _password.control.registerFocusController(_passwordFocus);
  }

  @override
  void dispose() {
    _email.control.unregisterFocusController(_emailFocus);
    _password.control.unregisterFocusController(_passwordFocus);
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _email.dispose();
    _password.dispose();
    _acceptTerms.dispose();
    form.dispose();
    super.dispose();
  }

  void _login() {
    final messenger = ScaffoldMessenger.of(context);
    if (form.valid) {
      messenger.showSnackBar(
        SnackBar(content: Text('Logged in as ${_email.control.value}')),
      );
    } else {
      // Marking everything touched makes all pending errors visible.
      form.markAllAsTouched();
      messenger.showSnackBar(
        const SnackBar(content: Text('Please correct the errors.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ListenableBuilder(
              listenable: _email,
              builder: (context, _) => TextField(
                controller: _email,
                focusNode: _emailFocus.focusNode,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  errorText: _email.errorText(context),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(height: 16.0),
            ListenableBuilder(
              listenable: _password,
              builder: (context, _) => TextField(
                controller: _password,
                focusNode: _passwordFocus.focusNode,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  errorText: _password.errorText(context),
                ),
                obscureText: true,
                onSubmitted: (_) => _login(),
              ),
            ),
            const SizedBox(height: 8.0),
            ListenableBuilder(
              listenable: _acceptTerms,
              builder: (context, _) => CheckboxListTile(
                value: _acceptTerms.value ?? false,
                onChanged: _acceptTerms.enabled ? _acceptTerms.onChanged : null,
                isError: _acceptTerms.errorText(context) != null,
                title: const Text('I accept the terms and conditions'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            const SizedBox(height: 20),
            // The form's status as a stream: any change to any field
            // recalculates it, and the stream gets one event per change.
            StreamBuilder<ControlStatus>(
              stream: form.statusChanged,
              initialData: form.status,
              builder: (context, snapshot) => ElevatedButton(
                onPressed: snapshot.data == ControlStatus.valid ? _login : null,
                child: const Text('Login (enabled when valid)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
