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
  }) : this._key = UniqueKey();

  /// Row key
  Key get key => _key;

  Key _key;

  bool get checked => _checked;

  bool _checked = false;
}
