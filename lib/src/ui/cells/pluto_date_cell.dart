import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/pluto_grid_date_picker.dart';

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
    Key? key,
  }) : super(key: key);

  @override
  _PlutoDateCellState createState() => _PlutoDateCellState();
}

class _PlutoDateCellState extends State<PlutoDateCell>
    with PopupCellState<PlutoDateCell> {
  PlutoGridStateManager? popupStateManager;

  @override
  List<PlutoColumn> popupColumns = [];

  @override
  List<PlutoRow> popupRows = [];

  @override
  Icon? icon = const Icon(
    Icons.date_range,
  );

  @override
  void openPopup() {
    if (widget.column.checkReadOnly(widget.row, widget.cell)) {
      return;
    }

    isOpenedPopup = true;

    PlutoGridDatePicker(
      context: context,
      stateManager: widget.stateManager,
      initDate: PlutoDateTimeHelper.parseOrNullWithFormat(
        widget.cell.value,
        widget.column.type.date!.format,
      ),
      startDate: widget.column.type.date!.startDate,
      endDate: widget.column.type.date!.endDate,
      dateFormat: widget.column.type.date!.dateFormat,
      headerDateFormat: widget.column.type.date!.headerDateFormat,
      onSelected: onSelected,
    );
  }
}
