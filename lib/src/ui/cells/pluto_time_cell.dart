import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'popup_cell.dart';

class PlutoTimeCell extends StatefulWidget implements PopupCell {
  @override
  final PlutoGridStateManager? stateManager;

  @override
  final PlutoCell? cell;

  @override
  final PlutoColumn? column;

  @override
  final PlutoRow? row;

  const PlutoTimeCell({
    this.stateManager,
    this.cell,
    this.column,
    this.row,
    Key? key,
  }) : super(key: key);

  @override
  _PlutoTimeCellState createState() => _PlutoTimeCellState();
}

class _PlutoTimeCellState extends State<PlutoTimeCell>
    with PopupCellState<PlutoTimeCell> {
  PlutoGridStateManager? popupStateManager;

  @override
  List<PlutoColumn>? popupColumns = [];

  @override
  List<PlutoRow>? popupRows = [];

  @override
  Icon? icon = const Icon(
    Icons.access_time,
  );

  String get cellHour => widget.cell!.value.toString().substring(0, 2);

  String get cellMinute => widget.cell!.value.toString().substring(3, 5);

  @override
  void openPopup() {
    if (widget.column!.readOnly) {
      return;
    }

    isOpenedPopup = true;

    final localeText = widget.stateManager!.localeText;

    final configuration = widget.stateManager!.configuration!.copyWith(
      enableRowColorAnimation: false,
      enableColumnBorder: false,
    );

    PlutoDualGridPopup(
      context: context,
      onSelected: (PlutoDualOnSelectedEvent event) {
        isOpenedPopup = false;

        if (event.gridA == null || event.gridB == null) {
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
            textAlign: PlutoColumnTextAlign.center,
            titleTextAlign: PlutoColumnTextAlign.center,
            width: 134,
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
          event.stateManager!.setSelectingMode(PlutoGridSelectingMode.none);

          for (var i = 0; i < event.stateManager!.refRows!.length; i += 1) {
            if (event.stateManager!.refRows![i]!.cells['hour']!.value ==
                cellHour) {
              event.stateManager!.setCurrentCell(
                  event.stateManager!.refRows![i]!.cells['hour'], i);

              event.stateManager!.moveScrollByRow(
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
            textAlign: PlutoColumnTextAlign.center,
            titleTextAlign: PlutoColumnTextAlign.center,
            width: 134,
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
          event.stateManager!.setSelectingMode(PlutoGridSelectingMode.none);

          for (var i = 0; i < event.stateManager!.refRows!.length; i += 1) {
            if (event.stateManager!.refRows![i]!.cells['minute']!.value ==
                cellMinute) {
              event.stateManager!.setCurrentCell(
                  event.stateManager!.refRows![i]!.cells['minute'], i);

              event.stateManager!.moveScrollByRow(
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
    );
  }
}
