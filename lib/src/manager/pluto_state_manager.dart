part of '../../pluto_grid.dart';

abstract class IPlutoState extends ChangeNotifier
    implements
        ICellState,
        IColumnState,
        IEditingState,
        IGridState,
        IKeyboardState,
        IRowState,
        IScrollState,
        ISelectingState {
  notifyListeners({
    bool checkCellValue = true,
  });
}

class PlutoState extends ChangeNotifier
    with
        CellState,
        ColumnState,
        EditingState,
        GridState,
        KeyboardState,
        RowState,
        ScrollState,
        SelectingState {
  notifyListeners({
    bool checkCellValue = true,
  }) {
    if (checkCellValue) {
      super.notifyListeners();
    } else {
      withoutCheckCellValue(() {
        super.notifyListeners();
      });
    }
  }
}

class PlutoStateManager extends PlutoState {
  PlutoStateManager({
    @required List<PlutoColumn> columns,
    @required List<PlutoRow> rows,
    @required FocusNode gridFocusNode,
    @required PlutoScrollController scroll,
    PlutoMode mode,
    PlutoOnChangedEventCallback onChangedEventCallback,
    PlutoOnSelectedEventCallback onSelectedEventCallback,
  }) {
    this._columns = columns;
    this._rows = rows;
    this._gridFocusNode = gridFocusNode;
    this._scroll = scroll;
    this._mode = mode;
    this._onChanged = onChangedEventCallback;
    this._onSelected = onSelectedEventCallback;
    this._gridKey = GlobalKey();
  }

  static List<PlutoSelectingMode> get selectingModes =>
      PlutoSelectingMode.None.items;

  static void initializeRows(
    List<PlutoColumn> refColumns,
    List<PlutoRow> refRows, {
    bool increase = true,
    int start = 0,
  }) {
    if (refColumns == null ||
        refColumns.length < 1 ||
        refRows == null ||
        refRows.length < 1) {
      return;
    }

    List<PlutoColumn> columnsForApplyFormat = refColumns
        .where((element) => element.type.applyFormatOnInit)
        .toList(growable: false);

    final bool hasColumnsForApplyFormat = columnsForApplyFormat.length > 0;

    final bool hasSortIdx = refRows.length > 0 && refRows.first.sortIdx != null;

    if (hasColumnsForApplyFormat == false && hasSortIdx == true) {
      return;
    }

    int sortIdx = start;

    for (var rowIdx = 0; rowIdx < refRows.length; rowIdx += 1) {
      if (hasColumnsForApplyFormat) {
        columnsForApplyFormat.forEach((column) {
          refRows[rowIdx].cells[column.field].value = column.type
              .applyFormat(refRows[rowIdx].cells[column.field].value);

          if (column.type.isNumber) {
            refRows[rowIdx].cells[column.field].value = num.tryParse(
                  refRows[rowIdx].cells[column.field].value.replaceAll(',', ''),
                ) ??
                0;
          }
        });
      }

      if (hasSortIdx == false) {
        refRows[rowIdx].sortIdx = sortIdx;

        sortIdx = increase ? ++sortIdx : --sortIdx;
      }
    }
  }
}

class PlutoScrollController {
  LinkedScrollControllerGroup vertical;
  ScrollController leftFixedRowsVertical;
  ScrollController bodyRowsVertical;
  ScrollController rightRowsVerticalScroll;

  LinkedScrollControllerGroup horizontal;
  ScrollController bodyHeadersHorizontal;
  ScrollController bodyRowsHorizontal;

  PlutoScrollController({
    this.vertical,
    this.leftFixedRowsVertical,
    this.bodyRowsVertical,
    this.rightRowsVerticalScroll,
    this.horizontal,
    this.bodyHeadersHorizontal,
    this.bodyRowsHorizontal,
  });
}

class PlutoLayout {
  /// Screen width
  double maxWidth;

  /// Screen height
  double maxHeight;

  /// grid header height
  double headerHeight;

  /// grid footer height
  double footerHeight;

  /// Whether to apply a fixed column according to the screen size.
  /// true : If there is a fixed column, the fixed column is exposed.
  /// false : If there is a fixed column but the screen is narrow, it is exposed as a normal column.
  bool showFixedColumn;

  PlutoLayout({
    this.maxWidth,
    this.maxHeight,
    this.showFixedColumn,
    this.headerHeight,
    this.footerHeight,
  });

  double get offsetHeight => maxHeight - headerHeight - footerHeight;
}

class PlutoCellPosition {
  int columnIdx;
  int rowIdx;

  PlutoCellPosition({
    this.columnIdx,
    this.rowIdx,
  });
}

class PlutoKeyPressed {
  bool shift;

  bool ctrl;

  PlutoKeyPressed({
    this.shift = false,
    this.ctrl = false,
  });
}

enum PlutoSelectingMode {
  Square,
  Row,
  None,

  /// using only internal
  _Horizontal,
}

extension PlutoSelectingModeExtension on PlutoSelectingMode {
  bool get isSquare => this == PlutoSelectingMode.Square;

  bool get isRow => this == PlutoSelectingMode.Row;

  bool get isNone => this == PlutoSelectingMode.None;

  /// using only internal
  bool get _isHorizontal => this == PlutoSelectingMode._Horizontal;

  List<PlutoSelectingMode> get items {
    return [
      PlutoSelectingMode.Square,
      PlutoSelectingMode.Row,
      PlutoSelectingMode.None,
    ];
  }

  String toShortString() {
    return this.toString().split('.').last;
  }
}
