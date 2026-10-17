import 'package:bind_forms/bind_forms.dart';
import 'package:material_ui/material_ui.dart';

import 'login_page.dart';
import 'signals_page.dart';
import 'showcase/demo.dart';
import 'showcase/design_systems.dart';
import 'showcase/flutter_widgets.dart';
import 'showcase/pickers.dart';
import 'showcase/third_party_inputs.dart';

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
        title: 'bind_forms',
        theme: ThemeData(colorSchemeSeed: Colors.blue),
        localizationsDelegates: showcaseLocalizationsDelegates,
        home: const CatalogPage(),
      ),
    );
  }
}

/// The showcase sections.
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  static final sections = <(String, String, IconData, Widget Function())>[
    (
      'Login form',
      'A complete form: validation, errors on blur, submit',
      Icons.login,
      LoginPage.new,
    ),
    (
      'Signals',
      'The login form observed with bind_forms_signals',
      Icons.bolt,
      SignalsPage.new,
    ),
    (
      'Flutter widgets',
      'Material and Cupertino: 15 widgets, 16 wrapper packages',
      Icons.flutter_dash,
      FlutterWidgetsPage.new,
    ),
    (
      'Third-party inputs',
      'Text, selection, toggles, colors, signatures: 24 wrapper packages',
      Icons.extension,
      ThirdPartyInputsPage.new,
    ),
    (
      'Pickers',
      'Files, images, contacts, months, languages: 8 wrapper packages',
      Icons.photo_library_outlined,
      PickersPage.new,
    ),
    (
      'Fluent UI',
      'reactive_fluent_ui: 8 widgets',
      Icons.window,
      FluentPage.new,
    ),
    (
      'macOS UI',
      'reactive_macos_ui: 7 widgets',
      Icons.laptop_mac,
      MacosPage.new,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('bind_forms')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Every widget covered by reactive_forms_widgets, bound to a '
              'FormControl directly: no wrapper widgets, no re-declared '
              'constructors.',
            ),
          ),
          for (final (title, subtitle, icon, page) in sections)
            ListTile(
              leading: Icon(icon),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  Navigator.of(context)
                      .push(MaterialPageRoute<void>(builder: (_) => page())),
            ),
          const Divider(),
          const ListTile(
            title: Text('Not shown'),
            subtitle: Text(
              'reactive_awesome_select and reactive_md_editable_textinput '
              'wrap packages that no longer compile on current Flutter '
              '(they use TextTheme and ThemeData members removed years '
              'ago), so their wrappers are broken too. reactive_getwidget '
              'is empty.',
            ),
          ),
        ],
      ),
    );
  }
}
