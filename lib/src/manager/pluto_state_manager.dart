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

  PlutoKeyPressed({
    this.shift = false,
  });
}

enum PlutoSelectingMode {
  Square,
  Horizontal,
  None,
}

extension PlutoSelectingModeExtension on PlutoSelectingMode {
  bool get isSquare => this == PlutoSelectingMode.Square;

  bool get isHorizontal => this == PlutoSelectingMode.Horizontal;

  bool get isNone => this == PlutoSelectingMode.None;
}
