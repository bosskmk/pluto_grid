import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'state/cell_state.dart';
import 'state/column_group_state.dart';
import 'state/column_sizing_state.dart';
import 'state/column_state.dart';
import 'state/dragging_row_state.dart';
import 'state/editing_state.dart';
import 'state/filtering_row_state.dart';
import 'state/focus_state.dart';
import 'state/grid_state.dart';
import 'state/keyboard_state.dart';
import 'state/layout_state.dart';
import 'state/pagination_row_state.dart';
import 'state/row_state.dart';
import 'state/scroll_state.dart';
import 'state/selecting_state.dart';
import 'state/visibility_layout_state.dart';

abstract class IPlutoGridState
    implements
        PlutoChangeNotifier,
        ICellState,
        IColumnGroupState,
        IColumnSizingState,
        IColumnState,
        IDraggingRowState,
        IEditingState,
        IFilteringRowState,
        IFocusState,
        IGridState,
        IKeyboardState,
        ILayoutState,
        IPaginationRowState,
        IRowState,
        IScrollState,
        ISelectingState,
        IVisibilityLayoutState {}

class PlutoGridStateChangeNotifier extends PlutoChangeNotifier
    with
        CellState,
        ColumnGroupState,
        ColumnSizingState,
        ColumnState,
        DraggingRowState,
        EditingState,
        FilteringRowState,
        FocusState,
        GridState,
        KeyboardState,
        LayoutState,
        PaginationRowState,
        RowState,
        ScrollState,
        SelectingState,
        VisibilityLayoutState {}

/// It manages the state of the [PlutoGrid] and contains methods used by the grid.
///
/// An instance of [PlutoGridStateManager] can be returned
/// through the [onLoaded] callback of the [PlutoGrid] constructor.
/// ```dart
/// PlutoGridStateManager stateManager;
///
/// PlutoGrid(
///   onLoaded: (PlutoGridOnLoadedEvent event) => stateManager = event.stateManager,
/// )
/// ```
/// {@template initialize_rows_sync_or_async}
/// It is created when [PlutoGrid] is first created,
/// and the state required for the grid is set for `List<PlutoRow> rows`.
/// [PlutoGridStateManager.initializeRows], which operates at this time, works synchronously,
/// and if there are many rows, the UI may freeze when starting the grid.
///
/// To prevent UI from freezing when passing many rows to [PlutoGrid],
/// you can set rows asynchronously as follows.
/// After passing an empty list when creating [PlutoGrid],
/// add rows initialized with [initializeRowsAsync] as shown below.
///
/// ```dart
/// PlutoGridStateManager.initializeRowsAsync(
///   columns,
///   fetchedRows,
/// ).then((value) {
///   stateManager.refRows.addAll(FilteredList(initialList: value));
///   stateManager.notifyListeners();
/// });
/// {@endtemplate}
/// ```
class PlutoGridStateManager extends PlutoGridStateChangeNotifier {
  PlutoGridStateManager({
    required List<PlutoColumn> columns,
    required List<PlutoRow> rows,
    required FocusNode? gridFocusNode,
    required PlutoGridScrollController? scroll,
    List<PlutoColumnGroup>? columnGroups,
    PlutoGridMode? mode,
    PlutoOnChangedEventCallback? onChangedEventCallback,
    PlutoOnSelectedEventCallback? onSelectedEventCallback,
    PlutoOnSortedEventCallback? onSortedEventCallback,
    PlutoOnRowCheckedEventCallback? onRowCheckedEventCallback,
    PlutoOnRowDoubleTapEventCallback? onRowDoubleTapEventCallback,
    PlutoOnRowSecondaryTapEventCallback? onRowSecondaryTapEventCallback,
    PlutoOnRowsMovedEventCallback? onRowsMovedEventCallback,
    PlutoRowColorCallback? onRowColorCallback,
    PlutoColumnMenuDelegate? columnMenuDelegate,
    CreateHeaderCallBack? createHeader,
    CreateFooterCallBack? createFooter,
    PlutoGridConfiguration? configuration,
  }) {
    refColumns = FilteredList(initialList: columns);
    refColumnGroups = FilteredList(initialList: columnGroups);
    refRows = FilteredList(initialList: rows);
    setGridFocusNode(gridFocusNode);
    setScroll(scroll);
    setGridMode(mode);
    setOnChanged(onChangedEventCallback);
    setOnSelected(onSelectedEventCallback);
    setOnSorted(onSortedEventCallback);
    setOnRowChecked(onRowCheckedEventCallback);
    setOnRowDoubleTap(onRowDoubleTapEventCallback);
    setOnRowSecondaryTap(onRowSecondaryTapEventCallback);
    setOnRowsMoved(onRowsMovedEventCallback);
    setRowColorCallback(onRowColorCallback);
    setColumnMenuDelegate(columnMenuDelegate);
    setCreateHeader(createHeader);
    setCreateFooter(createFooter);
    setConfiguration(configuration);
    setShowColumnFooter(
      columns.any((element) => element.footerRenderer != null),
    );
    setGridKey(GlobalKey());
  }

  static List<PlutoGridSelectingMode> get selectingModes =>
      PlutoGridSelectingMode.values;

  /// It handles the necessary settings when [rows] are first set or added to the [PlutoGrid].
  ///
  /// {@template initialize_rows_params}
  /// [forceApplySortIdx] determines whether to force PlutoRow.sortIdx to be set.
  /// [PlutoRow.sortIdx] does not reset if the value is already set.
  /// Set [forceApplySortIdx] to true to reset this value.
  ///
  /// [increase] determines whether to increment or decrement when initializing [sortIdx].
  /// For example, if a row is added before an existing row,
  /// the [sortIdx] value should be set to a negative number than the row being added.
  ///
  /// [start] sets the starting value when initializing [sortIdx].
  /// For example, if sortIdx is set from 0 to 9 in the previous 10 rows,
  /// [start] is set to 10, which sets the sortIdx of the row added at the end.
  /// {@endtemplate}
  ///
  /// {@macro initialize_rows_sync_or_async}
  static List<PlutoRow> initializeRows(
    List<PlutoColumn> refColumns,
    List<PlutoRow> refRows, {
    bool forceApplySortIdx = false,
    bool increase = true,
    int start = 0,
  }) {
    if (refColumns.isEmpty || refRows.isEmpty) {
      return refRows;
    }

    _ApplyList applyList = _ApplyList([
      _ApplyCellForSetColumnRow(refColumns),
      _ApplyCellForFormat(refColumns),
      _ApplyRowForSortIdx(
        forceApply: forceApplySortIdx,
        increase: increase,
        start: start,
        firstRow: refRows.first,
      ),
    ]);

    if (!applyList.apply) {
      return refRows;
    }

    var rowLength = refRows.length;

    for (var rowIdx = 0; rowIdx < rowLength; rowIdx += 1) {
      applyList.execute(refRows[rowIdx]);
    }

    return refRows;
  }

  /// An asynchronous version of [PlutoGridStateManager.initializeRows].
  ///
  /// [PlutoGridStateManager.initializeRowsAsync] repeats [Timer] every [duration],
  /// Process the setting of [refRows] by the size of [chunkSize].
  /// [Isolate] is a good way to handle CPU heavy work, but
  /// The condition that List<PlutoRow> cannot be passed to Isolate
  /// solves the problem of UI freezing by dividing the work with Timer.
  ///
  /// {@macro initialize_rows_params}
  ///
  /// [chunkSize] determines the number of lists processed at one time when setting rows.
  ///
  /// [duration] determines the processing interval when setting rows.
  ///
  /// If pagination is set, [PlutoGridStateManager.setPage] must be called
  /// after Future is completed before Rows appear on the screen.
  ///
  /// ```dart
  /// PlutoGridStateManager.initializeRowsAsync(columns, fetchedRows).then((initializedRows) {
  ///   stateManager.refRows.addAll(FilteredList(initialList: initializedRows));
  ///   stateManager.setPage(1, notify: false);
  ///   stateManager.notifyListeners();
  /// });
  /// ```
  ///
  /// {@macro initialize_rows_sync_or_async}
  static Future<List<PlutoRow>> initializeRowsAsync(
    List<PlutoColumn> refColumns,
    List<PlutoRow> refRows, {
    bool forceApplySortIdx = false,
    bool increase = true,
    int start = 0,
    int chunkSize = 100,
    Duration duration = const Duration(milliseconds: 1),
  }) {
    if (refColumns.isEmpty || refRows.isEmpty) {
      return Future.value(refRows);
    }

    assert(chunkSize > 0);

    final Completer<List<PlutoRow>> completer = Completer();

    SplayTreeMap<int, List<PlutoRow>> splayMapRows = SplayTreeMap();

    final Iterable<List<PlutoRow>> chunks = refRows.slices(chunkSize);

    final chunksLength = chunks.length;

    final List<int> chunksIndexes = List.generate(
      chunksLength,
      (index) => index,
    );

    Timer.periodic(duration, (timer) {
      if (chunksIndexes.isEmpty) {
        return;
      }

      final chunkIndex = chunksIndexes.removeLast();

      final chunk = chunks.elementAt(chunkIndex);

      Future(() {
        return PlutoGridStateManager.initializeRows(
          refColumns,
          chunk,
          forceApplySortIdx: forceApplySortIdx,
          increase: increase,
          start: start + (chunkIndex * chunkSize),
        );
      }).then((value) {
        splayMapRows[chunkIndex] = value;

        if (splayMapRows.length == chunksLength) {
          completer.complete(
            splayMapRows.values.expand((element) => element).toList(),
          );

          timer.cancel();
        }
      });
    });

    return completer.future;
  }
}

/// This is a class for handling horizontal and vertical scrolling of columns and rows of [PlutoGrid].
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
  int get hashCode => Object.hash(columnIdx, rowIdx);
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
  int get hashCode => Object.hash(field, rowIdx);
}

class PlutoGridKeyPressed {
  bool shift;

  bool ctrl;

  PlutoGridKeyPressed({
    this.shift = false,
    this.ctrl = false,
  });

  void reset() {
    shift = false;
    ctrl = false;
  }
}

/// A type of selection mode when you select a row or cell in a grid
/// by tapping and holding, then moving the pointer
/// or selecting a row or cell in the grid with controls or shift and tap.
///
/// [PlutoGridSelectingMode.cell] selects each cell.
///
/// [PlutoGridSelectingMode.row] selects row by row.
///
/// [PlutoGridSelectingMode.none] does nothing.
enum PlutoGridSelectingMode {
  cell,
  row,
  none,

  /// using only internal
  horizontal;

  bool get isCell => this == PlutoGridSelectingMode.cell;

  bool get isRow => this == PlutoGridSelectingMode.row;

  bool get isNone => this == PlutoGridSelectingMode.none;

  /// using only internal
  bool get isHorizontal => this == PlutoGridSelectingMode.horizontal;
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

  @override
  bool get apply => list.isNotEmpty;

  @override
  void execute(PlutoRow row) {
    var len = list.length;

    for (var i = 0; i < len; i += 1) {
      list[i].execute(row);
    }
  }
}

class _ApplyCellForSetColumnRow implements _Apply {
  final List<PlutoColumn> refColumns;

  _ApplyCellForSetColumnRow(this.refColumns);

  @override
  bool get apply => true;

  @override
  void execute(PlutoRow row) {
    for (var element in refColumns) {
      row.cells[element.field]!
        ..setColumn(element)
        ..setRow(row);
    }
  }
}

class _ApplyCellForFormat implements _Apply {
  final List<PlutoColumn> refColumns;

  _ApplyCellForFormat(
    this.refColumns,
  ) {
    assert(refColumns.isNotEmpty);

    columnsToApply = refColumns.where(
      (element) => element.type.applyFormatOnInit,
    );
  }

  late Iterable<PlutoColumn> columnsToApply;

  @override
  bool get apply => columnsToApply.isNotEmpty;

  @override
  void execute(PlutoRow row) {
    for (var column in columnsToApply) {
      var value = column.type.applyFormat(row.cells[column.field]!.value);

      if (column.type is PlutoColumnTypeWithNumberFormat) {
        value =
            (column.type as PlutoColumnTypeWithNumberFormat).toNumber(value);
      }

      row.cells[column.field]!.value = value;
    }
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

  @override
  bool get apply => forceApply == true || firstRow!.sortIdx == null;

  @override
  void execute(PlutoRow? row) {
    row!.sortIdx = _sortIdx;

    _sortIdx = increase ? ++_sortIdx : --_sortIdx;
  }
}
