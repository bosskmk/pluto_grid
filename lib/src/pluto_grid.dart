import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoGrid extends StatefulWidget {
  const PlutoGrid({
    Key? key,
    required this.columns,
    required this.rows,
    this.columnGroups,
    this.onLoaded,
    this.onChanged,
    this.onSelected,
    this.onRowChecked,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.onRowsMoved,
    this.createHeader,
    this.createFooter,
    this.rowColorCallback,
    this.configuration,
    this.mode = PlutoGridMode.normal,
  }) : super(key: key);

  final List<PlutoColumn> columns;

  final List<PlutoRow> rows;

  final List<PlutoColumnGroup>? columnGroups;

  final PlutoOnLoadedEventCallback? onLoaded;

  final PlutoOnChangedEventCallback? onChanged;

  final PlutoOnSelectedEventCallback? onSelected;

  final PlutoOnRowCheckedEventCallback? onRowChecked;

  final PlutoOnRowDoubleTapEventCallback? onRowDoubleTap;

  final PlutoOnRowSecondaryTapEventCallback? onRowSecondaryTap;

  final PlutoOnRowsMovedEventCallback? onRowsMoved;

  final CreateHeaderCallBack? createHeader;

  final CreateFooterCallBack? createFooter;

  final PlutoRowColorCallback? rowColorCallback;

  final PlutoGridConfiguration? configuration;

  /// [PlutoGridMode.normal]
  /// Normal grid with cell editing.
  ///
  /// [PlutoGridMode.select]
  /// Editing is not possible, and if you press enter or tap on the list,
  /// you can receive the selected row and cell from the onSelected callback.
  final PlutoGridMode? mode;

  @override
  _PlutoGridState createState() => _PlutoGridState();
}

class _PlutoGridState extends State<PlutoGrid> {
  FocusNode? _gridFocusNode;

  final LinkedScrollControllerGroup _verticalScroll =
      LinkedScrollControllerGroup();

  final LinkedScrollControllerGroup _horizontalScroll =
      LinkedScrollControllerGroup();

  final List<Function()> _disposeList = [];

  late PlutoGridStateManager _stateManager;

  PlutoGridKeyManager? _keyManager;

  PlutoGridEventManager? _eventManager;

  bool? _showFrozenColumn;

  bool? _hasLeftFrozenColumns;

  double? _bodyLeftOffset;

  double? _bodyRightOffset;

  bool? _hasRightFrozenColumns;

  double? _rightFrozenLeftOffset;

  bool? _showColumnGroups;

  bool? _showColumnFilter;

  bool? _showLoading;

  Widget? _header;

  Widget? _footer;

  final _stackKeys = {
    _StackName.header: UniqueKey(),
    _StackName.headerDivider: UniqueKey(),
    _StackName.leftFrozenColumns: UniqueKey(),
    _StackName.leftFrozenRows: UniqueKey(),
    _StackName.leftFrozenDivider: UniqueKey(),
    _StackName.bodyColumns: UniqueKey(),
    _StackName.bodyRows: UniqueKey(),
    _StackName.rightFrozenColumns: UniqueKey(),
    _StackName.rightFrozenRows: UniqueKey(),
    _StackName.rightFrozenDivider: UniqueKey(),
    _StackName.columnRowDivider: UniqueKey(),
    _StackName.footer: UniqueKey(),
    _StackName.footerDivider: UniqueKey(),
    _StackName.loading: UniqueKey(),
  };

  get _headerStack => Positioned.fill(
        bottom: _stateManager.headerBottomOffset,
        child: _header!,
        key: _stackKeys[_StackName.header],
      );

  get _headerDividerStack => Positioned(
        top: _stateManager.headerHeight,
        left: 0,
        right: 0,
        child: PlutoShadowLine(
          axis: Axis.horizontal,
          color: _stateManager.configuration!.gridBorderColor,
          shadow: _stateManager.configuration!.enableGridBorderShadow,
        ),
        key: _stackKeys[_StackName.headerDivider],
      );

  get _leftFrozenColumnsStack => Positioned.fill(
        top: _stateManager.headerHeight,
        right: _stateManager.leftFrozenRightOffset,
        bottom: _stateManager.columnBottomOffset,
        child: PlutoLeftFrozenColumns(_stateManager),
        key: _stackKeys[_StackName.leftFrozenColumns],
      );

  get _leftFrozenRowsStack => Positioned.fill(
        top: _stateManager.rowsTopOffset,
        right: _stateManager.leftFrozenRightOffset,
        bottom: _stateManager.footerHeight,
        child: PlutoLeftFrozenRows(_stateManager),
        key: _stackKeys[_StackName.leftFrozenRows],
      );

  get _bodyColumnsStack => Positioned.fill(
        top: _stateManager.headerHeight,
        left: _bodyLeftOffset,
        right: _bodyRightOffset,
        bottom: _stateManager.columnBottomOffset,
        child: PlutoBodyColumns(_stateManager),
        key: _stackKeys[_StackName.bodyColumns],
      );

  get _bodyRowsStack => Positioned.fill(
        top: _stateManager.rowsTopOffset,
        left: _bodyLeftOffset,
        right: _bodyRightOffset,
        bottom: _stateManager.footerHeight,
        child: PlutoBodyRows(_stateManager),
        key: _stackKeys[_StackName.bodyRows],
      );

  get _rightFrozenColumnsStack => Positioned.fill(
        top: _stateManager.headerHeight,
        left: _rightFrozenLeftOffset,
        bottom: _stateManager.columnBottomOffset,
        child: PlutoRightFrozenColumns(_stateManager),
        key: _stackKeys[_StackName.rightFrozenColumns],
      );

  get _rightFrozenRowsStack => Positioned.fill(
        top: _stateManager.rowsTopOffset,
        left: _rightFrozenLeftOffset,
        bottom: _stateManager.footerHeight,
        child: PlutoRightFrozenRows(_stateManager),
        key: _stackKeys[_StackName.rightFrozenRows],
      );

  get _leftFrozenDividerStack => Positioned(
        top: _stateManager.headerHeight,
        left: _bodyLeftOffset! - PlutoGridSettings.gridBorderWidth,
        bottom: _stateManager.footerHeight,
        child: PlutoShadowLine(
          axis: Axis.vertical,
          color: _stateManager.configuration!.gridBorderColor,
          shadow: _stateManager.configuration!.enableGridBorderShadow,
        ),
        key: _stackKeys[_StackName.leftFrozenDivider],
      );

  get _rightFrozenDividerStack => Positioned(
        top: _stateManager.headerHeight,
        left: _rightFrozenLeftOffset! - PlutoGridSettings.gridBorderWidth,
        bottom: _stateManager.footerHeight,
        child: PlutoShadowLine(
          axis: Axis.vertical,
          reverse: true,
          color: _stateManager.configuration!.gridBorderColor,
          shadow: _stateManager.configuration!.enableGridBorderShadow,
        ),
        key: _stackKeys[_StackName.rightFrozenDivider],
      );

  get _columnRowDividerStack => Positioned(
        top: _stateManager.rowsTopOffset - PlutoGridSettings.gridBorderWidth,
        left: 0,
        right: 0,
        child: PlutoShadowLine(
          axis: Axis.horizontal,
          color: _stateManager.configuration!.gridBorderColor,
          shadow: _stateManager.configuration!.enableGridBorderShadow,
        ),
        key: _stackKeys[_StackName.columnRowDivider],
      );

  get _footerDividerStack => Positioned(
        top: _stateManager.footerTopOffset,
        left: 0,
        right: 0,
        child: PlutoShadowLine(
          axis: Axis.horizontal,
          reverse: true,
          color: _stateManager.configuration!.gridBorderColor,
          shadow: _stateManager.configuration!.enableGridBorderShadow,
        ),
        key: _stackKeys[_StackName.footerDivider],
      );

  get _footerStack => Positioned.fill(
        top: _stateManager.footerTopOffset,
        child: _footer!,
        key: _stackKeys[_StackName.footer],
      );

  get _loadingStack => Positioned.fill(
        child: PlutoLoading(
          backgroundColor: _stateManager.configuration!.gridBackgroundColor,
          indicatorColor: _stateManager.configuration!.cellTextStyle.color,
          indicatorText: _stateManager.configuration!.localeText.loadingText,
          indicatorSize: _stateManager.configuration!.cellTextStyle.fontSize,
        ),
        key: _stackKeys[_StackName.loading],
      );

  @override
  void dispose() {
    for (var dispose in _disposeList) {
      dispose();
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _initProperties();

    _initStateManager();

    _initKeyManager();

    _initEventManager();

    _initOnLoadedEvent();

    _initSelectMode();

    _initHeaderFooter();
  }

  void _initProperties() {
    _gridFocusNode = FocusNode();

    // Dispose
    _disposeList.add(() {
      _gridFocusNode!.dispose();
    });
  }

  void _initStateManager() {
    _stateManager = PlutoGridStateManager(
      columns: widget.columns,
      rows: widget.rows,
      gridFocusNode: _gridFocusNode,
      scroll: PlutoGridScrollController(
        vertical: _verticalScroll,
        horizontal: _horizontalScroll,
      ),
      columnGroups: widget.columnGroups,
      mode: widget.mode,
      onChangedEventCallback: widget.onChanged,
      onSelectedEventCallback: widget.onSelected,
      onRowCheckedEventCallback: widget.onRowChecked,
      onRowDoubleTapEventCallback: widget.onRowDoubleTap,
      onRowSecondaryTapEventCallback: widget.onRowSecondaryTap,
      onRowsMovedEventCallback: widget.onRowsMoved,
      createHeader: widget.createHeader,
      createFooter: widget.createFooter,
      configuration: widget.configuration,
    );

    _stateManager.addListener(_changeStateListener);

    _stateManager.setRowColorCallback(widget.rowColorCallback);

    // Dispose
    _disposeList.add(() {
      _stateManager.removeListener(_changeStateListener);
      _stateManager.dispose();
    });
  }

  void _initKeyManager() {
    _keyManager = PlutoGridKeyManager(
      stateManager: _stateManager,
    );

    _keyManager!.init();

    _stateManager.setKeyManager(_keyManager);

    // Dispose
    _disposeList.add(() {
      _keyManager!.dispose();
    });
  }

  void _initEventManager() {
    _eventManager = PlutoGridEventManager(
      stateManager: _stateManager,
    );

    _eventManager!.init();

    _stateManager.setEventManager(_eventManager);

    // Dispose
    _disposeList.add(() {
      _eventManager!.dispose();
    });
  }

  void _initOnLoadedEvent() {
    if (widget.onLoaded == null) {
      return;
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      widget.onLoaded!(PlutoGridOnLoadedEvent(
        stateManager: _stateManager,
      ));
    });
  }

  void _initSelectMode() {
    if (widget.mode.isSelect != true) {
      return;
    }

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (_stateManager.currentCell == null && widget.rows.isNotEmpty) {
        _stateManager.setCurrentCell(
            widget.rows.first.cells.entries.first.value, 0);
      }

      _stateManager.gridFocusNode!.requestFocus();
    });
  }

  void _initHeaderFooter() {
    if (_stateManager.showHeader) {
      _header = _stateManager.createHeader!(_stateManager);
    }

    if (_stateManager.showFooter) {
      _footer = _stateManager.createFooter!(_stateManager);
    }

    if (_header is PlutoPagination || _footer is PlutoPagination) {
      _stateManager.setPage(1, notify: false);
    }
  }

  void _changeStateListener() {
    if (_showFrozenColumn != _stateManager.showFrozenColumn ||
        _hasLeftFrozenColumns != _stateManager.hasLeftFrozenColumns ||
        _bodyLeftOffset != _stateManager.bodyLeftOffset ||
        _bodyRightOffset != _stateManager.bodyRightOffset ||
        _hasRightFrozenColumns != _stateManager.hasRightFrozenColumns ||
        _rightFrozenLeftOffset != _stateManager.rightFrozenLeftOffset ||
        _showColumnGroups != _stateManager.showColumnGroups ||
        _showColumnFilter != _stateManager.showColumnFilter ||
        _showLoading != _stateManager.showLoading) {
      setState(_resetState);
    }
  }

  KeyEventResult _handleGridFocusOnKey(FocusNode focusNode, RawKeyEvent event) {
    /// 2021-11-19
    /// KeyEventResult.skipRemainingHandlers 동작 오류로 인한 임시 코드
    /// 이슈 해결 후 :
    /// ```dart
    /// keyManager!.subject.add(PlutoKeyManagerEvent(
    ///   focusNode: focusNode,
    ///   event: event,
    /// ));
    /// ```
    if (_keyManager!.eventResult.isSkip == false) {
      _keyManager!.subject.add(PlutoKeyManagerEvent(
        focusNode: focusNode,
        event: event,
      ));
    }

    /// 2021-11-19
    /// KeyEventResult.skipRemainingHandlers 동작 오류로 인한 임시 코드
    /// 이슈 해결 후 :
    /// ```dart
    /// return KeyEventResult.handled;
    /// ```
    return _keyManager!.eventResult.consume(KeyEventResult.handled);
  }

  void _setLayout(BoxConstraints size) {
    _stateManager.setLayout(size);

    _resetState();
  }

  void _resetState() {
    _showFrozenColumn = _stateManager.showFrozenColumn;

    _hasLeftFrozenColumns = _stateManager.hasLeftFrozenColumns;

    _bodyLeftOffset = _stateManager.bodyLeftOffset;

    _bodyRightOffset = _stateManager.bodyRightOffset;

    _hasRightFrozenColumns = _stateManager.hasRightFrozenColumns;

    _rightFrozenLeftOffset = _stateManager.rightFrozenLeftOffset;

    _showColumnGroups = _stateManager.showColumnGroups;

    _showColumnFilter = _stateManager.showColumnFilter;

    _showLoading = _stateManager.showLoading;
  }

  Widget _builder(BuildContext ctx, BoxConstraints size) {
    _setLayout(size);

    if (_stateManager.keepFocus) {
      _gridFocusNode?.requestFocus();
    }

    final List<Widget> stack = [];

    if (_stateManager.showHeader) {
      stack.add(_headerStack);
      stack.add(_headerDividerStack);
    }

    if (_showFrozenColumn! && _hasLeftFrozenColumns!) {
      stack.add(_leftFrozenColumnsStack);
      stack.add(_leftFrozenRowsStack);
      stack.add(_leftFrozenDividerStack);
    }

    stack.add(_bodyColumnsStack);
    stack.add(_bodyRowsStack);
    stack.add(_columnRowDividerStack);

    if (_showFrozenColumn! && _hasRightFrozenColumns!) {
      stack.add(_rightFrozenColumnsStack);
      stack.add(_rightFrozenRowsStack);
      stack.add(_rightFrozenDividerStack);
    }

    if (_stateManager.showFooter) {
      stack.add(_footerStack);
      stack.add(_footerDividerStack);
    }

    if (_stateManager.showLoading) {
      stack.add(_loadingStack);
    }

    return _GridContainer(
      stateManager: _stateManager,
      child: Stack(
        children: stack,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      onFocusChange: _stateManager.setKeepFocus,
      onKey: _handleGridFocusOnKey,
      child: SafeArea(
        child: LayoutBuilder(key: _stateManager.gridKey, builder: _builder),
      ),
    );
  }
}

class _GridContainer extends StatelessWidget {
  final PlutoGridStateManager stateManager;

  final Widget child;

  const _GridContainer({
    required this.stateManager,
    required this.child,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final configuration = stateManager.configuration!;

    return Focus(
      focusNode: stateManager.gridFocusNode,
      child: ScrollConfiguration(
        behavior: const PlutoScrollBehavior().copyWith(
          scrollbars: false,
        ),
        child: Container(
          padding: const EdgeInsets.all(PlutoGridSettings.gridPadding),
          decoration: BoxDecoration(
            color: configuration.gridBackgroundColor,
            borderRadius: configuration.gridBorderRadius,
            border: Border.all(
              color: configuration.gridBorderColor,
              width: PlutoGridSettings.gridBorderWidth,
            ),
          ),
          child: ClipRRect(
            borderRadius:
                configuration.gridBorderRadius.resolve(TextDirection.ltr),
            child: child,
          ),
        ),
      ),
    );
  }
}

class PlutoGridOnLoadedEvent {
  final PlutoGridStateManager stateManager;

  PlutoGridOnLoadedEvent({
    required this.stateManager,
  });
}

/// Caution
///
/// [columnIdx] and [rowIdx] are values in the currently displayed state.
class PlutoGridOnChangedEvent {
  final int? columnIdx;
  final PlutoColumn? column;
  final int? rowIdx;
  final PlutoRow? row;
  final dynamic value;
  final dynamic oldValue;

  PlutoGridOnChangedEvent({
    this.columnIdx,
    this.column,
    this.rowIdx,
    this.row,
    this.value,
    this.oldValue,
  });

  @override
  String toString() {
    String out = '[PlutoOnChangedEvent] ';
    out += 'ColumnIndex : $columnIdx, RowIndex : $rowIdx\n';
    out += '::: oldValue : $oldValue\n';
    out += '::: newValue : $value';
    return out;
  }
}

class PlutoGridOnSelectedEvent {
  final PlutoRow? row;
  final PlutoCell? cell;

  PlutoGridOnSelectedEvent({
    this.row,
    this.cell,
  });
}

abstract class PlutoGridOnRowCheckedEvent {
  bool get isAll => runtimeType == PlutoGridOnRowCheckedAllEvent;
  bool get isRow => runtimeType == PlutoGridOnRowCheckedOneEvent;

  final PlutoRow? row;
  final bool? isChecked;

  PlutoGridOnRowCheckedEvent({
    this.row,
    this.isChecked,
  });
}

class PlutoGridOnRowDoubleTapEvent {
  final PlutoRow? row;
  final PlutoCell? cell;

  PlutoGridOnRowDoubleTapEvent({
    this.row,
    this.cell,
  });
}

class PlutoGridOnRowSecondaryTapEvent {
  final PlutoRow? row;
  final PlutoCell? cell;
  final Offset? offset;

  PlutoGridOnRowSecondaryTapEvent({
    this.row,
    this.cell,
    this.offset,
  });
}

class PlutoGridOnRowsMovedEvent {
  final int? idx;
  final List<PlutoRow?>? rows;

  PlutoGridOnRowsMovedEvent({
    required this.idx,
    required this.rows,
  });
}

class PlutoGridOnRowCheckedOneEvent extends PlutoGridOnRowCheckedEvent {
  PlutoGridOnRowCheckedOneEvent({
    PlutoRow? row,
    bool? isChecked,
  }) : super(row: row, isChecked: isChecked);
}

class PlutoGridOnRowCheckedAllEvent extends PlutoGridOnRowCheckedEvent {
  PlutoGridOnRowCheckedAllEvent({
    bool? isChecked,
  }) : super(row: null, isChecked: isChecked);
}

class PlutoScrollBehavior extends MaterialScrollBehavior {
  const PlutoScrollBehavior() : super();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class PlutoRowColorContext {
  final PlutoRow row;

  final int rowIdx;

  final PlutoGridStateManager stateManager;

  PlutoRowColorContext({
    required this.row,
    required this.rowIdx,
    required this.stateManager,
  });
}

enum PlutoGridMode {
  normal,
  select,
  selectWithOneTap,
  popup,
}

extension PlutoGridModeExtension on PlutoGridMode? {
  bool get isNormal => this == PlutoGridMode.normal;

  bool get isSelect =>
      this == PlutoGridMode.select || this == PlutoGridMode.selectWithOneTap;

  bool get isSelectModeWithOneTap => this == PlutoGridMode.selectWithOneTap;

  bool get isPopup => this == PlutoGridMode.popup;
}

enum _StackName {
  header,
  headerDivider,
  leftFrozenColumns,
  leftFrozenRows,
  leftFrozenDivider,
  bodyColumns,
  bodyRows,
  rightFrozenColumns,
  rightFrozenRows,
  rightFrozenDivider,
  columnRowDivider,
  footer,
  footerDivider,
  loading,
}

class PlutoGridSettings {
  /// If there is a frozen column, the minimum width of the body
  /// (if it is less than the value, the frozen column is released)
  static const double bodyMinWidth = 200.0;

  /// Default column width
  static const double columnWidth = 200.0;

  /// Column width
  static const double minColumnWidth = 80.0;

  /// Frozen column division line (ShadowLine) size
  static const double shadowLineSize = 3.0;

  /// Sum of frozen column division line width
  static const double totalShadowLineWidth =
      PlutoGridSettings.shadowLineSize * 2;

  /// Grid - padding
  static const double gridPadding = 2.0;

  /// Grid - border width
  static const double gridBorderWidth = 1.0;

  static const double gridInnerSpacing =
      (gridPadding * 2) + (gridBorderWidth * 2);

  /// Row - Default row height
  static const double rowHeight = 45.0;

  /// Row - border width
  static const double rowBorderWidth = 1.0;

  /// Row - total height
  static const double rowTotalHeight = rowHeight + rowBorderWidth;

  /// Cell - padding
  static const double cellPadding = 10;

  /// Column title - padding
  static const double columnTitlePadding = 10;

  /// Cell - fontSize
  static const double cellFontSize = 14;

  /// Scroll when multi-selection is as close as that value from the edge
  static const double offsetScrollingFromEdge = 10.0;

  /// Size that scrolls from the edge at once when selecting multiple
  static const double offsetScrollingFromEdgeAtOnce = 200.0;

  static const int debounceMillisecondsForColumnFilter = 300;
}

typedef PlutoOnLoadedEventCallback = void Function(
    PlutoGridOnLoadedEvent event);

typedef PlutoOnChangedEventCallback = void Function(
    PlutoGridOnChangedEvent event);

typedef PlutoOnSelectedEventCallback = void Function(
    PlutoGridOnSelectedEvent event);

typedef PlutoOnRowCheckedEventCallback = void Function(
    PlutoGridOnRowCheckedEvent event);

typedef PlutoOnRowDoubleTapEventCallback = void Function(
    PlutoGridOnRowDoubleTapEvent event);

typedef PlutoOnRowSecondaryTapEventCallback = void Function(
    PlutoGridOnRowSecondaryTapEvent event);

typedef PlutoOnRowsMovedEventCallback = void Function(
    PlutoGridOnRowsMovedEvent event);

typedef CreateHeaderCallBack = Widget Function(
    PlutoGridStateManager stateManager);

typedef CreateFooterCallBack = Widget Function(
    PlutoGridStateManager stateManager);

typedef PlutoRowColorCallback = Color Function(
    PlutoRowColorContext rowColorContext);
