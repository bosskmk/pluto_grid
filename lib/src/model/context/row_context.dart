import 'package:pluto_grid/pluto_grid.dart';

import 'context_model.dart';

abstract class RowContext implements ContextModel<PlutoBaseRow> {
  int? get index => _index;

  int? _index;

  @override
  void updateContext(PlutoBaseRow widget) {
    _index = widget.rowIdx;
  }
}
