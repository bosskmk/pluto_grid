part of '../../pluto_grid.dart';

class PlutoRow {
  /// 행의 셀 리스트
  Map<String, PlutoCell> cells;

  /// 컬럼 정렬 시 기본 정렬 순서를 유지 하기 위한 값
  int sortIdx;

  PlutoRow({
    @required this.cells,
    this.sortIdx,
  }) : this._key = GlobalKey();

  /// Row key
  GlobalKey _key;
}
