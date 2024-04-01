import 'package:pluto_grid_plus/pluto_grid_plus.dart';

abstract class IHoveringState {

  bool get isHoveringRow;

  int? get hoveredRowIdx;

  void setIsHoveringRow(
    bool flag,
    {bool notify = true}
  );

  void setHoveredRowIdx(
    int rowIdx,
    {bool notify = true}
  );

  bool isRowIdxHovered(int rowIdx);
}

class _State {
  bool _isHoveringRow = false;

  int? _hoverRowIdx;
}

mixin HoveringState implements IPlutoGridState {
  final _State _state = _State();

  @override
  bool get isHoveringRow => _state._isHoveringRow;

  @override
  int? get hoveredRowIdx => _state._hoverRowIdx;

  @override
  void setIsHoveringRow(
    bool flag,
    {bool notify = true,}
  ) {
    if (isHoveringRow == flag) {
      return;
    }

    _state._isHoveringRow = flag;

    notifyListeners(notify, setIsHoveringRow.hashCode);
  }

  @override
  void setHoveredRowIdx(
    int? rowIdx,
    {bool notify = true,}
  ) {
    if (hoveredRowIdx == rowIdx) {
      return;
    }

    _state._hoverRowIdx = rowIdx;

    notifyListeners(notify, setHoveredRowIdx.hashCode);
  }

  @override
  bool isRowIdxHovered(int? rowIdx) {
    return rowIdx != null && hoveredRowIdx != null;
  }
}
