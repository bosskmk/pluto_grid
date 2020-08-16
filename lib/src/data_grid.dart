part of pluto_grid;

class PlutoGrid extends StatefulWidget {
  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;

  PlutoGrid({
    Key key,
    @required this.columns,
    @required this.rows,
  });

  @override
  _PlutoGridState createState() => _PlutoGridState();
}

class _PlutoGridState extends State<PlutoGrid> {
  FocusNode gridFocusNode;

  LinkedScrollControllerGroup verticalScroll = LinkedScrollControllerGroup();
  ScrollController leftFixedRowsVerticalScroll;
  ScrollController bodyRowsVerticalScroll;

  LinkedScrollControllerGroup horizontalScroll = LinkedScrollControllerGroup();
  ScrollController bodyHeadersHorizontalScroll;
  ScrollController bodyRowsHorizontalScroll;

  PlutoStateManager stateManager;

  double leftFixedColumnWidth;
  bool showFixedColumn;

  @override
  void dispose() {
    gridFocusNode.dispose();
    leftFixedRowsVerticalScroll.dispose();
    bodyRowsHorizontalScroll.dispose();
    bodyHeadersHorizontalScroll.dispose();
    bodyRowsHorizontalScroll.dispose();

    stateManager.removeListener(changeStateListener);

    super.dispose();
  }

  @override
  void initState() {
    applySortIdxIntoRows();

    gridFocusNode = FocusNode(onKey: handleGridFocusOnKey);
    leftFixedRowsVerticalScroll = verticalScroll.addAndGet();
    bodyRowsVerticalScroll = verticalScroll.addAndGet();
    bodyHeadersHorizontalScroll = horizontalScroll.addAndGet();
    bodyRowsHorizontalScroll = horizontalScroll.addAndGet();

    stateManager = PlutoStateManager(
      columns: widget.columns,
      rows: widget.rows,
      gridFocusNode: gridFocusNode,
      scroll: PlutoScrollController(
        vertical: verticalScroll,
        leftFixedRowsVertical: leftFixedRowsVerticalScroll,
        bodyRowsVertical: bodyRowsVerticalScroll,
        horizontal: horizontalScroll,
        bodyHeadersHorizontal: bodyHeadersHorizontalScroll,
        bodyRowsHorizontal: bodyRowsHorizontalScroll,
      ),
    );

    leftFixedColumnWidth = stateManager.leftFixedColumnsWidth;

    stateManager.addListener(changeStateListener);

    super.initState();
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
    if (leftFixedColumnWidth != stateManager.leftFixedColumnsWidth) {
      setState(() {
        leftFixedColumnWidth = stateManager.leftFixedColumnsWidth;
      });
    }
  }

  bool handleGridFocusOnKey(FocusNode focusNode, RawKeyEvent event) {
    if (event.runtimeType == RawKeyDownEvent) {
      if (event.logicalKey.keyId == LogicalKeyboardKey.arrowLeft.keyId) {
        // 왼쪽
        return stateManager.moveCurrentCell(MoveDirection.Left);
      } else if (event.logicalKey.keyId ==
          LogicalKeyboardKey.arrowRight.keyId) {
        // 오른쪽
        return stateManager.moveCurrentCell(MoveDirection.Right);
      } else if (event.logicalKey.keyId == LogicalKeyboardKey.arrowUp.keyId) {
        // 위
        return stateManager.moveCurrentCell(MoveDirection.Up);
      } else if (event.logicalKey.keyId == LogicalKeyboardKey.arrowDown.keyId) {
        // 아래
        return stateManager.moveCurrentCell(MoveDirection.Down);
      } else if (event.logicalKey.keyId == LogicalKeyboardKey.enter.keyId) {
        // 엔터
        stateManager.toggleEditing();
      } else if (event.logicalKey.keyLabel != null) {
        // 문자
      }
    }
    return false;
  }

  void setLayout(BoxConstraints size) {
    stateManager.setLayout(size);
    if (showFixedColumn != stateManager.layout.showFixedColumn) {
      showFixedColumn = stateManager.layout.showFixedColumn;
      leftFixedColumnWidth =
          showFixedColumn ? stateManager.leftFixedColumnsWidth : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, size) {
      setLayout(size);

      FocusScope.of(ctx).requestFocus(gridFocusNode);

      return RawKeyboardListener(
        focusNode: stateManager.gridFocusNode,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          child: Stack(
            children: [
              if (showFixedColumn == true)
                Positioned.fill(
                  child: LeftFixedHeaders(stateManager),
                ),
              if (showFixedColumn == true)
                Positioned.fill(
                  top: stateManager.style.rowHeight,
                  left: 0,
                  child: LeftFixedRows(stateManager),
                ),
              Positioned.fill(
                top: 0,
                left: leftFixedColumnWidth,
                child: BodyHeaders(stateManager),
              ),
              Positioned.fill(
                top: stateManager.style.rowHeight,
                left: leftFixedColumnWidth,
                child: BodyRows(stateManager),
              ),
              if (showFixedColumn == true)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: leftFixedColumnWidth,
                  child: ShadowLine(Axis.vertical),
                ),
              Positioned(
                top: stateManager.style.rowHeight,
                left: 0,
                right: 0,
                child: ShadowLine(Axis.horizontal),
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
  static const double rowHeight = 60.0;

  /// 기본 컬럼 넓이
  static const double columnWidth = 200.0;
}
