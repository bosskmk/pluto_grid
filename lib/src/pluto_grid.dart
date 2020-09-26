part of '../pluto_grid.dart';

typedef CreateHeaderCallBack = Widget Function(PlutoStateManager stateManager);
typedef CreateFooterCallBack = Widget Function(PlutoStateManager stateManager);

class PlutoGrid extends StatefulWidget {
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final PlutoMode mode;
  final PlutoOnLoadedEventCallback onLoaded;
  final PlutoOnChangedEventCallback onChanged;
  final PlutoOnSelectedEventCallback onSelected;
  final CreateHeaderCallBack createHeader;
  final CreateFooterCallBack createFooter;
  final PlutoConfiguration configuration;

  const PlutoGrid({
    Key key,
    @required this.columns,
    @required this.rows,
    this.onLoaded,
    this.onChanged,
    this.createHeader,
    this.createFooter,
    this.configuration,
  })  : this.mode = PlutoMode.Normal,
        this.onSelected = null,
        super(key: key);

  const PlutoGrid.popup({
    Key key,
    @required this.columns,
    @required this.rows,
    this.onLoaded,
    this.onChanged,
    this.onSelected,
    this.createHeader,
    this.createFooter,
    this.configuration,
    @required this.mode,
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

  bool _showFixedColumn;
  bool _hasLeftFixedColumns;
  double _bodyLeftOffset;
  double _bodyRightOffset;
  bool _hasRightFixedColumns;
  double _rightFixedLeftOffset;

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
    initializeColumnRow();

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
      if (stateManager.currentCell == null && widget.rows.length > 0) {
        stateManager.setCurrentCell(
            widget.rows.first.cells.entries.first.value, 0);
      }

      stateManager.gridFocusNode.requestFocus();
    });
  }

  void initializeColumnRow() {
    PlutoStateManager.initializeRows(widget.columns, widget.rows);
  }

  void changeStateListener() {
    if (_showFixedColumn != stateManager.showFixedColumn ||
        _hasLeftFixedColumns != stateManager.hasLeftFixedColumns ||
        _bodyLeftOffset != stateManager.bodyLeftOffset ||
        _bodyRightOffset != stateManager.bodyRightOffset ||
        _hasRightFixedColumns != stateManager.hasRightFixedColumns ||
        _rightFixedLeftOffset != stateManager.rightFixedLeftOffset) {
      setState(() {
        resetState();
      });
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
    _showFixedColumn = stateManager.showFixedColumn;

    _hasLeftFixedColumns = stateManager.hasLeftFixedColumns;

    _bodyLeftOffset = stateManager.bodyLeftOffset;

    _bodyRightOffset = stateManager.bodyRightOffset;

    _hasRightFixedColumns = stateManager.hasRightFixedColumns;

    _rightFixedLeftOffset = stateManager.rightFixedLeftOffset;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        key: stateManager.gridKey,
        builder: (ctx, size) {
          setLayout(size);

          FocusScope.of(ctx).requestFocus(gridFocusNode);

          return RawKeyboardListener(
            focusNode: stateManager.gridFocusNode,
            child: Container(
              padding: const EdgeInsets.all(PlutoDefaultSettings.gridPadding),
              decoration: BoxDecoration(
                color: stateManager.configuration.gridBackgroundColor,
                border: Border.all(
                  color: stateManager.configuration.gridBorderColor,
                  width: PlutoDefaultSettings.gridBorderWidth,
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
                      child: ShadowLine(
                        axis: Axis.horizontal,
                        color: stateManager.configuration.gridBorderColor,
                      ),
                    ),
                  ],
                  if (_showFixedColumn && _hasLeftFixedColumns) ...[
                    Positioned.fill(
                      top: stateManager.headerHeight,
                      left: 0,
                      child: LeftFixedColumns(stateManager),
                    ),
                    Positioned.fill(
                      top: stateManager.rowsTopOffset,
                      left: 0,
                      bottom: stateManager.footerHeight,
                      child: LeftFixedRows(stateManager),
                    ),
                  ],
                  Positioned.fill(
                    top: stateManager.headerHeight,
                    left: _bodyLeftOffset,
                    right: _bodyRightOffset,
                    child: BodyColumns(stateManager),
                  ),
                  Positioned.fill(
                    top: stateManager.rowsTopOffset,
                    left: _bodyLeftOffset,
                    right: _bodyRightOffset,
                    bottom: stateManager.footerHeight,
                    child: BodyRows(stateManager),
                  ),
                  if (_showFixedColumn && _hasRightFixedColumns) ...[
                    Positioned.fill(
                      top: stateManager.headerHeight,
                      left: _rightFixedLeftOffset,
                      child: RightFixedColumns(stateManager),
                    ),
                    Positioned.fill(
                      top: stateManager.rowsTopOffset,
                      left: _rightFixedLeftOffset,
                      bottom: stateManager.footerHeight,
                      child: RightFixedRows(stateManager),
                    ),
                  ],
                  if (_showFixedColumn && _hasLeftFixedColumns)
                    Positioned(
                      top: stateManager.headerHeight,
                      left: _bodyLeftOffset - 1,
                      bottom: stateManager.footerHeight,
                      child: ShadowLine(
                        axis: Axis.vertical,
                        color: stateManager.configuration.gridBorderColor,
                      ),
                    ),
                  if (_showFixedColumn && _hasRightFixedColumns)
                    Positioned(
                      top: stateManager.headerHeight,
                      left: _rightFixedLeftOffset - 1,
                      bottom: stateManager.footerHeight,
                      child: ShadowLine(
                        axis: Axis.vertical,
                        reverse: true,
                        color: stateManager.configuration.gridBorderColor,
                      ),
                    ),
                  Positioned(
                    top: stateManager.rowsTopOffset - 1,
                    left: 0,
                    right: 0,
                    child: ShadowLine(
                      axis: Axis.horizontal,
                      color: stateManager.configuration.gridBorderColor,
                    ),
                  ),
                  if (stateManager.showFooter) ...[
                    Positioned(
                      top: stateManager.footerTopOffset,
                      left: 0,
                      right: 0,
                      child: ShadowLine(
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
                ],
              ),
            ),
          );
        });
  }
}

enum PlutoMode {
  Normal,
  Select,
}

extension PlutoModeExtension on PlutoMode {
  bool get isNormal => this == PlutoMode.Normal;

  bool get isSelect => this == PlutoMode.Select;
}

class PlutoDefaultSettings {
  /// If there is a fixed column, the minimum width of the body
  /// (if it is less than the value, the fixed column is released)
  static const double bodyMinWidth = 200.0;

  /// Default column width
  static const double columnWidth = 200.0;

  /// Column width
  static const double minColumnWidth = 80.0;

  /// Fixed column division line (ShadowLine) size
  static const double shadowLineSize = 3.0;

  /// Sum of fixed column division line width
  static const double totalShadowLineWidth =
      PlutoDefaultSettings.shadowLineSize * 2;

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
