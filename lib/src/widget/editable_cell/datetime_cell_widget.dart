part of '../../../pluto_grid.dart';

class DatetimeCellWidget extends StatefulWidget implements _PopupBaseMixinImpl {
  final PlutoStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;

  DatetimeCellWidget({
    this.stateManager,
    this.cell,
    this.column,
  });

  @override
  _DatetimeCellWidgetState createState() => _DatetimeCellWidgetState();
}

class _DatetimeCellWidgetState extends State<DatetimeCellWidget>
    with _PopupBaseMixin<DatetimeCellWidget> {
  PlutoStateManager popupStateManager;

  List<PlutoColumn> popupColumns = [];

  List<PlutoRow> popupRows = [];

  Icon icon = Icon(
    Icons.date_range,
    color: Colors.black54,
  );

  StreamSubscription<KeyManagerEvent> keyManagerStream;

  @override
  void dispose() {
    if (widget.column.type.startDate == null ||
        widget.column.type.endDate == null) {
      popupStateManager?.scroll?.vertical
          ?.removeOffsetChangedListener(_handleScroll);
    }

    keyManagerStream?.cancel();

    super.dispose();
  }

  @override
  void initState() {
    popupHeight = 6 *
            (PlutoDefaultSettings.rowHeight +
                PlutoDefaultSettings.rowBorderWidth) +
        PlutoDefaultSettings.shadowLineSize +
        PlutoDefaultSettings.gridInnerSpacing;

    offsetOfScrollRowIdx = 2;

    popupColumns = _buildColumns();

    final defaultDate = DateTime.tryParse(widget.cell.value) ?? DateTime.now();

    final startDate = widget.column.type.startDate ??
        DatetimeHelper.moveToFirstWeekday(defaultDate.add(Duration(days: -30)));
    final endDate = widget.column.type.endDate ??
        DatetimeHelper.moveToLastWeekday(defaultDate.add(Duration(days: 30)));

    final List<DateTime> days = DatetimeHelper.getDaysInBetween(
      startDate,
      endDate,
    );

    popupRows = _buildRows(days);

    super.initState();
  }

  @override
  void _onLoaded(PlutoOnLoadedEvent event) {
    popupStateManager = event.stateManager;

    if (widget.column.type.startDate == null ||
        widget.column.type.endDate == null) {
      event.stateManager.scroll.vertical
          .addOffsetChangedListener(_handleScroll);
    }

    keyManagerStream = popupStateManager.keyManager.subject.stream
        .listen(_handleGridFocusOnKey);

    super._onLoaded(event);
  }

  bool _handleGridFocusOnKey(KeyManagerEvent keyManagerEvent) {
    if (keyManagerEvent.event.runtimeType == RawKeyDownEvent) {
      if (keyManagerEvent.isUp) {
        if (popupStateManager.currentRowIdx == 0) {
          popupStateManager.prependRows(_getMoreRows(insertBefore: true));
          return false;
        }
      } else if (keyManagerEvent.isDown) {
        if (popupStateManager.currentRowIdx ==
            popupStateManager.rows.length - 1) {
          popupStateManager.appendRows(_getMoreRows());
          return false;
        }
      }
    }
    return false;
  }

  void _handleScroll() {
    if (widget.column.type.startDate == null &&
        popupStateManager.scroll.vertical.offset == 0) {
      popupStateManager.prependRows(_getMoreRows(insertBefore: true));
    } else if (widget.column.type.endDate == null &&
        popupStateManager.scroll.bodyRowsVertical.position.maxScrollExtent ==
            popupStateManager.scroll.vertical.offset) {
      popupStateManager.appendRows(_getMoreRows());
    }
  }

  List<PlutoColumn> _buildColumns() {
    return [
      ['Su', '7'],
      ['Mo', '1'],
      ['Tu', '2'],
      ['We', '3'],
      ['Th', '4'],
      ['Fr', '5'],
      ['Sa', '6'],
    ].map((e) {
      return PlutoColumn(
        title: e[0],
        field: e[1],
        type: PlutoColumnType.text(readOnly: true),
        width: 45,
        enableDraggable: false,
        enableSorting: false,
        enableContextMenu: false,
      );
    }).toList(growable: false);
  }

  List<PlutoRow> _buildRows(List<DateTime> days) {
    List<PlutoRow> rows = [];

    while (days.length > 0) {
      final Map<String, PlutoCell> cells = Map.fromIterable(
        ['7', '1', '2', '3', '4', '5', '6'],
        key: (e) => e,
        value: (e) {
          final DateTime day = days.removeAt(0);
          return PlutoCell(
              value: day.day,
              originalValue:
                  intl.DateFormat(widget.column.type.format).format(day));
        },
      );

      rows.add(PlutoRow(cells: cells));
    }

    return rows;
  }

  List<PlutoRow> _getMoreRows({bool insertBefore = false}) {
    int firstDays = 1;
    int lastDays = 30;

    DateTime defaultDate = DateTime.parse(
        popupStateManager.rows.last.cells.entries.last.value.originalValue);

    if (insertBefore) {
      firstDays = -30;
      lastDays = -1;

      defaultDate = DateTime.parse(
          popupStateManager.rows.first.cells.entries.first.value.originalValue);
    }

    final startDate = widget.column.type.startDate ??
        DatetimeHelper.moveToFirstWeekday(
            defaultDate.add(Duration(days: firstDays)));

    final endDate = widget.column.type.endDate ??
        DatetimeHelper.moveToLastWeekday(
            defaultDate.add(Duration(days: lastDays)));

    final List<DateTime> days = DatetimeHelper.getDaysInBetween(
      startDate,
      endDate,
    );

    return _buildRows(days);
  }
}
