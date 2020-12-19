import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:pluto_filtered_list/pluto_filtered_list.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'state/cell_state.dart';
import 'state/column_state.dart';
import 'state/dragging_row_state.dart';
import 'state/editing_state.dart';
import 'state/filtering_row_state.dart';
import 'state/focus_state.dart';
import 'state/grid_state.dart';
import 'state/keyboard_state.dart';
import 'state/layout_state.dart';
import 'state/row_state.dart';
import 'state/scroll_state.dart';
import 'state/selecting_state.dart';

abstract class IPlutoState extends ChangeNotifier
    implements
        ICellState,
        IColumnState,
        IDraggingRowState,
        IEditingState,
        IFilteringRowState,
        IFocusState,
        IGridState,
        IKeyboardState,
        ILayoutState,
        IRowState,
        IScrollState,
        ISelectingState {
  notifyListeners();

  notifyListenersOnPostFrame();
}

class PlutoState extends ChangeNotifier
    with
        CellState,
        ColumnState,
        DraggingRowState,
        EditingState,
        FilteringRowState,
        FocusState,
        GridState,
        KeyboardState,
        LayoutState,
        RowState,
        ScrollState,
        SelectingState {
  bool _disposed = false;

  @override
  dispose() {
    _disposed = true;
    super.dispose();
  }

  notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  notifyListenersOnPostFrame() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }
}

class PlutoStateManager extends PlutoState {
  PlutoStateManager({
    @required List<PlutoColumn> columns,
    @required List<PlutoRow> rows,
    @required FocusNode gridFocusNode,
    @required PlutoScrollController scroll,
    PlutoGridMode mode,
    PlutoOnChangedEventCallback onChangedEventCallback,
    PlutoOnSelectedEventCallback onSelectedEventCallback,
    CreateHeaderCallBack createHeader,
    CreateFooterCallBack createFooter,
    PlutoConfiguration configuration,
  }) {
    refColumns = columns;
    refRows = FilteredList(initialList: rows);
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
      PlutoSelectingMode.none.items;

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

    _ApplyList applyList = _ApplyList([
      _ApplyCellFormat(refColumns),
      _ApplyRowSortIdx(
        forceApply: forceApplySortIdx,
        increase: increase,
        start: start,
        firstRow: refRows.first,
      ),
    ]);

    if (!applyList.apply) {
      return;
    }

    var rowLength = refRows.length;

    for (var rowIdx = 0; rowIdx < rowLength; rowIdx += 1) {
      applyList.execute(refRows[rowIdx]);
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
  cell,
  row,
  none,

  /// using only internal
  horizontal,
}

extension PlutoSelectingModeExtension on PlutoSelectingMode {
  bool get isCell => this == PlutoSelectingMode.cell;

  bool get isRow => this == PlutoSelectingMode.row;

  bool get isNone => this == PlutoSelectingMode.none;

  /// using only internal
  bool get isHorizontal => this == PlutoSelectingMode.horizontal;

  List<PlutoSelectingMode> get items {
    return [
      PlutoSelectingMode.cell,
      PlutoSelectingMode.row,
      PlutoSelectingMode.none,
    ];
  }

  String toShortString() {
    return toString().split('.').last;
  }
}

abstract class _Apply {
  bool get apply;

  void execute(PlutoRow row);
}

class _ApplyList implements _Apply {
  final List<_Apply> list;

  _ApplyList(this.list) {
    list.removeWhere((element) => !element.apply);
  }

  bool get apply => list.isNotEmpty;

  void execute(PlutoRow row) {
    var len = list.length;

    for (var i = 0; i < len; i += 1) {
      list[i].execute(row);
    }
  }
}

class _ApplyCellFormat implements _Apply {
  final List<PlutoColumn> refColumns;

  _ApplyCellFormat(
    this.refColumns,
  ) {
    assert(refColumns != null && refColumns.isNotEmpty);

    columnsToApply = refColumns
        .where((element) => element.type.applyFormatOnInit)
        .toList(growable: false);
  }

  List<PlutoColumn> columnsToApply;

  bool get apply => columnsToApply.isNotEmpty;

  void execute(PlutoRow row) {
    columnsToApply.forEach((column) {
      row.cells[column.field].value =
          column.type.applyFormat(row.cells[column.field].value);

      if (column.type.isNumber) {
        row.cells[column.field].value = num.tryParse(
              row.cells[column.field].value.replaceAll(',', ''),
            ) ??
            0;
      }
    });
  }
}

class _ApplyRowSortIdx implements _Apply {
  final bool forceApply;

  final bool increase;

  final int start;

  final PlutoRow firstRow;

  _ApplyRowSortIdx({
    @required this.forceApply,
    @required this.increase,
    @required this.start,
    @required this.firstRow,
  }) {
    assert(forceApply != null);
    assert(increase != null);
    assert(start != null);
    assert(firstRow != null);

    _sortIdx = start;
  }

  int _sortIdx;

  bool get apply => forceApply == true || firstRow.sortIdx == null;

  void execute(PlutoRow row) {
    row.sortIdx = _sortIdx;

    _sortIdx = increase ? ++_sortIdx : --_sortIdx;
  }
}
