import 'package:flutter/widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'context_model.dart';

abstract class RowContext extends ContextModel<PlutoBaseRow> {
  bool get resolved =>
      _widget != null && !_widget!.stateManager.hasRemainingFrame;

  @protected
  PlutoBaseRow get widget => _widget!;

  PlutoBaseRow? _widget;

  @override
  void updateContext(PlutoBaseRow widget) {
    _widget = widget;
  }
}
