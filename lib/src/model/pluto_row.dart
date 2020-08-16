part of pluto_grid;

class PlutoRow {
  /// 행의 셀 리스트
  Map<String, PlutoCell> cells;

  PlutoRow({
    @required this.cells,
  }) : this._key = GlobalKey();

  /// Row key
  GlobalKey _key;
}
