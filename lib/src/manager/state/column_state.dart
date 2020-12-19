import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IColumnState {
  /// Columns provided at grid start.
  List<PlutoColumn> get columns;

  List<PlutoColumn> refColumns;

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
  PlutoColumn get currentColumn;

  /// Column field name of currently selected cell.
  String get currentColumnField;

  bool get hasSortedColumn;

  PlutoColumn get getSortedColumn;

  /// Column Index List by frozen Column
  List<int> get columnIndexesByShowFrozen;

  /// Whether a frozen column is displayed in the screen width.
  bool isShowFrozenColumn(double maxWidth);

  /// Toggle whether the column is frozen or not.
  void toggleFrozenColumn(Key columnKey, PlutoColumnFrozen frozen);

  /// Toggle column sorting.
  void toggleSortColumn(Key columnKey);

  /// Column width to index location based on full column.
  double columnsWidthAtColumnIdx(int columnIdx);

  /// Column width to index location based on Body column
  double bodyColumnsWidthAtColumnIdx(int columnIdx);

  /// Index of [column] in [columns]
  ///
  /// Depending on the state of the frozen column, the column order index
  /// must be referenced with the columnIndexesByShowFrozen function.
  int columnIndex(PlutoColumn column);

  /// Change column position.
  void moveColumn(Key columnKey, double offset);

  /// Change column size
  void resizeColumn(Key columnKey, double offset);

  void autoFitColumn(BuildContext context, PlutoColumn column);

  void sortAscending(PlutoColumn column);

  void sortDescending(PlutoColumn column);

  void sortBySortIdx();
}

mixin ColumnState implements IPlutoState {
  List<PlutoColumn> get columns => [...refColumns];

  List<PlutoColumn> refColumns;

  List<int> get columnIndexes => refColumns.asMap().keys.toList();

  List<int> get columnIndexesForShowFrozen {
    return [
      ...leftFrozenColumnIndexes,
      ...bodyColumnIndexes,
      ...rightFrozenColumnIndexes
    ];
  }

  double get columnsWidth {
    return refColumns.fold(0, (double value, element) => value + element.width);
  }

  List<PlutoColumn> get leftFrozenColumns {
    return refColumns.where((e) => e.frozen.isLeft).toList();
  }

  List<int> get leftFrozenColumnIndexes {
    return refColumns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.frozen.isLeft) {
        return [...previousValue, refColumns.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  double get leftFrozenColumnsWidth {
    return leftFrozenColumns.fold(
        0, (double value, element) => value + element.width);
  }

  List<PlutoColumn> get rightFrozenColumns {
    return refColumns.where((e) => e.frozen.isRight).toList();
  }

  List<int> get rightFrozenColumnIndexes {
    return refColumns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.frozen.isRight) {
        return [...previousValue, refColumns.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  double get rightFrozenColumnsWidth {
    return rightFrozenColumns.fold(
        0, (double value, element) => value + element.width);
  }

  List<PlutoColumn> get bodyColumns {
    return refColumns.where((e) => e.frozen.isNone).toList();
  }

  List<int> get bodyColumnIndexes {
    return bodyColumns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.frozen.isNone) {
        return [...previousValue, refColumns.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  double get bodyColumnsWidth {
    return bodyColumns.fold(
        0, (double value, element) => value + element.width);
  }

  PlutoColumn get currentColumn {
    if (currentColumnField == null) {
      return null;
    }

    return refColumns
        .where((element) => element.field == currentColumnField)
        ?.first;
  }

  String get currentColumnField {
    if (currentRow == null) {
      return null;
    }

    return currentRow.cells.keys.firstWhere(
        (key) => currentRow.cells[key].key == currentCell?.key,
        orElse: () => null);
  }

  bool get hasSortedColumn =>
      refColumns.firstWhere(
        (element) => !element.sort.isNone,
        orElse: () => null,
      ) !=
      null;

  PlutoColumn get getSortedColumn => refColumns.firstWhere(
        (element) => !element.sort.isNone,
        orElse: () => null,
      );

  List<int> get columnIndexesByShowFrozen {
    return showFrozenColumn ? columnIndexesForShowFrozen : columnIndexes;
  }

  bool isShowFrozenColumn(double maxWidth) {
    final bool hasFrozenColumn =
        leftFrozenColumns.isNotEmpty || rightFrozenColumns.isNotEmpty;

    return hasFrozenColumn &&
        maxWidth >
            (leftFrozenColumnsWidth +
                rightFrozenColumnsWidth +
                PlutoGridSettings.bodyMinWidth +
                PlutoGridSettings.totalShadowLineWidth);
  }

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

  void toggleSortColumn(Key columnKey) {
    for (var i = 0; i < refColumns.length; i += 1) {
      PlutoColumn column = refColumns[i];

      if (column.key == columnKey) {
        if (column.sort.isNone) {
          column.sort = PlutoColumnSort.ascending;

          sortAscending(column);
        } else if (column.sort.isAscending) {
          column.sort = PlutoColumnSort.descending;

          sortDescending(column);
        } else {
          column.sort = PlutoColumnSort.none;

          sortBySortIdx();
        }
      } else {
        column.sort = PlutoColumnSort.none;
      }
    }

    updateCurrentCellPosition(notify: false);

    notifyListeners();
  }

  double columnsWidthAtColumnIdx(int columnIdx) {
    double width = 0.0;
    columnIndexes.getRange(0, columnIdx).forEach((idx) {
      width += refColumns[idx].width;
    });
    return width;
  }

  double bodyColumnsWidthAtColumnIdx(int columnIdx) {
    double width = 0.0;
    bodyColumnIndexes.getRange(0, columnIdx).forEach((idx) {
      width += refColumns[idx].width;
    });
    return width;
  }

  int columnIndex(PlutoColumn column) {
    final columnIndexes = columnIndexesByShowFrozen;

    for (var i = 0; i < columnIndexes.length; i += 1) {
      if (refColumns[columnIndexes[i]].field == column.field) {
        return i;
      }
    }

    return null;
  }

  void moveColumn(Key columnKey, double offset) {
    offset -= gridGlobalOffset.dx;

    final List<int> columnIndexes = columnIndexesByShowFrozen;

    Function findColumnIndex = (int i) {
      if (refColumns[columnIndexes[i]].key == columnKey) {
        return columnIndexes[i];
      }
      return null;
    };

    Function findIndexToMove = () {
      final double minLeft = showFrozenColumn ? leftFrozenColumnsWidth : 0;

      final double minRight =
          showFrozenColumn ? maxWidth - rightFrozenColumnsWidth : maxWidth;

      double currentOffset = 0.0;

      int startIndexToMove = 0;

      if (minRight < offset) {
        currentOffset = minRight;
        startIndexToMove = refColumns.length - rightFrozenColumns.length;
      } else if (minLeft < offset) {
        currentOffset -= scroll.horizontal.offset;
      }

      return (int i) {
        if (i == startIndexToMove) {
          if (currentOffset < offset &&
              offset <
                  currentOffset +
                      refColumns[columnIndexes[startIndexToMove]].width) {
            return columnIndexes[startIndexToMove];
          }

          currentOffset += refColumns[columnIndexes[startIndexToMove]].width;
          ++startIndexToMove;
        }

        return null;
      };
    }();

    int columnIndex;
    int indexToMove;

    for (var i = 0; i < columnIndexes.length; i += 1) {
      columnIndex ??= findColumnIndex(i);

      indexToMove ??= findIndexToMove(i);

      if (indexToMove != null && columnIndex != null) {
        break;
      }
    }

    if (columnIndex == indexToMove ||
        columnIndex == null ||
        indexToMove == null) {
      return;
    }

    // 컬럼의 순서 변경
    refColumns[columnIndex].frozen = refColumns[indexToMove].frozen;
    if (indexToMove < columnIndex) {
      refColumns.insert(indexToMove, refColumns[columnIndex]);
      refColumns.removeRange(columnIndex + 1, columnIndex + 2);
    } else {
      refColumns.insert(indexToMove + 1, refColumns[columnIndex]);
      refColumns.removeRange(columnIndex, columnIndex + 1);
    }

    updateCurrentCellPosition(notify: false);

    notifyListeners();
  }

  void resizeColumn(Key columnKey, double offset) {
    for (var i = 0; i < refColumns.length; i += 1) {
      final column = refColumns[i];

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
    final String maxValue = refRows.fold('', (previousValue, element) {
      final value = element.cells.entries
          .firstWhere((element) => element.key == column.field)
          .value
          .value;

      if (previousValue.toString().length < value.toString().length) {
        return value.toString();
      }

      return previousValue.toString();
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

    resizeColumn(
      column.key,
      textPainter.width -
          column.width +
          (PlutoGridSettings.cellPadding * 2) +
          10,
    );
  }

  void sortAscending(PlutoColumn column) {
    refRows.sort(
      (a, b) => column.type.compare(
        a.cells[column.field].valueForSorting,
        b.cells[column.field].valueForSorting,
      ),
    );
  }

  void sortDescending(PlutoColumn column) {
    refRows.sort(
      (b, a) => column.type.compare(
        a.cells[column.field].valueForSorting,
        b.cells[column.field].valueForSorting,
      ),
    );
  }

  void sortBySortIdx() {
    refRows.sort((a, b) {
      if (a.sortIdx == null || b.sortIdx == null) {
        if (a.sortIdx == null && b.sortIdx == null) {
          return 0;
        }

        return a.sortIdx == null ? -1 : 1;
      }

      return a.sortIdx.compareTo(b.sortIdx);
    });
  }
}
