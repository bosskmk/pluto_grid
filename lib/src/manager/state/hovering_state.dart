import 'package:pluto_grid_plus/pluto_grid_plus.dart';

abstract class IHoveringState {

  int? get hoveredRowIdx;

  void setHoveredRowIdx(
    int? rowIdx,
    {bool notify = true}
  );

  bool isRowIdxHovered(int rowIdx);
}

class _State {
  int? _hoverRowIdx;
}

mixin HoveringState implements IPlutoGridState {
  final _State _state = _State();

  @override
  int? get hoveredRowIdx => _state._hoverRowIdx;

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
  bool isRowIdxHovered(int rowIdx) {
    if (hoveredRowIdx == null) {
      return false;
    }
    if (hoveredRowIdx == rowIdx) {
      return true;
    } else {
      return false;
    }
  }
}
