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

  List<PlutoColumn> popupColumns;

  List<PlutoRow> popupRows;

  Icon icon = Icon(
    Icons.date_range,
    color: Colors.black54,
  );

  String fieldOnSelected;

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
    fieldOnSelected = 'date';

    popupColumns = _buildColumns();

    final defaultDate = DateTime.tryParse(widget.cell.value) ?? DateTime.now();

    popupRows = DatetimeHelper.getDaysInBetween(
      widget.column.type.startDate ?? defaultDate.add(Duration(days: -30)),
      widget.column.type.endDate ?? defaultDate.add(Duration(days: 30)),
    ).map((day) {
      return _buildRow(day);
    }).toList();

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
        if (popupStateManager.currentRowIdx == popupStateManager.rows.length) {
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
      PlutoColumn(
        title: 'date',
        field: 'date',
        type: PlutoColumnType.text(readOnly: true),
      ),
      PlutoColumn(
        title: 'weekday',
        field: 'weekday',
        type: PlutoColumnType.text(readOnly: true),
      ),
    ];
  }

  PlutoRow _buildRow(dynamic day) {
    return PlutoRow(
      cells: {
        'date': PlutoCell(value: day),
        'weekday': PlutoCell(
          value: intl.DateFormat('EEEE').format(DateTime.parse(day)),
        ),
      },
    );
  }

  List<PlutoRow> _getMoreRows({bool insertBefore = false}) {
    int firstDays = 1;
    int lastDays = 30;

    String defaultDate =
        popupStateManager.rows.last.cells.entries.first.value.value;

    if (insertBefore) {
      firstDays = -30;
      lastDays = -1;

      defaultDate =
          popupStateManager.rows.first.cells.entries.first.value.value;
    }

    return DatetimeHelper.getDaysInBetween(
      DateTime.parse(defaultDate).add(Duration(days: firstDays)),
      DateTime.parse(defaultDate).add(Duration(days: lastDays)),
    ).map((day) {
      return _buildRow(day);
    }).toList();
  }
}
