import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:pluto_grid/pluto_grid.dart';

class PlutoGridDatePicker {
  final BuildContext context;
  final PlutoGridStateManager stateManager;
  final DateTime? initDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? format;
  final PlutoOnLoadedEventCallback? onLoaded;
  final PlutoOnSelectedEventCallback? onSelected;
  final double? cellWidth;
  final double? cellHeight;

  PlutoGridDatePicker({
    required this.context,
    required this.stateManager,
    this.initDate,
    this.startDate,
    this.endDate,
    this.format = 'yyyy-MM-dd',
    this.onLoaded,
    this.onSelected,
    this.cellWidth,
    this.cellHeight,
  }) : dateFormat = intl.DateFormat(format) {
    open();
  }

  late final intl.DateFormat dateFormat;

  Future<void> open() async {
    const rowsHeight = 6 * PlutoGridSettings.rowTotalHeight;

    const popupHeight = PlutoGridSettings.rowTotalHeight +
        PlutoGridSettings.rowHeight +
        rowsHeight +
        PlutoGridSettings.gridInnerSpacing;

    final popupColumns = _buildColumns();

    final defaultDate = _getDefaultDate();

    final List<DateTime> days = PlutoDateTimeHelper.getDaysInBetween(
      DateTime(defaultDate.year, defaultDate.month, 1),
      DateTime(defaultDate.year, defaultDate.month + 1, 0),
    );

    final popupRows = _buildRows(days);

    PlutoGridPopup(
      context: context,
      mode: PlutoGridMode.select,
      onLoaded: _onLoaded,
      onSelected: onSelected,
      columns: popupColumns,
      rows: popupRows,
      width: popupColumns.fold<double>(0, (previous, column) {
            return previous + column.width;
          }) +
          1,
      height: popupHeight,
      createHeader: _createHeader,
      configuration: stateManager.configuration?.copyWith(
        gridBorderRadius: stateManager.configuration?.gridPopupBorderRadius ??
            BorderRadius.zero,
        defaultColumnTitlePadding: PlutoGridSettings.columnTitlePadding,
        defaultCellPadding: 3,
        rowHeight: stateManager.configuration!.rowHeight,
        enableRowColorAnimation: false,
        enableColumnBorder: false,
        borderColor: stateManager.configuration!.gridBackgroundColor,
        activatedBorderColor: stateManager.configuration!.gridBackgroundColor,
        activatedColor: stateManager.configuration!.gridBackgroundColor,
        gridBorderColor: stateManager.configuration!.gridBackgroundColor,
      ),
    );
  }

  void _onLoaded(PlutoGridOnLoadedEvent event) {
    event.stateManager.setSelectingMode(PlutoGridSelectingMode.none);

    if (initDate != null) {
      final rows = event.stateManager.rows;

      final initDateString = dateFormat.format(initDate!);

      for (var i = 0; i < rows.length; i += 1) {
        for (var entry in rows[i].cells.entries) {
          if (rows[i].cells[entry.key]!.value == initDateString) {
            event.stateManager.setCurrentCell(
                event.stateManager.refRows[i].cells[entry.key], i);
            break;
          }
        }
      }
    }

    if (onLoaded != null) {
      onLoaded!(event);
    }
  }

  DateTime _getDefaultDate() {
    if (initDate != null) {
      return initDate!;
    }

    if (startDate != null) {
      return startDate!;
    }

    if (endDate != null) {
      return endDate!;
    }

    return DateTime.now();
  }

  Widget _createHeader(PlutoGridStateManager? stateManager) {
    return _DateCellHeader(stateManager: stateManager!);
  }

  String _dateFormatter(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return '';
    }

    var dateTime = dateFormat.parse(
      value.toString(),
    );

    return dateTime.day.toString();
  }

  Widget _cellRenderer(PlutoColumnRendererContext renderContext) {
    final cell = renderContext.cell;

    final isCurrentCell = renderContext.stateManager.isCurrentCell(cell);

    final cellColor = isCurrentCell
        ? stateManager.configuration!.activatedBorderColor
        : stateManager.configuration!.gridBackgroundColor;

    final textColor = isCurrentCell
        ? stateManager.configuration!.gridBackgroundColor
        : stateManager.configuration!.cellTextStyle.color;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: cellColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _dateFormatter(cell.value),
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  List<PlutoColumn> _buildColumns() {
    final localeText = stateManager.localeText;

    return [
      [localeText.sunday, '7'],
      [localeText.monday, '1'],
      [localeText.tuesday, '2'],
      [localeText.wednesday, '3'],
      [localeText.thursday, '4'],
      [localeText.friday, '5'],
      [localeText.saturday, '6'],
    ].map((e) {
      return PlutoColumn(
        title: e[0],
        field: e[1],
        readOnly: true,
        type: PlutoColumnType.text(),
        width: 45,
        enableColumnDrag: false,
        enableSorting: false,
        enableContextMenu: false,
        textAlign: PlutoColumnTextAlign.center,
        titleTextAlign: PlutoColumnTextAlign.center,
        renderer: _cellRenderer,
      );
    }).toList(growable: false);
  }

  List<PlutoRow> _buildRows(List<DateTime> days) {
    List<PlutoRow> rows = [];

    while (days.isNotEmpty) {
      final Map<String, PlutoCell> cells = Map.fromIterable(
        <String>['7', '1', '2', '3', '4', '5', '6'],
        key: (dynamic e) => e.toString(),
        value: (dynamic e) {
          if (days.isEmpty) {
            return PlutoCell(value: '');
          }

          if (days.first.weekday.toString() != e) {
            return PlutoCell(value: '');
          }

          final DateTime day = days.removeAt(0);

          return PlutoCell(
            value: dateFormat.format(day),
          );
        },
      );

      rows.add(PlutoRow(cells: cells));
    }

    return rows;
  }
}

class _DateCellHeader extends PlutoStatefulWidget {
  @override
  final PlutoGridStateManager stateManager;

  const _DateCellHeader({required this.stateManager});

  @override
  _DateCellHeaderState createState() => _DateCellHeaderState();
}

abstract class _DateCellHeaderStateWithChange
    extends PlutoStateWithChange<_DateCellHeader> {
  PlutoCell? currentCell;

  @override
  void onChange() {
    resetState((update) {
      currentCell = update<PlutoCell?>(
        currentCell,
        widget.stateManager.currentCell,
        compare: identical,
      );
    });
  }
}

class _DateCellHeaderState extends _DateCellHeaderStateWithChange {
  String get currentDate {
    if (currentCell == null || currentCell!.value.toString().isEmpty) {
      return '';
    }

    return currentCell!.value.toString();
  }

  Color? get textColor =>
      widget.stateManager.configuration!.columnTextStyle.color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.stateManager.rowTotalHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: PlutoGridSettings.cellPadding,
      ),
      alignment: Alignment.center,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          currentDate,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
