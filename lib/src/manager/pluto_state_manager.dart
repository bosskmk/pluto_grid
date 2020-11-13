part of '../../pluto_grid.dart';

abstract class IPlutoState extends ChangeNotifier
    implements
        ICellState,
        IColumnState,
        IDraggingRowState,
        IEditingState,
        IGridState,
        IKeyboardState,
        ILayoutState,
        IRowState,
        IScrollState,
        ISelectingState {
  notifyListeners();
}

class PlutoState extends ChangeNotifier
    with
        CellState,
        ColumnState,
        DraggingRowState,
        EditingState,
        GridState,
        KeyboardState,
        LayoutState,
        RowState,
        ScrollState,
        SelectingState {
  notifyListeners() {
    super.notifyListeners();
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
    CreateHeaderCallBack createHeader,
    CreateFooterCallBack createFooter,
    PlutoConfiguration configuration,
  }) {
    _columns = columns;
    _rows = rows;
    setGridFocusNode(gridFocusNode);
    setScroll(scroll);
    setGridMode(mode);
    setOnChanged(onChangedEventCallback);
    setOnSelected(onSelectedEventCallback);
    setCreateHeader(createHeader);
    setCreateFooter(createFooter);
    setConfiguration(configuration);
    setGridKey(GlobalKey());
  }

  static List<PlutoSelectingMode> get selectingModes =>
      PlutoSelectingMode.None.items;

  static void initializeRows(
    List<PlutoColumn> refColumns,
    List<PlutoRow> refRows, {
    bool forceApplySortIdx = false,
    bool increase = true,
    int start = 0,
  }) {
    if (refColumns == null ||
        refColumns.isEmpty ||
        refRows == null ||
        refRows.isEmpty) {
      return;
    }

    List<PlutoColumn> columnsForApplyFormat = refColumns
        .where((element) => element.type.applyFormatOnInit)
        .toList(growable: false);

    final bool applyFormat = columnsForApplyFormat.isNotEmpty;

    final bool applySortIdx = forceApplySortIdx == true ||
        (refRows.isNotEmpty && refRows.first.sortIdx == null);

    if (applyFormat == false && applySortIdx == false) {
      return;
    }

    int sortIdx = start;

    for (var rowIdx = 0; rowIdx < refRows.length; rowIdx += 1) {
      if (applyFormat) {
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

      if (applySortIdx == true) {
        refRows[rowIdx].sortIdx = sortIdx;

        sortIdx = increase ? ++sortIdx : --sortIdx;
      }
    }
  }
}

class PlutoScrollController {
  LinkedScrollControllerGroup vertical;

  LinkedScrollControllerGroup horizontal;

  PlutoScrollController({
    this.vertical,
    this.horizontal,
  });

  ScrollController get bodyRowsHorizontal => _bodyRowsHorizontal;

  ScrollController _bodyRowsHorizontal;

  ScrollController get bodyRowsVertical => _bodyRowsVertical;

  ScrollController _bodyRowsVertical;

  double get maxScrollHorizontal {
    assert(_bodyRowsHorizontal != null);

    return _bodyRowsHorizontal.position.maxScrollExtent;
  }

  double get maxScrollVertical {
    assert(_bodyRowsVertical != null);

    return _bodyRowsVertical.position.maxScrollExtent;
  }

  double get verticalOffset => vertical.offset;

  double get horizontalOffset => horizontal.offset;

  void setBodyRowsHorizontal(ScrollController scrollController) {
    _bodyRowsHorizontal = scrollController;
  }

  void setBodyRowsVertical(ScrollController scrollController) {
    _bodyRowsVertical = scrollController;
  }
}

class PlutoCellPosition {
  int columnIdx;
  int rowIdx;

  PlutoCellPosition({
    this.columnIdx,
    this.rowIdx,
  });

  @override
  bool operator ==(covariant PlutoCellPosition other) {
    return columnIdx == other.columnIdx && rowIdx == other.rowIdx;
  }

  @override
  int get hashCode => super.hashCode;
}

class PlutoSelectingCellPosition {
  String field;
  int rowIdx;

  PlutoSelectingCellPosition({
    this.field,
    this.rowIdx,
  });

  @override
  bool operator ==(covariant PlutoSelectingCellPosition other) {
    return field == other.field && rowIdx == other.rowIdx;
  }

  @override
  int get hashCode => super.hashCode;
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
    return toString().split('.').last;
  }
}
