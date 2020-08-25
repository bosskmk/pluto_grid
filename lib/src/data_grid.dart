part of '../pluto_grid.dart';

/// [Todo list]
/// 컬럼 정렬 시 rowIdx 설명 추가 (rowIdx 는 보이는 상태에서의 rowIdx)
/// row selection 추가
/// number column type 추가
/// 날짜 선택 column type 추가
/// 컬럼 검색 추가
/// 페이지 up, down 추가 (키 이벤트)
/// 페이지 네비게이션 추가 (UI)

enum PlutoMode {
  Normal,
  SelectRow,
}

extension PlutoModeExtension on PlutoMode {
  bool get isNormal => this == PlutoMode.Normal;

  bool get isSelectRow => this == PlutoMode.SelectRow;
}

class PlutoGrid extends StatefulWidget {
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final PlutoMode mode;
  final PlutoOnLoadedEventCallback onLoaded;
  final PlutoOnChangedEventCallback onChanged;
  final PlutoOnSelectedEventCallback onSelectedRow;

  const PlutoGrid({
    Key key,
    @required this.columns,
    @required this.rows,
    this.onLoaded,
    this.onChanged,
  })  : this.mode = PlutoMode.Normal,
        this.onSelectedRow = null,
        super(key: key);

  const PlutoGrid.popup({
    Key key,
    @required this.columns,
    @required this.rows,
    this.onLoaded,
    this.onChanged,
    this.onSelectedRow,
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

    initSelectRowMode();

    super.initState();
  }

  void initProperties() {
    applySortIdxIntoRows();

    gridFocusNode = FocusNode(onKey: handleGridFocusOnKey);

    leftFixedRowsVerticalScroll = verticalScroll.addAndGet();
    bodyRowsVerticalScroll = verticalScroll.addAndGet();
    rightRowsVerticalScroll = verticalScroll.addAndGet();

    bodyHeadersHorizontalScroll = horizontalScroll.addAndGet();
    bodyRowsHorizontalScroll = horizontalScroll.addAndGet();

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
      onSelectedEventCallback: widget.onSelectedRow,
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

  void initSelectRowMode() {
    if (widget.mode.isSelectRow != true) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (stateManager.currentCell == null) {
        stateManager.setCurrentCell(
            widget.rows.first.cells.entries.first.value, 0);
      }

      stateManager.gridFocusNode.requestFocus();
    });
  }

  void applySortIdxIntoRows() {
    // 컬럼 정렬 시 기본 정렬을 위한 값
    for (var i = 0; i < widget.rows.length; i += 1) {
      if (widget.rows[i].sortIdx != null) {
        break;
      }
      widget.rows[i].sortIdx = i;
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
    stateManager.setLayout(size);

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
                  if (showFixedColumn == true && leftFixedColumnWidth > 0)
                    Positioned.fill(
                      left: 0,
                      child: LeftFixedHeaders(stateManager),
                    ),
                  if (showFixedColumn == true && leftFixedColumnWidth > 0)
                    Positioned.fill(
                      top: stateManager.style.rowHeight,
                      left: 0,
                      child: LeftFixedRows(stateManager),
                    ),
                  Positioned.fill(
                    top: 0,
                    left: leftFixedColumnWidth,
                    right: rightFixedColumnWidth,
                    child: BodyHeaders(stateManager),
                  ),
                  Positioned.fill(
                    top: stateManager.style.rowHeight,
                    left: leftFixedColumnWidth,
                    right: rightFixedColumnWidth,
                    child: BodyRows(stateManager),
                  ),
                  if (showFixedColumn == true && rightFixedColumnWidth > 0)
                    Positioned.fill(
                      top: 0,
                      left: size.maxWidth -
                          rightFixedColumnWidth -
                          PlutoDefaultSettings.totalShadowLineWidth,
                      child: RightFixedHeaders(stateManager),
                    ),
                  if (showFixedColumn == true && rightFixedColumnWidth > 0)
                    Positioned.fill(
                      top: stateManager.style.rowHeight,
                      left: size.maxWidth -
                          rightFixedColumnWidth -
                          PlutoDefaultSettings.totalShadowLineWidth,
                      child: RightFixedRows(stateManager),
                    ),
                  if (showFixedColumn == true && leftFixedColumnWidth > 0)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: leftFixedColumnWidth,
                      child: ShadowLine(axis: Axis.vertical),
                    ),
                  if (showFixedColumn == true && rightFixedColumnWidth > 0)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: size.maxWidth -
                          rightFixedColumnWidth -
                          PlutoDefaultSettings.totalShadowLineWidth,
                      child: ShadowLine(axis: Axis.vertical, reverse: true),
                    ),
                  Positioned(
                    top: stateManager.style.rowHeight,
                    left: 0,
                    right: 0,
                    child: ShadowLine(axis: Axis.horizontal),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class PlutoDefaultSettings {
  /// 고정 컬럼이 있는 경우 body 의 최소 넓이 (값 보다 작으면 fixed 컬럼이 풀림)
  static const double bodyMinWidth = 200.0;

  /// 기본 행 높이
  static const double rowHeight = 45.0;

  /// 기본 컬럼 넓이
  static const double columnWidth = 200.0;

  /// 최소 컬럼 넓이
  static const double minColumnWidth = 80.0;

  /// Fixed 컬럼 구분 선(ShadowLine) 크기
  static const double shadowLineSize = 3.0;

  /// Fixed 컬럼 구분 선 넓이 합계
  static const double totalShadowLineWidth =
      PlutoDefaultSettings.shadowLineSize * 2;

  /// 멀티 선택 시 가장자리에서 해당 값 만큼 가까운 경우 스크롤
  static const double offsetScrollingFromEdge = 80.0;

  /// 멀티 선택 시 가장자리에서 한번에 스크롤 되는 크기
  static const double offsetScrollingFromEdgeAtOnce = 200.0;

  /// Grid - padding
  static const double gridPadding = 2.0;

  /// Grid - border width
  static const double gridBorderWidth = 1.0;

  /// Grid - border color : 그리드 전체 border
  static const Color gridBorderColor = Color.fromRGBO(161, 165, 174, 100);

  /// Header - text style
  static const TextStyle headerTextStyle = const TextStyle(
    color: Colors.black,
    decoration: TextDecoration.none,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  /// Row - border width
  static const double rowBorderWidth = 1.0;

  /// Row - box color : 선택 상태의 Row
  static const Color currentRowColor = Color.fromRGBO(220, 245, 255, 100);

  /// Row - border color
  static const Color rowBorderColor = Color.fromRGBO(221, 226, 235, 100);

  /// Cell - padding
  static const double cellPadding = 10;

  /// Cell - border color : 선택 상태의 셀
  static const Color currentCellBorderColor = Colors.lightBlue;

  /// Cell - text style
  static const TextStyle cellTextStyle = TextStyle(
    fontSize: 14,
  );

  /// Cell - current editing cell color
  static const Color currentEditingCellColor = Colors.white;

  /// Cell - current read only cell color
  static const Color currentReadOnlyCellColor =
      Color.fromRGBO(242, 242, 242, 100);
}
