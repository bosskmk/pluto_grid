import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:pluto_filtered_list/pluto_filtered_list.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/manager/state/optimisation_state.dart';

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

abstract class IPlutoGridState extends PlutoChangeNotifier
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
        ISelectingState,
        IOptimisationState {}

class PlutoGridState extends PlutoChangeNotifier
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
        SelectingState,
        OptimisationState {}

class PlutoGridStateManager extends PlutoGridState {
  PlutoGridStateManager({
    required List<PlutoColumn>? columns,
    required List<PlutoRow?>? rows,
    required FocusNode? gridFocusNode,
    required PlutoGridScrollController? scroll,
    PlutoGridMode? mode,
    PlutoOnChangedEventCallback? onChangedEventCallback,
    PlutoOnSelectedEventCallback? onSelectedEventCallback,
    PlutoOnRowCheckedEventCallback? onRowCheckedEventCallback,
    PlutoOnRowDoubleTapEventCallback? onRowDoubleTapEventCallback,
    PlutoOnRowSecondaryTapEventCallback? onRowSecondaryTapEventCallback,
    CreateHeaderCallBack? createHeader,
    CreateFooterCallBack? createFooter,
    PlutoGridConfiguration? configuration,
    bool? showColumnFilter,
  }) {
    refColumns = FilteredList(initialList: columns);
    refRows = FilteredList(initialList: rows);
    if (showColumnFilter != null) setShowColumnFilter(showColumnFilter);
    setGridFocusNode(gridFocusNode);
    setScroll(scroll);
    setGridMode(mode);
    setOnChanged(onChangedEventCallback);
    setOnSelected(onSelectedEventCallback);
    setOnRowChecked(onRowCheckedEventCallback);
    setOnRowDoubleTap(onRowDoubleTapEventCallback);
    setOnRowSecondaryTap(onRowSecondaryTapEventCallback);
    setCreateHeader(createHeader);
    setCreateFooter(createFooter);
    setConfiguration(configuration);
    setGridKey(GlobalKey());
  }

  static List<PlutoGridSelectingMode> get selectingModes => PlutoGridSelectingMode.none.items;

  static void initializeRows(
    List<PlutoColumn>? refColumns,
    List<PlutoRow?>? refRows, {
    bool forceApplySortIdx = false,
    bool increase = true,
    int? start = 0,
  }) {
    if (refColumns == null || refColumns.isEmpty || refRows == null || refRows.isEmpty) {
      return;
    }

    _ApplyList applyList = _ApplyList([
      _ApplyCellForSetColumn(refColumns),
      _ApplyCellForFormat(refColumns),
      _ApplyRowForSortIdx(
        forceApply: forceApplySortIdx,
        increase: increase,
        start: start ?? 0,
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

class PlutoGridScrollController {
  LinkedScrollControllerGroup? vertical;

  LinkedScrollControllerGroup? horizontal;

  PlutoGridScrollController({
    this.vertical,
    this.horizontal,
  });

  ScrollController? get bodyRowsHorizontal => _bodyRowsHorizontal;

  ScrollController? _bodyRowsHorizontal;

  ScrollController? get bodyRowsVertical => _bodyRowsVertical;

  ScrollController? _bodyRowsVertical;

  double get maxScrollHorizontal {
    assert(_bodyRowsHorizontal != null);

    return _bodyRowsHorizontal!.position.maxScrollExtent;
  }

  double get maxScrollVertical {
    assert(_bodyRowsVertical != null);

    return _bodyRowsVertical!.position.maxScrollExtent;
  }

  double get verticalOffset => vertical!.offset;

  double get horizontalOffset => horizontal!.offset;

  void setBodyRowsHorizontal(ScrollController? scrollController) {
    _bodyRowsHorizontal = scrollController;
  }

  void setBodyRowsVertical(ScrollController? scrollController) {
    _bodyRowsVertical = scrollController;
  }
}

class PlutoGridCellPosition {
  int? columnIdx;
  int? rowIdx;

  PlutoGridCellPosition({
    this.columnIdx,
    this.rowIdx,
  });

  @override
  bool operator ==(covariant PlutoGridCellPosition other) {
    return columnIdx == other.columnIdx && rowIdx == other.rowIdx;
  }

  @override
  int get hashCode => super.hashCode;
}

class PlutoGridSelectingCellPosition {
  String? field;
  int? rowIdx;

  PlutoGridSelectingCellPosition({
    this.field,
    this.rowIdx,
  });

  @override
  bool operator ==(covariant PlutoGridSelectingCellPosition other) {
    return field == other.field && rowIdx == other.rowIdx;
  }

  @override
  int get hashCode => super.hashCode;
}

class PlutoGridKeyPressed {
  bool shift;

  bool ctrl;

  PlutoGridKeyPressed({
    this.shift = false,
    this.ctrl = false,
  });
}

enum PlutoGridSelectingMode {
  cell,
  row,
  none,

  /// using only internal
  horizontal,
}

extension PlutoGridSelectingModeExtension on PlutoGridSelectingMode {
  bool get isCell => this == PlutoGridSelectingMode.cell;

  bool get isRow => this == PlutoGridSelectingMode.row;

  bool get isNone => this == PlutoGridSelectingMode.none;

  /// using only internal
  bool get isHorizontal => this == PlutoGridSelectingMode.horizontal;

  List<PlutoGridSelectingMode> get items {
    return [
      PlutoGridSelectingMode.cell,
      PlutoGridSelectingMode.row,
      PlutoGridSelectingMode.none,
    ];
  }

  String toShortString() {
    return toString().split('.').last;
  }
}

abstract class _Apply {
  bool get apply;

  void execute(PlutoRow? row);
}

class _ApplyList implements _Apply {
  final List<_Apply> list;

  _ApplyList(this.list) {
    list.removeWhere((element) => !element.apply);
  }

  bool get apply => list.isNotEmpty;

  void execute(PlutoRow? row) {
    var len = list.length;

    for (var i = 0; i < len; i += 1) {
      list[i].execute(row);
    }
  }
}

class _ApplyCellForSetColumn implements _Apply {
  final List<PlutoColumn> refColumns;

  _ApplyCellForSetColumn(this.refColumns);

  bool get apply => true;

  void execute(PlutoRow? row) {
    refColumns.forEach((element) {
      try {
        row!.cells[element.field]!.setColumn(element);
      } catch (err, stack) {
        print('Error Access Field: (${element.field})');
        rethrow;
      }
    });
  }
}

class _ApplyCellForFormat implements _Apply {
  final List<PlutoColumn> refColumns;

  _ApplyCellForFormat(
    this.refColumns,
  ) {
    assert(refColumns.isNotEmpty);

    columnsToApply = refColumns.where((element) => element.type.applyFormatOnInit!).toList(growable: false);
  }

  late List<PlutoColumn> columnsToApply;

  bool get apply => columnsToApply.isNotEmpty;

  void execute(PlutoRow? row) {
    columnsToApply.forEach((column) {
      row!.cells[column.field]!.value = column.type.applyFormat(row.cells[column.field]!.value);

      if (column.type.isNumber) {
        row.cells[column.field]!.value = num.tryParse(
              row.cells[column.field]!.value.toString().replaceAll(',', ''),
            ) ??
            0;
      }
    });
  }
}

class _ApplyRowForSortIdx implements _Apply {
  final bool forceApply;

  final bool increase;

  final int start;

  final PlutoRow? firstRow;

  _ApplyRowForSortIdx({
    required this.forceApply,
    required this.increase,
    required this.start,
    required this.firstRow,
  }) {
    assert(firstRow != null);

    _sortIdx = start;
  }

  late int _sortIdx;

  bool get apply => forceApply == true || firstRow!.sortIdx == null;

  void execute(PlutoRow? row) {
    row!.sortIdx = _sortIdx;

    _sortIdx = increase ? ++_sortIdx : --_sortIdx;
  }
}
