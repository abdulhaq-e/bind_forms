import 'package:bind_forms/bind_forms.dart';
import 'package:material_ui/material_ui.dart';

/// A sign-up form built with the builder helpers.
///
/// Compare with the login page: there, every field needs an adapter field,
/// a `ListenableBuilder` and a line in `dispose`. Here
/// [TextControlBuilder] and [ValueControlBuilder] own the adapters, so the
/// form is the only state left. The input widgets are still the real ones,
/// built by the app with all of their own parameters.
///
/// The age is bound to a slider and a text field at once: two adapters,
/// each with its own focus node, on one control.
class BuildersPage extends StatefulWidget {
  const BuildersPage({super.key});

  @override
  State<BuildersPage> createState() => _BuildersPageState();
}

class _BuildersPageState extends State<BuildersPage> {
  final form = FormGroup({
    'name': FormControl<String>(validators: [Validators.required]),
    'age': FormControl<int>(
      value: 30,
      validators: [Validators.required, Validators.min(18), Validators.max(99)],
    ),
    'acceptTerms': FormControl<bool>(
      value: false,
      validators: [Validators.requiredTrue],
    ),
  });

  @override
  void dispose() {
    form.dispose();
    super.dispose();
  }

  void _signUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Signed up ${form.formControl<String>('name').value}, '
          'age ${form.formControl<int>('age').value}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final age = form.formControl<int>('age');

    return Scaffold(
      appBar: AppBar(title: const Text('Builders')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextControlBuilder(
            control: form.formControl<String>('name'),
            builder: (context, field) => TextField(
              controller: field,
              focusNode: field.focusNode,
              decoration: InputDecoration(
                labelText: 'Name',
                border: const OutlineInputBorder(),
                errorText: field.errorText(context),
              ),
              textInputAction: TextInputAction.next,
            ),
          ),
          const SizedBox(height: 24),
          Text('Age', style: Theme.of(context).textTheme.titleSmall),
          ValueControlBuilder(
            control: age,
            builder: (context, field) => Slider(
              value: (field.value ?? 18).clamp(0, 120).toDouble(),
              max: 120,
              divisions: 120,
              label: '${field.value}',
              focusNode: field.focusNode,
              onChanged: field.enabled
                  ? (value) => field.onChanged(value.round())
                  : null,
            ),
          ),
          TextControlBuilder(
            control: age,
            validationMessages: {
              ValidationMessage.min: (_) => 'You must be at least 18',
              ValidationMessage.max: (_) => 'Please enter a real age',
            },
            builder: (context, field) => TextField(
              controller: field,
              focusNode: field.focusNode,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Age',
                helperText: 'The slider and this field share one control',
                border: const OutlineInputBorder(),
                errorText: field.errorText(context),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ValueControlBuilder(
            control: form.formControl<bool>('acceptTerms'),
            showErrors: (control) =>
                control.invalid && (control.dirty || control.touched),
            builder: (context, field) => CheckboxListTile(
              value: field.value ?? false,
              onChanged: field.enabled ? field.onChanged : null,
              isError: field.errorText(context) != null,
              title: const Text('I accept the terms and conditions'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 24),
          ControlBuilder(
            control: form,
            builder: (context, form) => FilledButton(
              onPressed: form.valid ? _signUp : null,
              child: const Text('Sign up'),
            ),
          ),
        ],
      ),
    );
  }
}
