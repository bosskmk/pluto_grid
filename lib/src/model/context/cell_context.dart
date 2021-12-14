import 'package:pluto_grid/pluto_grid.dart';

import 'context_model.dart';

abstract class CellContext implements ContextModel<PlutoBaseCell> {
  PlutoColumn? get column => _column;

  PlutoColumn? _column;

  PlutoRow? get row => _row;

  PlutoRow? _row;

  @override
  void updateContext(PlutoBaseCell widget) {
    _column = widget.column;

    _row = widget.row;
  }
}
