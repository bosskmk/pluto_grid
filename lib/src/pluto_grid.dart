import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:pluto_grid/pluto_grid.dart';

typedef PlutoOnLoadedEventCallback = void Function(PlutoOnLoadedEvent event);

typedef PlutoOnChangedEventCallback = void Function(PlutoOnChangedEvent event);

typedef PlutoOnSelectedEventCallback = void Function(
    PlutoOnSelectedEvent event);

typedef CreateHeaderCallBack = Widget Function(PlutoStateManager stateManager);

typedef CreateFooterCallBack = Widget Function(PlutoStateManager stateManager);

class PlutoGrid extends StatefulWidget {
  final List<PlutoColumn> columns;

  final List<PlutoRow> rows;

  final PlutoOnLoadedEventCallback onLoaded;

  final PlutoOnChangedEventCallback onChanged;

  final PlutoOnSelectedEventCallback onSelected;

  final CreateHeaderCallBack createHeader;

  final CreateFooterCallBack createFooter;

  final PlutoConfiguration configuration;

  /// [PlutoGridMode.normal]
  /// Normal grid with cell editing.
  ///
  /// [PlutoGridMode.select]
  /// Editing is not possible, and if you press enter or tap on the list,
  /// you can receive the selected row and cell from the onSelected callback.
  final PlutoGridMode mode;

  const PlutoGrid({
    Key key,
    @required this.columns,
    @required this.rows,
    this.onLoaded,
    this.onChanged,
    this.onSelected,
    this.createHeader,
    this.createFooter,
    this.configuration,
    this.mode = PlutoGridMode.normal,
  }) : super(key: key);

  @override
  _PlutoGridState createState() => _PlutoGridState();
}

class _PlutoGridState extends State<PlutoGrid> {
  FocusNode gridFocusNode;

  LinkedScrollControllerGroup verticalScroll = LinkedScrollControllerGroup();

  LinkedScrollControllerGroup horizontalScroll = LinkedScrollControllerGroup();

  PlutoStateManager stateManager;

  PlutoKeyManager keyManager;

  PlutoEventManager eventManager;

  bool _showFrozenColumn;
  bool _hasLeftFrozenColumns;
  double _bodyLeftOffset;
  double _bodyRightOffset;
  bool _hasRightFrozenColumns;
  double _rightFrozenLeftOffset;
  bool _showColumnFilter;
  bool _showLoading;

  List<Function()> disposeList = [];

  @override
  void dispose() {
    disposeList.forEach((dispose) {
      dispose();
    });

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    initProperties();

    initStateManager();

    initKeyManager();

    initEventManager();

    initOnLoadedEvent();

    initSelectMode();
  }

  void initProperties() {
    gridFocusNode = FocusNode(onKey: handleGridFocusOnKey);

    // Dispose
    disposeList.add(() {
      gridFocusNode.dispose();
    });
  }

  void initStateManager() {
    stateManager = PlutoStateManager(
      columns: widget.columns,
      rows: widget.rows,
      gridFocusNode: gridFocusNode,
      scroll: PlutoScrollController(
        vertical: verticalScroll,
        horizontal: horizontalScroll,
      ),
      mode: widget.mode,
      onChangedEventCallback: widget.onChanged,
      onSelectedEventCallback: widget.onSelected,
      createHeader: widget.createHeader,
      createFooter: widget.createFooter,
      configuration: widget.configuration,
    );

    stateManager.addListener(changeStateListener);

    // Dispose
    disposeList.add(() {
      stateManager.removeListener(changeStateListener);
      stateManager.dispose();
    });
  }

  void initKeyManager() {
    keyManager = PlutoKeyManager(
      stateManager: stateManager,
    );

    keyManager.init();

    stateManager.setKeyManager(keyManager);

    // Dispose
    disposeList.add(() {
      keyManager.dispose();
    });
  }

  void initEventManager() {
    eventManager = PlutoEventManager(
      stateManager: stateManager,
    );

    eventManager.init();

    stateManager.setEventManager(eventManager);

    // Dispose
    disposeList.add(() {
      eventManager.dispose();
    });
  }

  void initOnLoadedEvent() {
    if (widget.onLoaded == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onLoaded(PlutoOnLoadedEvent(
        stateManager: stateManager,
      ));
    });
  }

  void initSelectMode() {
    if (widget.mode.isSelect != true) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (stateManager.currentCell == null && widget.rows.isNotEmpty) {
        stateManager.setCurrentCell(
            widget.rows.first.cells.entries.first.value, 0);
      }

      stateManager.gridFocusNode.requestFocus();
    });
  }

  void changeStateListener() {
    if (_showFrozenColumn != stateManager.showFrozenColumn ||
        _hasLeftFrozenColumns != stateManager.hasLeftFrozenColumns ||
        _bodyLeftOffset != stateManager.bodyLeftOffset ||
        _bodyRightOffset != stateManager.bodyRightOffset ||
        _hasRightFrozenColumns != stateManager.hasRightFrozenColumns ||
        _rightFrozenLeftOffset != stateManager.rightFrozenLeftOffset ||
        _showColumnFilter != stateManager.showColumnFilter ||
        _showLoading != stateManager.showLoading) {
      setState(resetState);
    }
  }

  bool handleGridFocusOnKey(FocusNode focusNode, RawKeyEvent event) {
    keyManager.subject.add(KeyManagerEvent(
      focusNode: focusNode,
      event: event,
    ));

    return true;
  }

  void setLayout(BoxConstraints size) {
    stateManager.setLayout(size);

    resetState();
  }

  void resetState() {
    _showFrozenColumn = stateManager.showFrozenColumn;

    _hasLeftFrozenColumns = stateManager.hasLeftFrozenColumns;

    _bodyLeftOffset = stateManager.bodyLeftOffset;

    _bodyRightOffset = stateManager.bodyRightOffset;

    _hasRightFrozenColumns = stateManager.hasRightFrozenColumns;

    _rightFrozenLeftOffset = stateManager.rightFrozenLeftOffset;

    _showColumnFilter = stateManager.showColumnFilter;

    _showLoading = stateManager.showLoading;
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      onFocusChange: (hasFocus) {
        stateManager.setKeepFocus(hasFocus);
      },
      child: SafeArea(
        child: LayoutBuilder(
            key: stateManager.gridKey,
            builder: (ctx, size) {
              setLayout(size);

              if (stateManager.keepFocus) {
                FocusScope.of(ctx).requestFocus(gridFocusNode);
              }

              return RawKeyboardListener(
                focusNode: stateManager.gridFocusNode,
                child: Container(
                  padding: const EdgeInsets.all(PlutoGridSettings.gridPadding),
                  decoration: BoxDecoration(
                    color: stateManager.configuration.gridBackgroundColor,
                    border: Border.all(
                      color: stateManager.configuration.gridBorderColor,
                      width: PlutoGridSettings.gridBorderWidth,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (stateManager.showHeader) ...[
                        Positioned.fill(
                          top: 0,
                          bottom: stateManager.headerBottomOffset,
                          child: widget.createHeader(stateManager),
                        ),
                        Positioned(
                          top: stateManager.headerHeight,
                          left: 0,
                          right: 0,
                          child: PlutoShadowLine(
                            axis: Axis.horizontal,
                            color: stateManager.configuration.gridBorderColor,
                          ),
                        ),
                      ],
                      if (_showFrozenColumn && _hasLeftFrozenColumns) ...[
                        Positioned.fill(
                          top: stateManager.headerHeight,
                          left: 0,
                          child: PlutoLeftFrozenColumns(stateManager),
                        ),
                        Positioned.fill(
                          top: stateManager.rowsTopOffset,
                          left: 0,
                          bottom: stateManager.footerHeight,
                          child: PlutoLeftFrozenRows(stateManager),
                        ),
                      ],
                      Positioned.fill(
                        top: stateManager.headerHeight,
                        left: _bodyLeftOffset,
                        right: _bodyRightOffset,
                        child: PlutoBodyColumns(stateManager),
                      ),
                      Positioned.fill(
                        top: stateManager.rowsTopOffset,
                        left: _bodyLeftOffset,
                        right: _bodyRightOffset,
                        bottom: stateManager.footerHeight,
                        child: PlutoBodyRows(stateManager),
                      ),
                      if (_showFrozenColumn && _hasRightFrozenColumns) ...[
                        Positioned.fill(
                          top: stateManager.headerHeight,
                          left: _rightFrozenLeftOffset,
                          child: PlutoRightFrozenColumns(stateManager),
                        ),
                        Positioned.fill(
                          top: stateManager.rowsTopOffset,
                          left: _rightFrozenLeftOffset,
                          bottom: stateManager.footerHeight,
                          child: PlutoRightFrozenRows(stateManager),
                        ),
                      ],
                      if (_showFrozenColumn && _hasLeftFrozenColumns)
                        Positioned(
                          top: stateManager.headerHeight,
                          left: _bodyLeftOffset - 1,
                          bottom: stateManager.footerHeight,
                          child: PlutoShadowLine(
                            axis: Axis.vertical,
                            color: stateManager.configuration.gridBorderColor,
                          ),
                        ),
                      if (_showFrozenColumn && _hasRightFrozenColumns)
                        Positioned(
                          top: stateManager.headerHeight,
                          left: _rightFrozenLeftOffset - 1,
                          bottom: stateManager.footerHeight,
                          child: PlutoShadowLine(
                            axis: Axis.vertical,
                            reverse: true,
                            color: stateManager.configuration.gridBorderColor,
                          ),
                        ),
                      Positioned(
                        top: stateManager.rowsTopOffset - 1,
                        left: 0,
                        right: 0,
                        child: PlutoShadowLine(
                          axis: Axis.horizontal,
                          color: stateManager.configuration.gridBorderColor,
                        ),
                      ),
                      if (stateManager.showFooter) ...[
                        Positioned(
                          top: stateManager.footerTopOffset,
                          left: 0,
                          right: 0,
                          child: PlutoShadowLine(
                            axis: Axis.horizontal,
                            reverse: true,
                            color: stateManager.configuration.gridBorderColor,
                          ),
                        ),
                        Positioned.fill(
                          top: stateManager.footerTopOffset,
                          bottom: 0,
                          child: widget.createFooter(stateManager),
                        ),
                      ],
                      if (_showColumnFilter)
                        Positioned(
                          top: stateManager.headerHeight +
                              stateManager.columnHeight,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              color: stateManager.configuration.gridBorderColor,
                            ),
                          ),
                        ),
                      if (stateManager.showLoading)
                        Positioned.fill(
                          child: PlutoLoading(
                            backgroundColor:
                                stateManager.configuration.gridBackgroundColor,
                            indicatorColor:
                                stateManager.configuration.cellTextStyle.color,
                            indicatorText: stateManager
                                .configuration.localeText.loadingText,
                            indicatorSize: stateManager
                                .configuration.cellTextStyle.fontSize,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class PlutoOnLoadedEvent {
  final PlutoStateManager stateManager;

  PlutoOnLoadedEvent({
    this.stateManager,
  });
}

/// Caution
///
/// [columnIdx] and [rowIdx] are values in the currently displayed state.
class PlutoOnChangedEvent {
  final int columnIdx;
  final PlutoColumn column;
  final int rowIdx;
  final PlutoRow row;
  final dynamic value;
  final dynamic oldValue;

  PlutoOnChangedEvent({
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

class PlutoOnSelectedEvent {
  final PlutoRow row;
  final PlutoCell cell;

  PlutoOnSelectedEvent({
    this.row,
    this.cell,
  });
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

  /// Scroll when multi-selection is as close as that value from the edge
  static const double offsetScrollingFromEdge = 10.0;

  /// Size that scrolls from the edge at once when selecting multiple
  static const double offsetScrollingFromEdgeAtOnce = 200.0;

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

  /// Cell - fontSize
  static const double cellFontSize = 14;
}

enum PlutoGridMode {
  normal,
  select,
  popup,
}

extension PlutoGridModeExtension on PlutoGridMode {
  bool get isNormal => this == PlutoGridMode.normal;

  bool get isSelect => this == PlutoGridMode.select;

  bool get isPopup => this == PlutoGridMode.popup;
}
