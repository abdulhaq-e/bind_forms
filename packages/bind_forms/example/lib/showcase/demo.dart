import 'package:bind_forms/bind_forms.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent show FluentLocalizations;
import 'package:material_ui/material_ui.dart';

import 'legacy_material.dart';

/// Localizations the showcased widgets need beyond material_ui's own.
const showcaseLocalizationsDelegates = [
  fluent.FluentLocalizations.delegate,
  legacyMaterialLocalizations,
];

/// A card showing one real widget bound to [control], the
/// reactive_forms_widgets package it makes unnecessary, and the control's
/// live value.
///
/// The reset button changes the control from code, so each card also shows
/// the binding working in the model-to-view direction.
class DemoCard extends StatelessWidget {
  const DemoCard({
    super.key,
    required this.title,
    required this.replaces,
    required this.control,
    required this.child,
    this.note,
    this.legacyMaterial = false,
  });

  final String title;

  /// Whether the widget is built on flutter/material rather than
  /// material_ui, and so needs [LegacyMaterial] around it.
  final bool legacyMaterial;

  /// The wrapper package this demo replaces, e.g. `reactive_checkbox`.
  final String replaces;
  final AbstractControl<Object?> control;
  final Widget child;

  /// Anything worth knowing about this binding.
  final String? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleMedium),
                      Text(
                        'replaces $replaces',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Reset from code',
                  icon: const Icon(Icons.restart_alt),
                  onPressed: () => control.reset(),
                ),
              ],
            ),
            if (legacyMaterial) ...[
              const SizedBox(height: 4),
              Text(
                'Built on flutter/material, not yet migrated to material_ui.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
            if (note != null) ...[
              const SizedBox(height: 4),
              Text(note!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: legacyMaterial ? LegacyMaterial(child: child) : child,
            ),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: control.listenable,
              builder: (context, _) => Text(
                'value: ${_describe(control.value)}'
                '${control.invalid ? '  ·  invalid' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _describe(Object? value) {
    final text = switch (value) {
      List<int> bytes when bytes.length > 16 => '${bytes.length} bytes',
      _ => '$value',
    };
    return text.length > 80 ? '${text.substring(0, 80)}…' : text;
  }
}

/// Owns a [FormControlValueNotifier] for widgets with a `value` +
/// `onChanged` pair, so each demo is just the widget itself.
class ValueDemo<T> extends StatefulWidget {
  const ValueDemo({
    super.key,
    required this.title,
    required this.replaces,
    required this.control,
    required this.builder,
    this.note,
    this.legacyMaterial = false,
  });

  final String title;
  final String replaces;
  final String? note;
  final bool legacyMaterial;

  /// Creates the control. Called once.
  final FormControl<T> Function() control;

  /// Builds the real widget. Rebuilt whenever the control changes.
  final Widget Function(BuildContext context, FormControlValueNotifier<T> field)
  builder;

  @override
  State<ValueDemo<T>> createState() => _ValueDemoState<T>();
}

class _ValueDemoState<T> extends State<ValueDemo<T>> {
  late final FormControl<T> _control = widget.control();
  late final FormControlValueNotifier<T> _field = FormControlValueNotifier(
    _control,
    showErrors: (control) =>
        control.invalid && (control.dirty || control.touched),
  );

  @override
  void dispose() {
    _field.dispose();
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: widget.title,
      replaces: widget.replaces,
      note: widget.note,
      legacyMaterial: widget.legacyMaterial,
      control: _control,
      child: ListenableBuilder(
        listenable: _field,
        builder: (context, _) => widget.builder(context, _field),
      ),
    );
  }
}

/// Owns a [FormControlTextEditingController] for widgets that take a
/// [TextEditingController].
class TextDemo<T> extends StatefulWidget {
  const TextDemo({
    super.key,
    required this.title,
    required this.replaces,
    required this.control,
    required this.builder,
    this.note,
    this.legacyMaterial = false,
  });

  final String title;
  final String replaces;
  final String? note;
  final bool legacyMaterial;
  final FormControl<T> Function() control;
  final Widget Function(
    BuildContext context,
    FormControlTextEditingController<T> field,
  )
  builder;

  @override
  State<TextDemo<T>> createState() => _TextDemoState<T>();
}

class _TextDemoState<T> extends State<TextDemo<T>> {
  late final FormControl<T> _control = widget.control();
  late final FormControlTextEditingController<T> _field =
      FormControlTextEditingController(_control);

  @override
  void dispose() {
    _field.dispose();
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: widget.title,
      replaces: widget.replaces,
      note: widget.note,
      legacyMaterial: widget.legacyMaterial,
      control: _control,
      child: ListenableBuilder(
        listenable: _field,
        builder: (context, _) => widget.builder(context, _field),
      ),
    );
  }
}

/// Owns a widget's own [TextEditingController] subclass and a
/// [FormControlTextBinding] that keeps it in sync with the control.
class BindingDemo<T, C extends TextEditingController> extends StatefulWidget {
  const BindingDemo({
    super.key,
    required this.title,
    required this.replaces,
    required this.control,
    required this.textController,
    required this.builder,
    this.note,
    this.legacyMaterial = false,
  });

  final String title;
  final String replaces;
  final String? note;
  final bool legacyMaterial;
  final FormControl<T> Function() control;

  /// Creates the widget's own controller. Called once.
  final C Function() textController;
  final Widget Function(
    BuildContext context,
    C textController,
    FormControlTextBinding<T> field,
  )
  builder;

  @override
  State<BindingDemo<T, C>> createState() => _BindingDemoState<T, C>();
}

class _BindingDemoState<T, C extends TextEditingController>
    extends State<BindingDemo<T, C>> {
  late final FormControl<T> _control = widget.control();
  late final C _textController = widget.textController();
  late final FormControlTextBinding<T> _field = FormControlTextBinding(
    _control,
    _textController,
  );

  @override
  void dispose() {
    _field.dispose();
    _textController.dispose();
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoCard(
      title: widget.title,
      replaces: widget.replaces,
      note: widget.note,
      legacyMaterial: widget.legacyMaterial,
      control: _control,
      child: ListenableBuilder(
        listenable: _field,
        builder: (context, _) =>
            widget.builder(context, _textController, _field),
      ),
    );
  }
}

/// A button that shows [label], opens a picker with [pick], and writes the
/// result to [field]. Replaces the picker wrapper packages, which wrap an
/// async function behind a tap target.
class PickerButton<T> extends StatelessWidget {
  const PickerButton({
    super.key,
    required this.field,
    required this.label,
    required this.pick,
    this.icon = Icons.touch_app_outlined,
  });

  final FormControlValueNotifier<T> field;
  final String label;
  final IconData icon;
  final Future<T?> Function() pick;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: field.enabled
          ? () async {
              final picked = await pick();
              if (picked != null) field.onChanged(picked);
            }
          : null,
    );
  }
}

/// A scrolling page of demos.
class DemoPage extends StatelessWidget {
  const DemoPage({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: children,
      ),
    );
  }
}
