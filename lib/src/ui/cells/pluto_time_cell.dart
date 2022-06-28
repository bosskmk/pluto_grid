import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'popup_cell.dart';

class PlutoTimeCell extends StatefulWidget implements PopupCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoTimeCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    Key? key,
  }) : super(key: key);

  @override
  PlutoTimeCellState createState() => PlutoTimeCellState();
}

class PlutoTimeCellState extends State<PlutoTimeCell>
    with PopupCellState<PlutoTimeCell> {
  PlutoGridStateManager? popupStateManager;

  @override
  List<PlutoColumn> popupColumns = [];

  @override
  List<PlutoRow> popupRows = [];

  @override
  Icon? icon = const Icon(
    Icons.access_time,
  );

  String get cellValue =>
      widget.cell.value ?? widget.column.type.time!.defaultValue;

  String get cellHour => cellValue.toString().substring(0, 2);

  String get cellMinute => cellValue.toString().substring(3, 5);

  @override
  void openPopup() {
    if (widget.column.readOnly) {
      return;
    }

    isOpenedPopup = true;

    final localeText = widget.stateManager.localeText;

    final configuration = widget.stateManager.configuration!.copyWith(
      gridBorderRadius:
          widget.stateManager.configuration?.gridPopupBorderRadius ??
              BorderRadius.zero,
      defaultColumnTitlePadding: PlutoGridSettings.columnTitlePadding,
      defaultCellPadding: const EdgeInsets.symmetric(horizontal: 3),
      rowHeight: widget.stateManager.configuration!.rowHeight,
      enableRowColorAnimation: false,
      enableColumnBorder: false,
      borderColor: widget.stateManager.configuration!.gridBackgroundColor,
      activatedBorderColor:
          widget.stateManager.configuration!.gridBackgroundColor,
      activatedColor: widget.stateManager.configuration!.gridBackgroundColor,
      gridBorderColor: widget.stateManager.configuration!.gridBackgroundColor,
      inactivatedBorderColor:
          widget.stateManager.configuration!.gridBackgroundColor,
    );

    PlutoDualGridPopup(
      context: context,
      onSelected: (PlutoDualOnSelectedEvent event) {
        isOpenedPopup = false;

        if (event.gridA == null || event.gridB == null) {
          widget.stateManager.setKeepFocus(true);
          textFocus.requestFocus();
          return;
        }

        super.handleSelected(
          '${event.gridA!.cell!.value}:'
          '${event.gridB!.cell!.value}',
        );
      },
      gridPropsA: PlutoDualGridProps(
        columns: [
          PlutoColumn(
            title: localeText.hour,
            field: 'hour',
            readOnly: true,
            type: PlutoColumnType.text(),
            enableSorting: false,
            enableColumnDrag: false,
            enableContextMenu: false,
            enableDropToResize: false,
            textAlign: PlutoColumnTextAlign.center,
            titleTextAlign: PlutoColumnTextAlign.center,
            width: 134,
            renderer: _cellRenderer,
          ),
        ],
        rows: Iterable<int>.generate(24)
            .map((hour) => PlutoRow(cells: {
                  'hour': PlutoCell(
                    value: hour.toString().padLeft(2, '0'),
                  ),
                }))
            .toList(growable: false),
        onLoaded: (PlutoGridOnLoadedEvent event) {
          event.stateManager.setSelectingMode(PlutoGridSelectingMode.none);

          for (var i = 0; i < event.stateManager.refRows.length; i += 1) {
            if (event.stateManager.refRows[i].cells['hour']!.value ==
                cellHour) {
              event.stateManager.setCurrentCell(
                  event.stateManager.refRows[i].cells['hour'], i);

              event.stateManager.moveScrollByRow(
                  PlutoMoveDirection.up, i + 1 + offsetOfScrollRowIdx);
              return;
            }
          }
        },
        configuration: configuration,
      ),
      gridPropsB: PlutoDualGridProps(
        columns: [
          PlutoColumn(
            title: localeText.minute,
            field: 'minute',
            readOnly: true,
            type: PlutoColumnType.text(),
            enableSorting: false,
            enableColumnDrag: false,
            enableContextMenu: false,
            enableDropToResize: false,
            textAlign: PlutoColumnTextAlign.center,
            titleTextAlign: PlutoColumnTextAlign.center,
            width: 134,
            renderer: _cellRenderer,
          ),
        ],
        rows: Iterable<int>.generate(60)
            .map((minute) => PlutoRow(cells: {
                  'minute': PlutoCell(
                    value: minute.toString().padLeft(2, '0'),
                  ),
                }))
            .toList(growable: false),
        onLoaded: (PlutoGridOnLoadedEvent event) {
          event.stateManager.setSelectingMode(PlutoGridSelectingMode.none);

          for (var i = 0; i < event.stateManager.refRows.length; i += 1) {
            if (event.stateManager.refRows[i].cells['minute']!.value ==
                cellMinute) {
              event.stateManager.setCurrentCell(
                  event.stateManager.refRows[i].cells['minute'], i);

              event.stateManager.moveScrollByRow(
                  PlutoMoveDirection.up, i + 1 + offsetOfScrollRowIdx);
              return;
            }
          }
        },
        configuration: configuration,
      ),
      mode: PlutoGridMode.select,
      width: 276,
      height: 300,
      divider: const PlutoDualGridDivider(
        show: false,
      ),
    );
  }

  Widget _cellRenderer(PlutoColumnRendererContext renderContext) {
    final cell = renderContext.cell;

    final isCurrentCell = renderContext.stateManager.isCurrentCell(cell);

    final cellColor = isCurrentCell && renderContext.stateManager.hasFocus
        ? widget.stateManager.configuration!.activatedBorderColor
        : widget.stateManager.configuration!.gridBackgroundColor;

    final textColor = isCurrentCell && renderContext.stateManager.hasFocus
        ? widget.stateManager.configuration!.gridBackgroundColor
        : widget.stateManager.configuration!.cellTextStyle.color;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: cellColor,
        shape: BoxShape.circle,
        border: !isCurrentCell
            ? null
            : !renderContext.stateManager.hasFocus
                ? Border.all(
                    color:
                        widget.stateManager.configuration!.activatedBorderColor,
                    width: 1,
                  )
                : null,
      ),
      child: Center(
        child: Text(
          cell.value,
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
