part of '../../../pluto_grid.dart';

abstract class IColumnState {
  /// Columns provided at grid start.
  List<PlutoColumn> get columns;

  List<PlutoColumn> _columns;

  /// Column index list.
  List<int> get columnIndexes;

  /// List of column indexes in which the sequence is maintained
  /// while the Fixed column is visible.
  List<int> get columnIndexesForShowFixed;

  /// Width of the entire column.
  double get columnsWidth;

  /// Left fixed columns.
  List<PlutoColumn> get leftFixedColumns;

  /// Left fixed column Index List.
  List<int> get leftFixedColumnIndexes;

  /// Width of the left fixed column.
  double get leftFixedColumnsWidth;

  /// Right fixed columns.
  List<PlutoColumn> get rightFixedColumns;

  /// Right fixed column Index List.
  List<int> get rightFixedColumnIndexes;

  /// Width of the right fixed column.
  double get rightFixedColumnsWidth;

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

  /// Column Index List by Fixed Column
  List<int> columnIndexesByShowFixed();

  /// Whether a fixed column is displayed in the screen width.
  bool isShowFixedColumn(double maxWidth);

  /// Toggle whether the column is fixed or not.
  void toggleFixedColumn(Key columnKey, PlutoColumnFixed fixed);

  /// Toggle column sorting.
  void toggleSortColumn(Key columnKey);

  /// Column width to index location based on full column.
  double columnsWidthAtColumnIdx(int columnIdx);

  /// Column width to index location based on Body column
  double bodyColumnsWidthAtColumnIdx(int columnIdx);

  /// Index of [column] in [columns]
  ///
  /// Depending on the state of the fixed column, the column order index
  /// must be referenced with the columnIndexesByShowFixed function.
  int columnIndex(PlutoColumn column);

  /// Change column position.
  void moveColumn(Key columnKey, double offset);

  /// Change column size
  void resizeColumn(Key columnKey, double offset);
}

mixin ColumnState implements IPlutoState {
  List<PlutoColumn> get columns => [..._columns];

  List<PlutoColumn> _columns;

  List<int> get columnIndexes => _columns.asMap().keys.toList();

  List<int> get columnIndexesForShowFixed {
    return [
      ...leftFixedColumnIndexes,
      ...bodyColumnIndexes,
      ...rightFixedColumnIndexes
    ];
  }

  double get columnsWidth {
    return _columns.fold(0, (double value, element) => value + element.width);
  }

  List<PlutoColumn> get leftFixedColumns {
    return _columns.where((e) => e.fixed.isLeft).toList();
  }

  List<int> get leftFixedColumnIndexes {
    return _columns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.fixed.isLeft) {
        return [...previousValue, columns.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  double get leftFixedColumnsWidth {
    return leftFixedColumns.fold(
        0, (double value, element) => value + element.width);
  }

  List<PlutoColumn> get rightFixedColumns {
    return _columns.where((e) => e.fixed.isRight).toList();
  }

  List<int> get rightFixedColumnIndexes {
    return _columns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.fixed.isRight) {
        return [...previousValue, columns.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  double get rightFixedColumnsWidth {
    return rightFixedColumns.fold(
        0, (double value, element) => value + element.width);
  }

  List<PlutoColumn> get bodyColumns {
    return _columns.where((e) => e.fixed.isNone).toList();
  }

  List<int> get bodyColumnIndexes {
    return bodyColumns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.fixed.isNone) {
        return [...previousValue, columns.indexOf(element)];
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

    return _columns
        .where((element) => element.field == currentColumnField)
        ?.first;
  }

  String get currentColumnField {
    if (currentRow == null) {
      return null;
    }

    return currentRow.cells.keys.firstWhere(
        (key) => currentRow.cells[key]._key == currentCell?._key,
        orElse: () => null);
  }

  List<int> columnIndexesByShowFixed() {
    return showFixedColumn ? columnIndexesForShowFixed : columnIndexes;
  }

  bool isShowFixedColumn(double maxWidth) {
    final bool hasFixedColumn =
        leftFixedColumns.length > 0 || rightFixedColumns.length > 0;

    return hasFixedColumn &&
        maxWidth >
            (leftFixedColumnsWidth +
                rightFixedColumnsWidth +
                PlutoDefaultSettings.bodyMinWidth +
                PlutoDefaultSettings.totalShadowLineWidth);
  }

  void toggleFixedColumn(Key columnKey, PlutoColumnFixed fixed) {
    for (var i = 0; i < _columns.length; i += 1) {
      if (_columns[i]._key == columnKey) {
        _columns[i].fixed =
            _columns[i].fixed.isFixed ? PlutoColumnFixed.None : fixed;
        break;
      }
    }

    updateCurrentCellPosition(notify: false);

    notifyListeners();
  }

  void toggleSortColumn(Key columnKey) {
    for (var i = 0; i < _columns.length; i += 1) {
      PlutoColumn column = _columns[i];

      if (column._key == columnKey) {
        final field = column.field;

        if (column.sort.isNone) {
          column.sort = PlutoColumnSort.Ascending;

          _rows.sort((a, b) =>
              column.type.compare(a.cells[field].value, b.cells[field].value));
        } else if (column.sort.isAscending) {
          column.sort = PlutoColumnSort.Descending;

          _rows.sort((b, a) =>
              column.type.compare(a.cells[field].value, b.cells[field].value));
        } else {
          column.sort = PlutoColumnSort.None;

          _rows.sort((a, b) {
            if (a.sortIdx == null || b.sortIdx == null) return 0;

            return a.sortIdx.compareTo(b.sortIdx);
          });
        }
      } else {
        column.sort = PlutoColumnSort.None;
      }
    }

    updateCurrentRowIdx(notify: false);

    updateCurrentCellPosition(notify: false);

    notifyListeners();
  }

  double columnsWidthAtColumnIdx(int columnIdx) {
    double width = 0.0;
    columnIndexes.getRange(0, columnIdx).forEach((idx) {
      width += _columns[idx].width;
    });
    return width;
  }

  double bodyColumnsWidthAtColumnIdx(int columnIdx) {
    double width = 0.0;
    bodyColumnIndexes.getRange(0, columnIdx).forEach((idx) {
      width += columns[idx].width;
    });
    return width;
  }

  int columnIndex(PlutoColumn column) {
    final columnIndexes = columnIndexesByShowFixed();

    for (var i = 0; i < columnIndexes.length; i += 1) {
      if (_columns[columnIndexes[i]].field == column.field) {
        return i;
      }
    }

    return null;
  }

  void moveColumn(Key columnKey, double offset) {
    offset -= gridGlobalOffset.dx;

    final List<int> columnIndexes = columnIndexesByShowFixed();

    Function findColumnIndex = (int i) {
      if (_columns[columnIndexes[i]]._key == columnKey) {
        return columnIndexes[i];
      }
      return null;
    };

    Function findIndexToMove = () {
      final double minLeft = showFixedColumn ? leftFixedColumnsWidth : 0;

      final double minRight =
          showFixedColumn ? maxWidth - rightFixedColumnsWidth : maxWidth;

      double currentOffset = 0.0;

      int startIndexToMove = 0;

      if (minRight < offset) {
        currentOffset = minRight;
        startIndexToMove = _columns.length - rightFixedColumns.length;
      } else if (minLeft < offset) {
        currentOffset -= scroll.horizontal.offset;
      }

      return (int i) {
        if (i == startIndexToMove) {
          if (currentOffset < offset &&
              offset <
                  currentOffset +
                      _columns[columnIndexes[startIndexToMove]].width) {
            return columnIndexes[startIndexToMove];
          }

          currentOffset += _columns[columnIndexes[startIndexToMove]].width;
          ++startIndexToMove;
        }

        return null;
      };
    }();

    int columnIndex;
    int indexToMove;

    for (var i = 0; i < columnIndexes.length; i += 1) {
      if (columnIndex == null) {
        columnIndex = findColumnIndex(i);
      }

      if (indexToMove == null) {
        indexToMove = findIndexToMove(i);
      }

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
    _columns[columnIndex].fixed = _columns[indexToMove].fixed;
    if (indexToMove < columnIndex) {
      _columns.insert(indexToMove, _columns[columnIndex]);
      _columns.removeRange(columnIndex + 1, columnIndex + 2);
    } else {
      _columns.insert(indexToMove + 1, _columns[columnIndex]);
      _columns.removeRange(columnIndex, columnIndex + 1);
    }

    updateCurrentCellPosition(notify: false);

    notifyListeners();
  }

  void resizeColumn(Key columnKey, double offset) {
    for (var i = 0; i < _columns.length; i += 1) {
      if (_columns[i]._key == columnKey) {
        final setWidth = _columns[i].width + offset;

        _columns[i].width = setWidth > PlutoDefaultSettings.minColumnWidth
            ? setWidth
            : PlutoDefaultSettings.minColumnWidth;
        break;
      }
    }

    resetShowFixedColumn(notify: false);

    notifyListeners();
  }
}
