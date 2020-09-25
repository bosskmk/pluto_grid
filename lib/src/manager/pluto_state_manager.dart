part of '../../pluto_grid.dart';

abstract class IPlutoState extends ChangeNotifier
    implements
        ICellState,
        IColumnState,
        IEditingState,
        IGridState,
        IKeyboardState,
        ILayoutState,
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
        LayoutState,
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
    CreateHeaderCallBack createHeader,
    CreateFooterCallBack createFooter,
    PlutoConfiguration configuration,
  }) {
    this._columns = columns;
    this._rows = rows;
    this.setGridFocusNode(gridFocusNode);
    this.setScroll(scroll);
    this.setGridMode(mode);
    this.setOnChanged(onChangedEventCallback);
    this.setOnSelected(onSelectedEventCallback);
    this.setCreateHeader(createHeader);
    this.setCreateFooter(createFooter);
    this.setConfiguration(configuration);
    this.setGridKey(GlobalKey());
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

  LinkedScrollControllerGroup horizontal;

  PlutoScrollController({
    this.vertical,
    this.horizontal,
  });

  ScrollController get bodyRowsVertical => _bodyRowsVertical;

  ScrollController _bodyRowsVertical;

  double get maxScrollVertical {
    assert(_bodyRowsVertical != null);

    return _bodyRowsVertical.position.maxScrollExtent;
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
