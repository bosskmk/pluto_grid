import 'dart:collection';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IColumnState {
  /// Columns provided at grid start.
  List<PlutoColumn> get columns;

  FilteredList<PlutoColumn>? refColumns;

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

  /// Whether a frozen column is displayed in the screen width.
  bool isShowFrozenColumn(double? maxWidth);

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
  int? columnIndex(PlutoColumn? column);

  /// Change column position.
  void moveColumn({
    required PlutoColumn column,
    required PlutoColumn targetColumn,
  });

  /// Change column size
  void resizeColumn(Key columnKey, double offset);

  void autoFitColumn(BuildContext context, PlutoColumn column);

  void hideColumn(
    Key columnKey,
    bool flag, {
    bool notify = true,
  });

  void sortAscending(PlutoColumn column, {bool notify = true});

  void sortDescending(PlutoColumn column, {bool notify = true});

  void sortBySortIdx(PlutoColumn column, {bool notify = true});

  void showSetColumnsPopup(BuildContext context);
}

mixin ColumnState implements IPlutoGridState {
  List<PlutoColumn> get columns => [...refColumns!];

  FilteredList<PlutoColumn>? get refColumns => _refColumns;

  set refColumns(FilteredList<PlutoColumn>? setColumns) {
    _refColumns = setColumns;
    _refColumns!.setFilter((element) => element.hide == false);
  }

  FilteredList<PlutoColumn>? _refColumns;

  List<int> get columnIndexes => refColumns!.asMap().keys.toList();

  List<int> get columnIndexesForShowFrozen {
    return [
      ...leftFrozenColumnIndexes,
      ...bodyColumnIndexes,
      ...rightFrozenColumnIndexes
    ];
  }

  double get columnsWidth {
    return refColumns!
        .fold(0, (double value, element) => value + element.width);
  }

  List<PlutoColumn> get leftFrozenColumns {
    return refColumns!.where((e) => e.frozen.isLeft).toList();
  }

  List<int> get leftFrozenColumnIndexes {
    return refColumns!.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.frozen.isLeft) {
        return [...previousValue, refColumns!.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  double get leftFrozenColumnsWidth {
    return leftFrozenColumns.fold(
        0, (double value, element) => value + element.width);
  }

  List<PlutoColumn> get rightFrozenColumns {
    return refColumns!.where((e) => e.frozen.isRight).toList();
  }

  List<int> get rightFrozenColumnIndexes {
    return refColumns!.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.frozen.isRight) {
        return [...previousValue, refColumns!.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  double get rightFrozenColumnsWidth {
    return rightFrozenColumns.fold(
        0, (double value, element) => value + element.width);
  }

  List<PlutoColumn> get bodyColumns {
    return refColumns!.where((e) => e.frozen.isNone).toList();
  }

  List<int> get bodyColumnIndexes {
    return bodyColumns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.frozen.isNone) {
        return [...previousValue, refColumns!.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  double get bodyColumnsWidth {
    return bodyColumns.fold(
        0, (double value, element) => value + element.width);
  }

  PlutoColumn? get currentColumn {
    if (currentColumnField == null) {
      return null;
    }

    return refColumns!
        .where((element) => element.field == currentColumnField)
        .first;
  }

  String? get currentColumnField {
    if (currentRow == null) {
      return null;
    }

    return currentRow!.cells.keys.firstWhereOrNull(
        (key) => currentRow!.cells[key]!.key == currentCell?.key);
  }

  bool get hasSortedColumn =>
      refColumns!.firstWhereOrNull(
        (element) => !element.sort.isNone,
      ) !=
      null;

  PlutoColumn? get getSortedColumn => refColumns!.firstWhereOrNull(
        (element) => !element.sort.isNone,
      );

  List<int> get columnIndexesByShowFrozen {
    return showFrozenColumn! ? columnIndexesForShowFrozen : columnIndexes;
  }

  bool isShowFrozenColumn(double? maxWidth) {
    final bool hasFrozenColumn =
        leftFrozenColumns.isNotEmpty || rightFrozenColumns.isNotEmpty;

    return hasFrozenColumn &&
        maxWidth! >
            (leftFrozenColumnsWidth +
                rightFrozenColumnsWidth +
                PlutoGridSettings.bodyMinWidth +
                PlutoGridSettings.totalShadowLineWidth);
  }

  void toggleFrozenColumn(Key columnKey, PlutoColumnFrozen frozen) {
    for (var i = 0; i < refColumns!.length; i += 1) {
      if (refColumns![i].key == columnKey) {
        refColumns![i].frozen =
            refColumns![i].frozen.isFrozen ? PlutoColumnFrozen.none : frozen;
        break;
      }
    }

    updateCurrentCellPosition(notify: false);

    notifyListeners();
  }

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

  double columnsWidthAtColumnIdx(int columnIdx) {
    double width = 0.0;
    columnIndexes.getRange(0, columnIdx).forEach((idx) {
      width += refColumns![idx].width;
    });
    return width;
  }

  double bodyColumnsWidthAtColumnIdx(int columnIdx) {
    double width = 0.0;
    bodyColumnIndexes.getRange(0, columnIdx).forEach((idx) {
      width += refColumns![idx].width;
    });
    return width;
  }

  int? columnIndex(PlutoColumn? column) {
    final columnIndexes = columnIndexesByShowFrozen;

    for (var i = 0; i < columnIndexes.length; i += 1) {
      if (refColumns![columnIndexes[i]].field == column!.field) {
        return i;
      }
    }

    return null;
  }

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

    final frozen = refColumns![index].frozen;

    final targetFrozen = refColumns![targetIndex].frozen;

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

    refColumns![index].frozen = targetFrozen;

    if (moveColumn) {
      var columnToMove = refColumns![index];

      refColumns!.removeAt(index);

      refColumns!.insert(targetIndex, columnToMove);
    }

    updateCurrentCellPosition(notify: false);

    notifyListeners();
  }

  void resizeColumn(Key columnKey, double offset) {
    for (var i = 0; i < refColumns!.length; i += 1) {
      final column = refColumns![i];

      if (column.key == columnKey) {
        final setWidth = column.width + offset;

        column.width = setWidth > column.minWidth ? setWidth : column.minWidth;
        break;
      }
    }

    resetShowFrozenColumn(notify: false);

    notifyListeners();
  }

  void autoFitColumn(BuildContext context, PlutoColumn column) {
    final String maxValue = refRows!.fold('', (previousValue, element) {
      final value = column.formattedValueForDisplay(
        element!.cells.entries
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
      column.key,
      textPainter.width - column.width + (cellPadding * 2) + 2,
    );
  }

  void hideColumn(
    Key columnKey,
    bool flag, {
    bool notify = true,
  }) {
    var found = refColumns!.originalList.firstWhereOrNull(
      (element) => element.key == columnKey,
    );

    if (found == null || found.hide == flag) {
      return;
    }

    found.hide = flag;

    refColumns!.update();

    resetCurrentState(notify: false);

    if (notify) {
      notifyListeners();
    }
  }

  void sortAscending(PlutoColumn column, {bool notify = true}) {
    _resetColumnSort();

    column.sort = PlutoColumnSort.ascending;

    refRows!.sort(
      (a, b) => column.type.compare(
        a!.cells[column.field]!.valueForSorting,
        b!.cells[column.field]!.valueForSorting,
      ),
    );

    if (notify) {
      notifyListeners();
    }
  }

  void sortDescending(PlutoColumn column, {bool notify = true}) {
    _resetColumnSort();

    column.sort = PlutoColumnSort.descending;

    refRows!.sort(
      (b, a) => column.type.compare(
        a!.cells[column.field]!.valueForSorting,
        b!.cells[column.field]!.valueForSorting,
      ),
    );

    if (notify) {
      notifyListeners();
    }
  }

  void sortBySortIdx(PlutoColumn column, {bool notify = true}) {
    _resetColumnSort();

    refRows!.sort((a, b) {
      if (a!.sortIdx == null || b!.sortIdx == null) {
        if (a.sortIdx == null && b!.sortIdx == null) {
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

  void showSetColumnsPopup(BuildContext? context) {
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

    var toRow = (PlutoColumn c) {
      return PlutoRow(
        cells: {
          'title': PlutoCell(value: c.title),
          columnField: PlutoCell(value: c.field),
        },
        checked: !c.hide,
      );
    };

    var rows = refColumns!.originalList.map(toRow).toList();

    PlutoGridStateManager? stateManager;

    var handleLister = () {
      stateManager!.refRows!.forEach((row) {
        var found = refColumns!.originalList.firstWhereOrNull(
          (column) => column.field == row!.cells[columnField]!.value.toString(),
        );

        if (found != null) {
          hideColumn(found.key, row!.checked != true, notify: false);
        }
      });

      notifyListeners();
    };

    PlutoGridPopup(
      context: context,
      configuration: configuration,
      columns: columns,
      rows: rows,
      width: 200,
      height: 500,
      mode: PlutoGridMode.popup,
      onLoaded: (e) {
        stateManager = e.stateManager;
        stateManager!.setSelectingMode(PlutoGridSelectingMode.none);
        stateManager!.addListener(handleLister);
      },
    );
  }

  void _resetColumnSort() {
    for (var i = 0; i < refColumns!.originalList.length; i += 1) {
      refColumns!.originalList[i].sort = PlutoColumnSort.none;
    }
  }

  List<int> _findIndexOfColumns(List<PlutoColumn> findColumns) {
    SplayTreeMap<int, int> found = SplayTreeMap();

    for (int i = 0; i < refColumns!.length; i += 1) {
      for (int j = 0; j < findColumns.length; j += 1) {
        if (findColumns[j].key == refColumns![i].key) {
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
}
