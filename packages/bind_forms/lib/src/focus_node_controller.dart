// Copyright 2020 Joan Pablo Jimenez Milian. All rights reserved.
// Use of this source code is governed by the MIT license that can be
// found in the LICENSE file.

import 'package:bind_forms_core/bind_forms_core.dart';
import 'package:flutter/widgets.dart';

/// Connects a Flutter [FocusNode] to a [FormControl].
///
/// Register it with [FormControl.registerFocusController] and hand
/// [focusNode] to the widget. Losing focus in the UI marks the control as
/// touched, and `control.focus()` / `control.unfocus()` move UI focus.
class FocusNodeController extends ChangeNotifier implements FocusController {
  bool _hasFocus = false;
  bool _disposed = false;
  final FocusNode _focusNode;
  final bool _shouldDisposeFocusNode;
  bool _modelToViewChanges = false;

  /// Creates a focus controller.
  ///
  /// If no [focusNode] is provided, one is created and disposed with this
  /// controller. A provided [focusNode] is not disposed here and must be
  /// disposed by its owner.
  FocusNodeController({FocusNode? focusNode})
    : _focusNode = focusNode ?? FocusNode(),
      _shouldDisposeFocusNode = focusNode == null {
    _focusNode.addListener(_onFocusNodeFocusChanges);
  }

  @override
  bool get hasFocus => _hasFocus;

  /// The focus node to pass to the widget.
  FocusNode get focusNode => _focusNode;

  /// Updates the focus state, notifying listeners unless [emitEvent] is false.
  void updateFocus(bool hasFocus, {bool emitEvent = true}) {
    if (_hasFocus != hasFocus) {
      _hasFocus = hasFocus;
      if (emitEvent && !_disposed) {
        notifyListeners();
      }
    }
  }

  @override
  void onControlFocusChanged(bool hasFocus) {
    _modelToViewChanges = true;

    if (hasFocus && !focusNode.hasFocus) {
      focusNode.requestFocus();
    } else if (!hasFocus && focusNode.hasFocus) {
      focusNode.unfocus();
    }

    updateFocus(hasFocus);
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusNodeFocusChanges);
    if (_shouldDisposeFocusNode) {
      focusNode.dispose();
    }
    _disposed = true;
    super.dispose();
  }

  void _onFocusNodeFocusChanges() {
    if (_modelToViewChanges) {
      _modelToViewChanges = false;
      return;
    }

    if (hasFocus && !focusNode.hasFocus) {
      updateFocus(false);
    } else if (!hasFocus && focusNode.hasFocus) {
      updateFocus(true);
    }
  }
}
