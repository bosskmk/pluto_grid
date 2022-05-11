import 'dart:collection';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IColumnState {
  /// Columns provided at grid start.
  List<PlutoColumn> get columns;

  FilteredList<PlutoColumn> refColumns = FilteredList();

  /// Column index list.
  List<int> get columnIndexes;

  /// List of column indexes in which the sequence is maintained
  /// while the frozen column is visible.
  List<int> get columnIndexesForShowFrozen;

  /// Width of the entire column.
  double get columnsWidth;

  /// Left frozen columns.
  List<PlutoColumn> get leftFrozenColumns;

  /// Left frozen column Index List.
  List<int> get leftFrozenColumnIndexes;

  /// Width of the left frozen column.
  double get leftFrozenColumnsWidth;

  /// Right frozen columns.
  List<PlutoColumn> get rightFrozenColumns;

  /// Right frozen column Index List.
  List<int> get rightFrozenColumnIndexes;

  /// Width of the right frozen column.
  double get rightFrozenColumnsWidth;

  /// Body columns.
  List<PlutoColumn> get bodyColumns;

  /// Body column Index List.
  List<int> get bodyColumnIndexes;

  /// Width of the body column.
  double get bodyColumnsWidth;

  /// Column of currently selected cell.
  PlutoColumn? get currentColumn;

  /// Column field name of currently selected cell.
  String? get currentColumnField;

  bool get hasSortedColumn;

  PlutoColumn? get getSortedColumn;

  /// Column Index List by frozen Column
  List<int> get columnIndexesByShowFrozen;

  /// Toggle whether the column is frozen or not.
  void toggleFrozenColumn(Key columnKey, PlutoColumnFrozen frozen);

  /// Toggle column sorting.
  void toggleSortColumn(PlutoColumn column);

  /// Column width to index location based on full column.
  double columnsWidthAtColumnIdx(int columnIdx);

  /// Column width to index location based on Body column
  double bodyColumnsWidthAtColumnIdx(int columnIdx);

  /// Index of [column] in [columns]
  ///
  /// Depending on the state of the frozen column, the column order index
  /// must be referenced with the columnIndexesByShowFrozen function.
  int? columnIndex(PlutoColumn column);

  void insertColumns(int columnIdx, List<PlutoColumn> columns);

  void removeColumns(List<PlutoColumn> columns);

  /// Change column position.
  void moveColumn({
    required PlutoColumn column,
    required PlutoColumn targetColumn,
  });

  /// Change column size
  void resizeColumn(
    PlutoColumn column,
    double offset, {
    bool notify = true,
    bool checkScroll = true,
  });

  void autoFitColumn(BuildContext context, PlutoColumn column);

  void hideColumn(
    Key columnKey,
    bool flag, {
    bool notify = true,
    bool checkScroll = true,
  });

  void sortAscending(PlutoColumn column, {bool notify = true});

  void sortDescending(PlutoColumn column, {bool notify = true});

  void sortBySortIdx(PlutoColumn column, {bool notify = true});

  void showSetColumnsPopup(BuildContext context);
}

mixin ColumnState implements IPlutoGridState {
  @override
  List<PlutoColumn> get columns => [...refColumns];

  @override
  FilteredList<PlutoColumn> get refColumns => _refColumns;

  @override
  set refColumns(FilteredList<PlutoColumn> setColumns) {
    _refColumns = setColumns;
    _refColumns.setFilter((element) => element.hide == false);
  }

  FilteredList<PlutoColumn> _refColumns = FilteredList();

  @override
  List<int> get columnIndexes => refColumns.asMap().keys.toList();

  @override
  List<int> get columnIndexesForShowFrozen {
    return [
      ...leftFrozenColumnIndexes,
      ...bodyColumnIndexes,
      ...rightFrozenColumnIndexes
    ];
  }

  @override
  double get columnsWidth {
    return refColumns.fold(0, (double value, element) => value + element.width);
  }

  @override
  List<PlutoColumn> get leftFrozenColumns {
    return refColumns.where((e) => e.frozen.isLeft).toList();
  }

  @override
  List<int> get leftFrozenColumnIndexes {
    return refColumns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.frozen.isLeft) {
        return [...previousValue, refColumns.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  @override
  double get leftFrozenColumnsWidth {
    return leftFrozenColumns.fold(
        0, (double value, element) => value + element.width);
  }

  @override
  List<PlutoColumn> get rightFrozenColumns {
    return refColumns.where((e) => e.frozen.isRight).toList();
  }

  @override
  List<int> get rightFrozenColumnIndexes {
    return refColumns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.frozen.isRight) {
        return [...previousValue, refColumns.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  @override
  double get rightFrozenColumnsWidth {
    return rightFrozenColumns.fold(
        0, (double value, element) => value + element.width);
  }

  @override
  List<PlutoColumn> get bodyColumns {
    return refColumns.where((e) => e.frozen.isNone).toList();
  }

  @override
  List<int> get bodyColumnIndexes {
    return bodyColumns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.frozen.isNone) {
        return [...previousValue, refColumns.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  @override
  double get bodyColumnsWidth {
    return bodyColumns.fold(
        0, (double value, element) => value + element.width);
  }

  @override
  PlutoColumn? get currentColumn {
    if (currentColumnField == null) {
      return null;
    }

    return refColumns
        .firstWhereOrNull((element) => element.field == currentColumnField);
  }

  @override
  String? get currentColumnField {
    if (currentRow == null) {
      return null;
    }

    return currentRow!.cells.keys.firstWhereOrNull(
        (key) => currentRow!.cells[key]!.key == currentCell?.key);
  }

  @override
  bool get hasSortedColumn =>
      refColumns.firstWhereOrNull(
        (element) => !element.sort.isNone,
      ) !=
      null;

  @override
  PlutoColumn? get getSortedColumn => refColumns.firstWhereOrNull(
        (element) => !element.sort.isNone,
      );

  @override
  List<int> get columnIndexesByShowFrozen {
    return showFrozenColumn ? columnIndexesForShowFrozen : columnIndexes;
  }

  @override
  void toggleFrozenColumn(Key columnKey, PlutoColumnFrozen frozen) {
    for (var i = 0; i < refColumns.length; i += 1) {
      if (refColumns[i].key == columnKey) {
        refColumns[i].frozen =
            refColumns[i].frozen.isFrozen ? PlutoColumnFrozen.none : frozen;
        break;
      }
    }

    updateCurrentCellPosition(notify: false);

    notifyListeners();
  }

  @override
  void toggleSortColumn(PlutoColumn column) {
    if (column.sort.isNone) {
      sortAscending(column, notify: false);
    } else if (column.sort.isAscending) {
      sortDescending(column, notify: false);
    } else {
      sortBySortIdx(column, notify: false);
    }

    updateCurrentCellPosition(notify: false);

    notifyListeners();
  }

  @override
  double columnsWidthAtColumnIdx(int columnIdx) {
    double width = 0.0;
    columnIndexes.getRange(0, columnIdx).forEach((idx) {
      width += refColumns[idx].width;
    });
    return width;
  }

  @override
  double bodyColumnsWidthAtColumnIdx(int columnIdx) {
    double width = 0.0;
    bodyColumnIndexes.getRange(0, columnIdx).forEach((idx) {
      width += refColumns[idx].width;
    });
    return width;
  }

  @override
  int? columnIndex(PlutoColumn column) {
    final columnIndexes = columnIndexesByShowFrozen;

    for (var i = 0; i < columnIndexes.length; i += 1) {
      if (refColumns[columnIndexes[i]].field == column.field) {
        return i;
      }
    }

    return null;
  }

  @override
  void insertColumns(int columnIdx, List<PlutoColumn> columns) {
    if (columns.isEmpty) {
      return;
    }

    if (columnIdx < 0 || refColumns.length < columnIdx) {
      return;
    }

    if (columnIdx >= refColumns.originalLength) {
      refColumns.addAll(columns.cast<PlutoColumn>());
    } else {
      refColumns.insertAll(columnIdx, columns);
    }

    _fillCellsInRows(columns);

    resetCurrentState(notify: false);

    notifyListeners();
  }

  @override
  void removeColumns(List<PlutoColumn> columns) {
    if (columns.isEmpty) {
      return;
    }

    refColumns.removeWhereFromOriginal((column) => columns.contains(column));

    _removeCellsInRows(columns);

    removeColumnsInColumnGroup(columns, notify: false);

    removeColumnsInFilterRows(columns, notify: false);

    resetCurrentState(notify: false);

    notifyListeners();
  }

  @override
  void moveColumn({
    required PlutoColumn column,
    required PlutoColumn targetColumn,
  }) {
    final foundIndexes = _findIndexOfColumns([column, targetColumn]);

    if (foundIndexes.length != 2) {
      return;
    }

    int index = foundIndexes[0];

    int targetIndex = foundIndexes[1];

    final frozen = refColumns[index].frozen;

    final targetFrozen = refColumns[targetIndex].frozen;

    bool moveColumn = true;

    if (frozen != targetFrozen) {
      if (targetFrozen.isRight && index > targetIndex) {
        moveColumn = false;
      } else if (targetFrozen.isLeft && index < targetIndex) {
        moveColumn = false;
      } else if (frozen.isLeft && index > targetIndex) {
        targetIndex += 1;
      } else if (frozen.isRight && index < targetIndex) {
        targetIndex -= 1;
      }
    }

    refColumns[index].frozen = targetFrozen;

    if (moveColumn) {
      var columnToMove = refColumns[index];

      refColumns.removeAt(index);

      refColumns.insert(targetIndex, columnToMove);
    }

    updateCurrentCellPosition(notify: false);

    notifyListeners();
  }

  @override
  void resizeColumn(
    PlutoColumn column,
    double offset, {
    bool notify = true,
    bool checkScroll = true,
  }) {
    final setWidth = column.width + offset;

    column.width = setWidth > column.minWidth ? setWidth : column.minWidth;

    resetShowFrozenColumn(notify: false);

    if (notify) {
      notifyListeners();
    }

    if (checkScroll) {
      updateCorrectScroll();
    }
  }

  @override
  void autoFitColumn(BuildContext context, PlutoColumn column) {
    final String maxValue = refRows.fold('', (previousValue, element) {
      final value = column.formattedValueForDisplay(
        element.cells.entries
            .firstWhere((element) => element.key == column.field)
            .value
            .value,
      );

      if (previousValue.length < value.length) {
        return value;
      }

      return previousValue;
    });

    // Get size after rendering virtually
    // https://stackoverflow.com/questions/54351655/flutter-textfield-width-should-match-width-of-contained-text
    TextSpan textSpan = TextSpan(
      style: DefaultTextStyle.of(context).style,
      text: maxValue,
    );

    TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // todo : Apply (popup type icon, checkbox, drag indicator, renderer)

    double cellPadding =
        column.cellPadding ?? configuration!.defaultCellPadding;

    resizeColumn(
      column,
      textPainter.width - column.width + (cellPadding * 2) + 2,
    );
  }

  @override
  void hideColumn(
    Key columnKey,
    bool flag, {
    bool notify = true,
    bool checkScroll = true,
  }) {
    var found = refColumns.originalList.firstWhereOrNull(
      (element) => element.key == columnKey,
    );

    if (found == null || found.hide == flag) {
      return;
    }

    found.hide = flag;

    refColumns.update();

    resetCurrentState(notify: false);

    if (notify) {
      notifyListeners();
    }

    if (checkScroll) {
      updateCorrectScroll();
    }
  }

  @override
  void sortAscending(PlutoColumn column, {bool notify = true}) {
    _resetColumnSort();

    column.sort = PlutoColumnSort.ascending;

    refRows.sort(
      (a, b) => column.type.compare(
        a.cells[column.field]!.valueForSorting,
        b.cells[column.field]!.valueForSorting,
      ),
    );

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void sortDescending(PlutoColumn column, {bool notify = true}) {
    _resetColumnSort();

    column.sort = PlutoColumnSort.descending;

    refRows.sort(
      (b, a) => column.type.compare(
        a.cells[column.field]!.valueForSorting,
        b.cells[column.field]!.valueForSorting,
      ),
    );

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void sortBySortIdx(PlutoColumn column, {bool notify = true}) {
    _resetColumnSort();

    refRows.sort((a, b) {
      if (a.sortIdx == null || b.sortIdx == null) {
        if (a.sortIdx == null && b.sortIdx == null) {
          return 0;
        }

        return a.sortIdx == null ? -1 : 1;
      }

      return a.sortIdx!.compareTo(b.sortIdx!);
    });

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void showSetColumnsPopup(BuildContext context) {
    const columnField = 'field';

    var columns = [
      PlutoColumn(
        title: configuration!.localeText.setColumnsTitle,
        field: 'title',
        type: PlutoColumnType.text(),
        enableRowChecked: true,
        enableEditingMode: false,
        enableContextMenu: false,
        enableColumnDrag: false,
      ),
      PlutoColumn(
        title: 'column field',
        field: columnField,
        type: PlutoColumnType.text(),
        hide: true,
      ),
    ];

    var toRow = _toRowByColumnField(columnField);

    var rows = refColumns.originalList.map(toRow).toList();

    PlutoGridStateManager? stateManager;

    PlutoGridPopup(
      context: context,
      configuration: configuration!.copyWith(
        enableRowColorAnimation: false,
        gridBorderRadius:
            configuration?.gridPopupBorderRadius ?? BorderRadius.zero,
      ),
      columns: columns,
      rows: rows,
      width: 200,
      height: 500,
      mode: PlutoGridMode.popup,
      onLoaded: (e) {
        stateManager = e.stateManager;
        stateManager!.setSelectingMode(PlutoGridSelectingMode.none);
        stateManager!.addListener(
          _handleSetColumnsListener(stateManager!, columnField),
        );
      },
    );
  }

  void _resetColumnSort() {
    for (var i = 0; i < refColumns.originalList.length; i += 1) {
      refColumns.originalList[i].sort = PlutoColumnSort.none;
    }
  }

  List<int> _findIndexOfColumns(List<PlutoColumn> findColumns) {
    SplayTreeMap<int, int> found = SplayTreeMap();

    for (int i = 0; i < refColumns.length; i += 1) {
      for (int j = 0; j < findColumns.length; j += 1) {
        if (findColumns[j].key == refColumns[i].key) {
          found[j] = i;
          continue;
        }
      }

      if (findColumns.length == found.length) {
        break;
      }
    }

    return found.values.toList();
  }

  PlutoRow Function(PlutoColumn column) _toRowByColumnField(
    String columnField,
  ) {
    return (PlutoColumn column) {
      return PlutoRow(
        cells: {
          'title': PlutoCell(value: column.title),
          columnField: PlutoCell(value: column.field),
        },
        checked: !column.hide,
      );
    };
  }

  void Function() _handleSetColumnsListener(
      PlutoGridStateManager stateManager, String columnField) {
    return () {
      for (var row in stateManager.refRows) {
        var found = refColumns.originalList.firstWhereOrNull(
          (column) => column.field == row.cells[columnField]!.value.toString(),
        );

        if (found != null) {
          hideColumn(found.key, row.checked != true, notify: false);
        }
      }

      notifyListeners();
    };
  }

  void _fillCellsInRows(List<PlutoColumn> columns) {
    for (var row in refRows.originalList) {
      final List<MapEntry<String, PlutoCell>> cells = [];

      for (var column in columns) {
        final cell = PlutoCell(value: column.type.defaultValue)
          ..setRow(row)
          ..setColumn(column);

        cells.add(MapEntry(column.field, cell));
      }

      row.cells.addEntries(cells);
    }
  }

  void _removeCellsInRows(List<PlutoColumn> columns) {
    for (var row in refRows.originalList) {
      for (var column in columns) {
        row.cells.remove(column.field);
      }
    }
  }
}
