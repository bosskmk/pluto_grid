import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'mixin_popup_cell.dart';

class PlutoSelectCell extends StatefulWidget implements AbstractMixinPopupCell {
  final PlutoGridStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;

  PlutoSelectCell({
    this.stateManager,
    this.cell,
    this.column,
  });

  @override
  _PlutoSelectCellState createState() => _PlutoSelectCellState();
}

class _PlutoSelectCellState extends State<PlutoSelectCell>
    with MixinPopupCell<PlutoSelectCell> {
  List<PlutoColumn> popupColumns;

  List<PlutoRow> popupRows;

  Icon icon = const Icon(
    Icons.arrow_drop_down,
  );

  @override
  void initState() {
    super.initState();

    popupHeight = ((widget.column.type.select.items.length + 1) *
            widget.stateManager.rowTotalHeight) +
        PlutoGridSettings.shadowLineSize +
        PlutoGridSettings.gridInnerSpacing;

    fieldOnSelected = widget.column.title;

    popupColumns = [
      PlutoColumn(
        title: widget.column.title,
        field: widget.column.title,
        type: PlutoColumnType.text(readOnly: true),
        formatter: widget.column.formatter,
        enableFilterMenuItem: false,
        enableHideColumnMenuItem: false,
        enableSetColumnsMenuItem: false,
      )
    ];

    popupRows = widget.column.type.select.items.map((dynamic item) {
      return PlutoRow(
        cells: {
          widget.column.title: PlutoCell(value: item),
        },
      );
    }).toList();
  }

  @override
  void onLoaded(PlutoGridOnLoadedEvent event) {
    event.stateManager.setSelectingMode(PlutoGridSelectingMode.none);

    super.onLoaded(event);
  }
}
