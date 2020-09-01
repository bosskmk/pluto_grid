part of '../../../pluto_grid.dart';

class TimeCellWidget extends StatefulWidget implements _PopupBaseMixinImpl {
  final PlutoStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;

  TimeCellWidget({
    this.stateManager,
    this.cell,
    this.column,
  });

  @override
  _TimeCellWidgetState createState() => _TimeCellWidgetState();
}

class _TimeCellWidgetState extends State<TimeCellWidget>
    with _PopupBaseMixin<TimeCellWidget> {
  PlutoStateManager popupStateManager;

  List<PlutoColumn> popupColumns = [];

  List<PlutoRow> popupRows = [];

  Icon icon = Icon(
    Icons.access_time,
    color: Colors.black54,
  );

  String get cellHour => widget.cell.value.toString().substring(0, 2);

  String get cellMinute => widget.cell.value.toString().substring(3, 5);

  void openPopup() {
    if (widget.column.type.readOnly) {
      return;
    }

    _isOpenedPopup = true;

    PlutoDualGridPopup(
      context: context,
      onSelected: (PlutoDualOnSelectedEvent event) {
        _isOpenedPopup = false;

        if (event == null || event.gridA == null || event.gridB == null) {
          return;
        }

        super._handleSelected(
          '${event.gridA.cell.originalValue}:'
          '${event.gridB.cell.originalValue}',
        );
      },
      gridPropsA: PlutoDualGridProps(
        columns: [
          PlutoColumn(
            title: 'hour',
            field: 'hour',
            type: PlutoColumnType.text(readOnly: true),
            enableSorting: false,
            enableDraggable: false,
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
          for (var i = 0; i < event.stateManager.rows.length; i += 1) {
            if (event.stateManager.rows[i].cells['hour'].originalValue ==
                cellHour) {
              event.stateManager
                  .setCurrentCell(event.stateManager.rows[i].cells['hour'], i);

              event.stateManager.moveScrollByRow(
                  MoveDirection.Up, i + 1 + offsetOfScrollRowIdx);
              return;
            }
          }
        },
      ),
      gridPropsB: PlutoDualGridProps(
        columns: [
          PlutoColumn(
            title: 'minute',
            field: 'minute',
            type: PlutoColumnType.text(readOnly: true),
            enableSorting: false,
            enableDraggable: false,
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
          for (var i = 0; i < event.stateManager.rows.length; i += 1) {
            if (event.stateManager.rows[i].cells['minute'].originalValue ==
                cellMinute) {
              event.stateManager.setCurrentCell(
                  event.stateManager.rows[i].cells['minute'], i);

              event.stateManager.moveScrollByRow(
                  MoveDirection.Up, i + 1 + offsetOfScrollRowIdx);
              return;
            }
          }
        },
      ),
      mode: PlutoMode.Select,
      width: 268,
      height: 300,
    );
  }
}
