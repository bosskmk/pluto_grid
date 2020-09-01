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

  const PlutoGrid({
    Key key,
    @required this.columns,
    @required this.rows,
    this.onLoaded,
    this.onChanged,
    this.createHeader,
    this.createFooter,
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
    @required this.mode,
  }) : super(key: key);

  @override
  _PlutoGridState createState() => _PlutoGridState();
}

class _PlutoGridState extends State<PlutoGrid> {
  FocusNode gridFocusNode;

  LinkedScrollControllerGroup verticalScroll = LinkedScrollControllerGroup();
  ScrollController leftFixedRowsVerticalScroll;
  ScrollController bodyRowsVerticalScroll;
  ScrollController rightRowsVerticalScroll;

  LinkedScrollControllerGroup horizontalScroll = LinkedScrollControllerGroup();
  ScrollController bodyHeadersHorizontalScroll;
  ScrollController bodyRowsHorizontalScroll;

  double leftFixedColumnWidth;
  double bodyColumnWidth;
  double rightFixedColumnWidth;
  bool showFixedColumn;
  double headerHeight;
  double footerHeight;

  List<Function()> disposeList = [];

  PlutoStateManager stateManager;
  PlutoKeyManager keyManager;

  @override
  void dispose() {
    disposeList.forEach((dispose) {
      dispose();
    });

    super.dispose();
  }

  @override
  void initState() {
    initProperties();

    initStateManager();

    initKeyManager();

    initOnLoadedEvent();

    initSelectMode();

    super.initState();
  }

  void initProperties() {
    applyColumnRowOnInit();

    gridFocusNode = FocusNode(onKey: handleGridFocusOnKey);

    leftFixedRowsVerticalScroll = verticalScroll.addAndGet();
    bodyRowsVerticalScroll = verticalScroll.addAndGet();
    rightRowsVerticalScroll = verticalScroll.addAndGet();

    bodyHeadersHorizontalScroll = horizontalScroll.addAndGet();
    bodyRowsHorizontalScroll = horizontalScroll.addAndGet();

    headerHeight =
        widget.createHeader == null ? 0 : PlutoDefaultSettings.rowTotalHeight;

    footerHeight =
        widget.createFooter == null ? 0 : PlutoDefaultSettings.rowTotalHeight;

    // Dispose
    disposeList.add(() {
      gridFocusNode.dispose();

      leftFixedRowsVerticalScroll.dispose();
      bodyRowsVerticalScroll.dispose();
      rightRowsVerticalScroll.dispose();

      bodyHeadersHorizontalScroll.dispose();
      bodyRowsHorizontalScroll.dispose();
    });
  }

  void initStateManager() {
    stateManager = PlutoStateManager(
      columns: widget.columns,
      rows: widget.rows,
      gridFocusNode: gridFocusNode,
      scroll: PlutoScrollController(
        vertical: verticalScroll,
        leftFixedRowsVertical: leftFixedRowsVerticalScroll,
        bodyRowsVertical: bodyRowsVerticalScroll,
        rightRowsVerticalScroll: rightRowsVerticalScroll,
        horizontal: horizontalScroll,
        bodyHeadersHorizontal: bodyHeadersHorizontalScroll,
        bodyRowsHorizontal: bodyRowsHorizontalScroll,
      ),
      mode: widget.mode,
      onChangedEventCallback: widget.onChanged,
      onSelectedEventCallback: widget.onSelected,
    );

    leftFixedColumnWidth = stateManager.leftFixedColumnsWidth;
    bodyColumnWidth = stateManager.bodyColumnsWidth;
    rightFixedColumnWidth = stateManager.rightFixedColumnsWidth;

    stateManager.addListener(changeStateListener);

    // Dispose
    disposeList.add(() {
      stateManager.removeListener(changeStateListener);
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

  void applyColumnRowOnInit() {
    List<PlutoColumn> applyFormatOnInit = widget.columns.where((element) {
      if (element.type.name.isNumber && element.type.applyFormatOnInit) {
        return true;
      } else if (element.type.name.isDate && element.type.applyFormatOnInit) {
        return true;
      }
      return false;
    }).toList(growable: false);

    final bool hasApplyFormatOnInit = applyFormatOnInit.length > 0;

    final bool hasSortIdx =
        widget.rows.length > 0 && widget.rows.first.sortIdx != null;

    if (hasApplyFormatOnInit == false && hasSortIdx == true) {
      return;
    }

    // Value for basic sorting when sorting columns
    for (var rowIdx = 0; rowIdx < widget.rows.length; rowIdx += 1) {
      if (hasApplyFormatOnInit) {
        applyFormatOnInit.forEach((element) {
          if (element.type.name.isNumber) {
            widget.rows[rowIdx].cells[element.field].value = num.parse(element
                .type
                .numberFormat(widget.rows[rowIdx].cells[element.field].value)
                .replaceAll(',', ''));
          } else if (element.type.name.isDate) {
            widget.rows[rowIdx].cells[element.field].value =
                intl.DateFormat(element.type.format).format(DateTime.parse(
                    widget.rows[rowIdx].cells[element.field].value));
          }
        });
      }

      if (hasSortIdx == false) {
        widget.rows[rowIdx].sortIdx = rowIdx;
      }
    }
  }

  void changeStateListener() {
    if (leftFixedColumnWidth != stateManager.leftFixedColumnsWidth ||
        rightFixedColumnWidth != stateManager.rightFixedColumnsWidth ||
        bodyColumnWidth != stateManager.bodyColumnsWidth) {
      setState(() {
        leftFixedColumnWidth = stateManager.leftFixedColumnsWidth;
        rightFixedColumnWidth = stateManager.rightFixedColumnsWidth;
        bodyColumnWidth = stateManager.bodyColumnsWidth;
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
    stateManager.setLayout(size, headerHeight, footerHeight);

    showFixedColumn = stateManager.layout.showFixedColumn;

    leftFixedColumnWidth =
        showFixedColumn ? stateManager.leftFixedColumnsWidth : 0;

    rightFixedColumnWidth =
        showFixedColumn ? stateManager.rightFixedColumnsWidth : 0;

    bodyColumnWidth = showFixedColumn
        ? stateManager.bodyColumnsWidth
        : stateManager.columnsWidth;
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
                border: Border.all(
                  color: PlutoDefaultSettings.gridBorderColor,
                  width: PlutoDefaultSettings.gridBorderWidth,
                ),
              ),
              child: Stack(
                children: [
                  if (widget.createHeader != null)
                    Positioned.fill(
                      top: 0,
                      bottom:
                          size.maxHeight - PlutoDefaultSettings.rowTotalHeight,
                      child: widget.createHeader(stateManager),
                    ),
                  if (widget.createHeader != null)
                    Positioned(
                      top: PlutoDefaultSettings.rowTotalHeight,
                      left: 0,
                      right: 0,
                      child: ShadowLine(axis: Axis.horizontal),
                    ),
                  if (showFixedColumn == true && leftFixedColumnWidth > 0)
                    Positioned.fill(
                      top: headerHeight,
                      left: 0,
                      child: LeftFixedHeaders(stateManager),
                    ),
                  if (showFixedColumn == true && leftFixedColumnWidth > 0)
                    Positioned.fill(
                      top: headerHeight + PlutoDefaultSettings.rowTotalHeight,
                      left: 0,
                      bottom: footerHeight,
                      child: LeftFixedRows(stateManager),
                    ),
                  Positioned.fill(
                    top: headerHeight,
                    left: leftFixedColumnWidth,
                    right: rightFixedColumnWidth,
                    child: BodyHeaders(stateManager),
                  ),
                  Positioned.fill(
                    top: headerHeight + PlutoDefaultSettings.rowTotalHeight,
                    left: leftFixedColumnWidth,
                    right: rightFixedColumnWidth,
                    bottom: footerHeight,
                    child: BodyRows(stateManager),
                  ),
                  if (showFixedColumn == true && rightFixedColumnWidth > 0)
                    Positioned.fill(
                      top: headerHeight,
                      left: size.maxWidth -
                          rightFixedColumnWidth -
                          PlutoDefaultSettings.totalShadowLineWidth,
                      child: RightFixedHeaders(stateManager),
                    ),
                  if (showFixedColumn == true && rightFixedColumnWidth > 0)
                    Positioned.fill(
                      top: headerHeight + PlutoDefaultSettings.rowTotalHeight,
                      left: size.maxWidth -
                          rightFixedColumnWidth -
                          PlutoDefaultSettings.totalShadowLineWidth,
                      bottom: footerHeight,
                      child: RightFixedRows(stateManager),
                    ),
                  if (showFixedColumn == true && leftFixedColumnWidth > 0)
                    Positioned(
                      top: headerHeight,
                      left: leftFixedColumnWidth,
                      bottom: footerHeight,
                      child: ShadowLine(axis: Axis.vertical),
                    ),
                  if (showFixedColumn == true && rightFixedColumnWidth > 0)
                    Positioned(
                      top: headerHeight,
                      left: size.maxWidth -
                          rightFixedColumnWidth -
                          PlutoDefaultSettings.totalShadowLineWidth,
                      bottom: footerHeight,
                      child: ShadowLine(axis: Axis.vertical, reverse: true),
                    ),
                  Positioned(
                    top: headerHeight + PlutoDefaultSettings.rowTotalHeight,
                    left: 0,
                    right: 0,
                    child: ShadowLine(axis: Axis.horizontal),
                  ),
                  if (widget.createFooter != null)
                    Positioned(
                      top: size.maxHeight -
                          footerHeight -
                          PlutoDefaultSettings.totalShadowLineWidth,
                      left: 0,
                      right: 0,
                      child: ShadowLine(axis: Axis.horizontal, reverse: true),
                    ),
                  if (widget.createFooter != null)
                    Positioned.fill(
                      top: size.maxHeight -
                          footerHeight -
                          PlutoDefaultSettings.totalShadowLineWidth,
                      bottom: 0,
                      child: widget.createFooter(stateManager),
                    ),
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
  static const double offsetScrollingFromEdge = 80.0;

  /// Size that scrolls from the edge at once when selecting multiple
  static const double offsetScrollingFromEdgeAtOnce = 200.0;

  /// Grid - padding
  static const double gridPadding = 2.0;

  /// Grid - border width
  static const double gridBorderWidth = 1.0;

  static const double gridInnerSpacing =
      (gridPadding * 2) + (gridBorderWidth * 2);

  /// Grid - grid border color
  static const Color gridBorderColor = Color.fromRGBO(161, 165, 174, 100);

  /// Header - text style
  static const TextStyle headerTextStyle = const TextStyle(
    color: Colors.black,
    decoration: TextDecoration.none,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  /// Row - Default row height
  static const double rowHeight = 45.0;

  /// Row - border width
  static const double rowBorderWidth = 1.0;

  /// Row - total height
  static const double rowTotalHeight = rowHeight + rowBorderWidth;

  /// Row - box color : Row in selected state
  static const Color currentRowColor = Color.fromRGBO(220, 245, 255, 100);

  /// Row - border color
  static const Color rowBorderColor = Color.fromRGBO(221, 226, 235, 100);

  /// Cell - padding
  static const double cellPadding = 10;

  /// Cell - border color : Cell in selected state
  static const Color currentCellBorderColor = Colors.lightBlue;

  /// Cell - fontSize
  static const double cellFontSize = 14;

  /// Cell - text style
  static const TextStyle cellTextStyle = TextStyle(
    fontSize: cellFontSize,
  );

  /// Cell - current editing cell color
  static const Color currentEditingCellColor = Colors.white;

  /// Cell - current read only cell color
  static const Color currentReadOnlyCellColor =
      Color.fromRGBO(196, 199, 204, 100);
}
