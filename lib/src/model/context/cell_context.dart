import 'package:flutter/widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'context_model.dart';

abstract class CellContext extends ContextModel<PlutoBaseCell> {
  bool get resolved =>
      _widget != null && !_widget!.stateManager.hasRemainingFrame;

  @protected
  PlutoBaseCell get widget => _widget!;

  PlutoBaseCell? _widget;

  @override
  void updateContext(PlutoBaseCell widget) {
    _widget = widget;
  }
}
