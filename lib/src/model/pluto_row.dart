part of '../../pluto_grid.dart';

class PlutoRow {
  /// List of row
  Map<String, PlutoCell> cells;

  /// Value to maintain the default sort order when sorting columns.
  /// If there is no value, it is automatically set when loading the grid.
  int sortIdx;

  PlutoRow({
    @required this.cells,
    this.sortIdx,
    bool checked = false,
  })  : _checked = checked,
        _key = UniqueKey();

  /// The state value that the checkbox is checked.
  /// If the enableRowChecked value of the [PlutoColumn] property is set to true,
  /// a check box appears in the cell of the corresponding column.
  /// To manually change the values at runtime,
  /// use the PlutoStateManager.setRowChecked
  /// or PlutoStateManager.toggleAllRowChecked methods.
  bool get checked => _checked;

  bool _checked;

  void _setChecked(bool flag) {
    _checked = flag;
  }

  /// Row key
  Key get key => _key;

  final Key _key;
}
