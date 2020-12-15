import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'mixin_popup_cell.dart';

class PlutoTimeCell extends StatefulWidget implements AbstractMixinPopupCell {
  final PlutoStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;

  PlutoTimeCell({
    this.stateManager,
    this.cell,
    this.column,
  });

  @override
  _PlutoTimeCellState createState() => _PlutoTimeCellState();
}

class _PlutoTimeCellState extends State<PlutoTimeCell>
    with MixinPopupCell<PlutoTimeCell> {
  PlutoStateManager popupStateManager;

  List<PlutoColumn> popupColumns = [];

  List<PlutoRow> popupRows = [];

  Icon icon = const Icon(
    Icons.access_time,
  );

  String get cellHour => widget.cell.value.toString().substring(0, 2);

  String get cellMinute => widget.cell.value.toString().substring(3, 5);

  void openPopup() {
    if (widget.column.type.readOnly) {
      return;
    }

    isOpenedPopup = true;

    final localeText = widget.stateManager.localeText;

    final configuration = widget.stateManager.configuration.copyWith(
      rowHeight: PlutoGridSettings.rowHeight,
    );

    PlutoDualGridPopup(
      context: context,
      onSelected: (PlutoDualOnSelectedEvent event) {
        isOpenedPopup = false;

        if (event == null || event.gridA == null || event.gridB == null) {
          return;
        }

        super.handleSelected(
          '${event.gridA.cell.value}:'
          '${event.gridB.cell.value}',
        );
      },
      gridPropsA: PlutoDualGridProps(
        columns: [
          PlutoColumn(
            title: localeText.hour,
            field: 'hour',
            type: PlutoColumnType.text(readOnly: true),
            enableSorting: false,
            enableColumnDrag: false,
            enableContextMenu: false,
            width: 134,
          ),
        ],
        rows: Iterable.generate(24)
            .map((hour) => PlutoRow(cells: {
                  'hour': PlutoCell(
                    value: hour.toString().padLeft(2, '0'),
                  ),
                }))
            .toList(growable: false),
        onLoaded: (PlutoOnLoadedEvent event) {
          event.stateManager.setSelectingMode(PlutoSelectingMode.none);

          for (var i = 0; i < event.stateManager.refRows.length; i += 1) {
            if (event.stateManager.refRows[i].cells['hour'].value == cellHour) {
              event.stateManager.setCurrentCell(
                  event.stateManager.refRows[i].cells['hour'], i);

              event.stateManager.moveScrollByRow(
                  MoveDirection.up, i + 1 + offsetOfScrollRowIdx);
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
            type: PlutoColumnType.text(readOnly: true),
            enableSorting: false,
            enableColumnDrag: false,
            enableContextMenu: false,
            width: 134,
          ),
        ],
        rows: Iterable.generate(60)
            .map((minute) => PlutoRow(cells: {
                  'minute': PlutoCell(
                    value: minute.toString().padLeft(2, '0'),
                  ),
                }))
            .toList(growable: false),
        onLoaded: (PlutoOnLoadedEvent event) {
          event.stateManager.setSelectingMode(PlutoSelectingMode.none);

          for (var i = 0; i < event.stateManager.refRows.length; i += 1) {
            if (event.stateManager.refRows[i].cells['minute'].value ==
                cellMinute) {
              event.stateManager.setCurrentCell(
                  event.stateManager.refRows[i].cells['minute'], i);

              event.stateManager.moveScrollByRow(
                  MoveDirection.up, i + 1 + offsetOfScrollRowIdx);
              return;
            }
          }
        },
        configuration: configuration,
      ),
      mode: PlutoGridMode.select,
      width: 276,
      height: 300,
    );
  }
}
