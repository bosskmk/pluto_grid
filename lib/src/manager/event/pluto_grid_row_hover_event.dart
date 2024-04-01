import 'package:pluto_grid_plus/pluto_grid_plus.dart';

/// [PlutoRow] This event handles the hover status of the widget.
class PlutoGridRowHoverEvent extends PlutoGridEvent {
  final int rowIdx;
  bool isHovered;

  PlutoGridRowHoverEvent({
    required this.rowIdx,
    required this.isHovered,
  });

  @override
  void handler(PlutoGridStateManager stateManager) {
    bool enableRowHoverColor = stateManager.configuration.style.enableRowHoverColor;

    // only change current hovered row index
    // if row hover color effect is enabled
    if (enableRowHoverColor) {
      // set the hovered row index to either the row index or null
      if (isHovered == true) {
        stateManager.setHoveredRowIdx(rowIdx, notify: true);
      } else {
        stateManager.setHoveredRowIdx(null, notify: true);
      }
    }

    // call the onRowEnter callback if it is not null
    if (stateManager.onRowEnter != null && isHovered == true) {
      stateManager.onRowEnter!(
        PlutoGridOnRowEnterEvent(
          row: stateManager.getRowByIdx(rowIdx),
          rowIdx: rowIdx,
        ),
      );
    }

    // call the onRowExit callback if it is not null
    if (stateManager.onRowExit != null && isHovered == false) {
      stateManager.onRowExit!(
        PlutoGridOnRowExitEvent(
          row: stateManager.getRowByIdx(rowIdx),
          rowIdx: rowIdx,
        ),
      );
    }
  }
}
