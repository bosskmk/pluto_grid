import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

import 'popup_cell.dart';

class PlutoDateCell extends StatefulWidget implements PopupCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoDateCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  PlutoDateCellState createState() => PlutoDateCellState();
}

class PlutoDateCellState extends State<PlutoDateCell>
    with PopupCellState<PlutoDateCell> {
  PlutoGridStateManager? popupStateManager;

  @override
  List<PlutoColumn> popupColumns = [];

  @override
  List<PlutoRow> popupRows = [];

  @override
  IconData? get icon => widget.column.type.date.popupIcon;

  @override
  void openPopup() async {
    if (widget.column.checkReadOnly(widget.row, widget.cell)) {
      return;
    }
    isOpenedPopup = true;
    if (widget.stateManager.selectDateCallback != null) {
      final sm = widget.stateManager;
      final date = await sm.selectDateCallback!(widget.cell, widget.column);
      isOpenedPopup = false;
      if (date != null) {
        handleSelected(widget.column.type.date.dateFormat.format(date)); // Consider call onSelected
      }
    } else {
      PlutoGridDatePicker(
        context: context,
        initDate: PlutoDateTimeHelper.parseOrNullWithFormat(
          widget.cell.value,
          widget.column.type.date.format,
        ),
        startDate: widget.column.type.date.startDate,
        endDate: widget.column.type.date.endDate,
        dateFormat: widget.column.type.date.dateFormat,
        headerDateFormat: widget.column.type.date.headerDateFormat,
        onSelected: onSelected,
        itemHeight: widget.stateManager.rowTotalHeight,
        configuration: widget.stateManager.configuration,
      );
    }
  }
}
