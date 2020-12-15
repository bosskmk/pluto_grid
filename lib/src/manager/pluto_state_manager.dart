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
