part of '../../../pluto_grid.dart';

class DateCellWidget extends StatefulWidget implements _PopupBaseMixinImpl {
  final PlutoStateManager stateManager;
  final PlutoCell cell;
  final PlutoColumn column;

  DateCellWidget({
    this.stateManager,
    this.cell,
    this.column,
  });

  @override
  _DateCellWidgetState createState() => _DateCellWidgetState();
}

class _DateCellWidgetState extends State<DateCellWidget>
    with _PopupBaseMixin<DateCellWidget> {
  PlutoStateManager popupStateManager;

  List<PlutoColumn> popupColumns = [];

  List<PlutoRow> popupRows = [];

  Icon icon = Icon(
    Icons.date_range,
  );

  StreamSubscription<KeyManagerEvent> keyManagerStream;

  @override
  void dispose() {
    if (widget.column.type.date.startDate == null ||
        widget.column.type.date.endDate == null) {
      popupStateManager?.scroll?.vertical
          ?.removeOffsetChangedListener(_handleScroll);
    }

    keyManagerStream?.cancel();

    super.dispose();
  }

  @override
  void initState() {
    popupHeight = (8 * PlutoDefaultSettings.rowTotalHeight) +
        PlutoDefaultSettings.shadowLineSize +
        PlutoDefaultSettings.gridInnerSpacing;

    offsetOfScrollRowIdx = 3;

    popupColumns = _buildColumns();

    final defaultDate = DateTime.tryParse(widget.cell.value) ?? DateTime.now();

    final startDate = widget.column.type.date.startDate ??
        DatetimeHelper.moveToFirstWeekday(defaultDate.add(Duration(days: -30)));

    final endDate = widget.column.type.date.endDate ??
        DatetimeHelper.moveToLastWeekday(defaultDate.add(Duration(days: 30)));

    final List<DateTime> days = DatetimeHelper.getDaysInBetween(
      startDate,
      endDate,
    );

    popupRows = _buildRows(days);

    createHeader = (PlutoStateManager stateManager) =>
        _DateCellHeader(stateManager: stateManager);

    super.initState();
  }

  @override
  void _onLoaded(PlutoOnLoadedEvent event) {
    popupStateManager = event.stateManager;

    popupStateManager.setSelectingMode(PlutoSelectingMode.None);

    if (widget.column.type.date.startDate == null ||
        widget.column.type.date.endDate == null) {
      event.stateManager.scroll.vertical
          .addOffsetChangedListener(_handleScroll);
    }

    keyManagerStream = popupStateManager.keyManager.subject.stream
        .listen(_handleGridFocusOnKey);

    super._onLoaded(event);
  }

  void _handleGridFocusOnKey(KeyManagerEvent keyManagerEvent) {
    if (keyManagerEvent.isKeyDownEvent) {
      if (keyManagerEvent.isUp) {
        if (popupStateManager.currentRowIdx == 0) {
          popupStateManager.prependRows(_getMoreRows(insertBefore: true));
          return;
        }
      } else if (keyManagerEvent.isDown) {
        if (popupStateManager.currentRowIdx ==
            popupStateManager.rows.length - 1) {
          popupStateManager.appendRows(_getMoreRows());
          return;
        }
      }
    }
    return;
  }

  void _handleScroll() {
    if (widget.column.type.date.startDate == null &&
        popupStateManager.scroll.vertical.offset == 0) {
      popupStateManager.prependRows(_getMoreRows(insertBefore: true));
    } else if (widget.column.type.date.endDate == null &&
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
          if (days.length < 1) {
            return PlutoCell(value: '');
          }

          if (days.first.weekday.toString() != e) {
            return PlutoCell(value: '');
          }

          final DateTime day = days.removeAt(0);

          return PlutoCell(
              value: day.day,
              originalValue:
                  intl.DateFormat(widget.column.type.date.format).format(day));
        },
      );

      rows.add(PlutoRow(cells: cells));
    }

    return rows;
  }

  List<PlutoRow> _getMoreRows({bool insertBefore = false}) {
    int firstDays;
    int lastDays;

    DateTime defaultDate;

    if (insertBefore) {
      firstDays = -30;
      lastDays = -1;

      defaultDate = DateTime.tryParse(popupStateManager
              .rows.first.cells.entries.first.value.originalValue) ??
          null;

      if (defaultDate == null) {
        return [];
      }

      if (widget.column.type.date.startDate != null &&
          defaultDate.isBefore(widget.column.type.date.startDate)) {
        defaultDate = widget.column.type.date.startDate;
      }
    } else {
      firstDays = 1;
      lastDays = 30;

      defaultDate = DateTime.tryParse(popupStateManager
              .rows.last.cells.entries.last.value.originalValue) ??
          null;

      if (defaultDate == null) {
        return [];
      }

      if (widget.column.type.date.endDate != null &&
          defaultDate.isAfter(widget.column.type.date.endDate)) {
        defaultDate = widget.column.type.date.endDate;
      }
    }

    final startDate = DatetimeHelper.moveToFirstWeekday(
        defaultDate.add(Duration(days: firstDays)));

    final endDate = DatetimeHelper.moveToLastWeekday(
        defaultDate.add(Duration(days: lastDays)));

    final List<DateTime> days = DatetimeHelper.getDaysInBetween(
      startDate,
      endDate,
    );

    return _buildRows(days);
  }
}

class _DateCellHeader extends StatefulWidget {
  final PlutoStateManager stateManager;

  _DateCellHeader({this.stateManager});

  @override
  _DateCellHeaderState createState() => _DateCellHeaderState();
}

class _DateCellHeaderState extends State<_DateCellHeader> {
  PlutoCell currentCell;

  @override
  void dispose() {
    widget.stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    widget.stateManager.addListener(changeStateListener);

    super.initState();
  }

  void changeStateListener() {
    if (identical(currentCell, widget.stateManager.currentCell) == false) {
      setState(() {
        currentCell = widget.stateManager.currentCell;
      });
    }
  }

  String get year {
    if (currentCell == null || currentCell.originalValue.isEmpty) {
      return '';
    }

    return intl.DateFormat('yyyy')
        .format(DateTime.parse(currentCell.originalValue));
  }

  String get month {
    if (currentCell == null || currentCell.originalValue.isEmpty) {
      return '';
    }

    return intl.DateFormat('MM')
        .format(DateTime.parse(currentCell.originalValue));
  }

  Color get textColor =>
      widget.stateManager.configuration.headerTextStyle.color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: PlutoDefaultSettings.rowTotalHeight,
      padding: const EdgeInsets.all(PlutoDefaultSettings.cellPadding),
      alignment: Alignment.center,
      child: Text(
        '$year-$month',
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
