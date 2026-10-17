// The one file in this app that imports flutter/material.
//
// flutter/material is being replaced by the material_ui package, and its
// types are different types: a flutter/material TextField looks for a
// flutter/material Material ancestor and finds none under a material_ui
// MaterialApp. Packages that haven't migrated yet need the ancestors they
// look for, which this provides.
import 'package:flutter/material.dart' as legacy;
import 'package:material_ui/material_ui.dart';

/// Gives [child] the flutter/material ancestors (theme and material) that
/// not-yet-migrated packages require, matching the current material_ui
/// theme.
class LegacyMaterial extends StatelessWidget {
  const LegacyMaterial({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return legacy.Theme(
      data: legacy.ThemeData(
        colorScheme: legacy.ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: colors.brightness,
        ),
      ),
      child: legacy.Material(
        type: legacy.MaterialType.transparency,
        child: child,
      ),
    );
  }
}

/// flutter/material's localizations, required by its text fields and
/// buttons. Register it with the app's `localizationsDelegates`.
const legacyMaterialLocalizations =
    legacy.DefaultMaterialLocalizations.delegate;
