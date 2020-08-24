part of pluto_grid;

class PlutoStateManager extends ChangeNotifier {
  List<PlutoColumn> _columns;

  List<PlutoColumn> get columns => [..._columns];

  List<PlutoRow> _rows;

  List<PlutoRow> get rows => [..._rows];

  FocusNode _gridFocusNode;

  FocusNode get gridFocusNode => _gridFocusNode;

  PlutoScrollController _scroll;

  PlutoScrollController get scroll => _scroll;

  PlutoStyle _style;

  PlutoStyle get style => _style;

  PlutoMode _mode;

  PlutoMode get mode => _mode;

  final PlutoOnChangedEventCallback _onChanged;

  final PlutoOnSelectedEventCallback _onSelected;

  final GlobalKey _gridKey;

  GlobalKey get gridKey => _gridKey;

  PlutoStateManager({
    @required List<PlutoColumn> columns,
    @required List<PlutoRow> rows,
    @required FocusNode gridFocusNode,
    @required PlutoScrollController scroll,
    PlutoStyle style,
    PlutoMode mode,
    PlutoOnChangedEventCallback onChangedEventCallback,
    PlutoOnSelectedEventCallback onSelectedEventCallback,
  })  : this._columns = columns,
        this._rows = rows,
        this._gridFocusNode = gridFocusNode,
        this._scroll = scroll,
        this._style = style ?? PlutoStyle(),
        this._mode = mode,
        this._onChanged = onChangedEventCallback,
        this._onSelected = onSelectedEventCallback,
        this._gridKey = GlobalKey();

  /// 전체 컬럼의 인덱스 리스트
  List<int> get columnIndexes => _columns.asMap().keys.toList();

  /// fixed 컬럼이 있는 경우 넓이가 좁을 때 fixed 컬럼의 순서를 유지하는 전체 컬럼의 인덱스 리스트
  List<int> get columnIndexesForShowFixed {
    return [
      ...leftFixedColumnIndexes,
      ...bodyColumnIndexes,
      ...rightFixedColumnIndexes
    ];
  }

  /// 전체 컬럼의 넓이
  double get columnsWidth {
    return _columns.fold(0, (double value, element) => value + element.width);
  }

  /// 왼쪽 고정 컬럼
  List<PlutoColumn> get leftFixedColumns {
    return _columns.where((e) => e.fixed.isLeft).toList();
  }

  /// 왼쪽 고정 컬럼의 인덱스 리스트
  List<int> get leftFixedColumnIndexes {
    return _columns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.fixed.isLeft) {
        return [...previousValue, columns.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  /// 왼쪽 고정 컬럼의 넓이
  double get leftFixedColumnsWidth {
    return leftFixedColumns.fold(
        0, (double value, element) => value + element.width);
  }

  /// 오른쪽 고정 컬럼
  List<PlutoColumn> get rightFixedColumns {
    return _columns.where((e) => e.fixed.isRight).toList();
  }

  /// 오른쪽 컬럼 인덱스 리스트
  List<int> get rightFixedColumnIndexes {
    return _columns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.fixed.isRight) {
        return [...previousValue, columns.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  /// 오른쪽 고정 컬럼의 넓이
  double get rightFixedColumnsWidth {
    return rightFixedColumns.fold(
        0, (double value, element) => value + element.width);
  }

  /// body 컬럼
  List<PlutoColumn> get bodyColumns {
    return _columns.where((e) => e.fixed.isNone).toList();
  }

  /// body 컬럼 인덱스 리스트
  List<int> get bodyColumnIndexes {
    return bodyColumns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.fixed.isNone) {
        return [...previousValue, columns.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  /// body 컬럼의 넓이
  double get bodyColumnsWidth {
    return bodyColumns.fold(
        0, (double value, element) => value + element.width);
  }

  /// 화면 사이즈와 고정 컬럼 출력 여부
  PlutoLayout _layout;

  PlutoLayout get layout => _layout;

  /// 현재 선택 된 셀의 컬럼
  PlutoColumn get currentColumn {
    if (currentColumnField == null) {
      return null;
    }

    return _columns
        .where((element) => element.field == currentColumnField)
        ?.first;
  }

  /// 현재 선택 된 셀의 컬럼 field 이름
  String get currentColumnField => currentRow.cells.entries
      .where((entry) => entry.value._key == _currentCell?._key)
      ?.first
      ?.key;

  Offset _gridGlobalOffset;

  /// 그리드의 global offset
  Offset get gridGlobalOffset {
    if (_gridGlobalOffset != null) {
      return _gridGlobalOffset;
    }

    final RenderBox gridRenderBox = _gridKey.currentContext?.findRenderObject();

    if (gridRenderBox == null) {
      return null;
    }

    _gridGlobalOffset = gridRenderBox.localToGlobal(Offset.zero);

    return _gridGlobalOffset;
  }

  /// 현재 선택 된 셀
  PlutoCell _currentCell;

  PlutoCell get currentCell => _currentCell;

  /// 현재 선택 된 셀의 위치 값
  PlutoCellPosition get currentCellPosition {
    if (_currentCell == null) {
      return null;
    }

    final columnIndexes = columnIndexesByShowFixed();

    return cellPositionByCellKey(_currentCell._key, columnIndexes);
  }

  /// 현재 선택 된 셀의 Row index
  int _currentRowIdx;

  int get currentRowIdx => _currentRowIdx;

  PlutoRow get currentRow {
    if (_currentRowIdx == null) {
      return null;
    }

    return _rows[_currentRowIdx];
  }

  /// 현재 셀의 편집 상태
  bool _isEditing = false;

  bool get isEditing => _isEditing;

  /// 멀티 선택 상태
  bool _isSelecting = false;

  bool get isSelecting => _isSelecting;

  /// 멀티 선택 셀의 현재 위치
  PlutoCellPosition _currentSelectingPosition;

  PlutoCellPosition get currentSelectingPosition => _currentSelectingPosition;

  /// 멀티 선택 된 셀들의 값
  String get currentSelectingText {
    List<String> textList = [];

    int columnStartIdx =
        min(currentCellPosition.columnIdx, currentSelectingPosition.columnIdx);

    int rowStartIdx =
        min(currentCellPosition.rowIdx, currentSelectingPosition.rowIdx);

    int columnEndIdx =
        max(currentCellPosition.columnIdx, currentSelectingPosition.columnIdx);

    int rowEndIdx =
        max(currentCellPosition.rowIdx, currentSelectingPosition.rowIdx);

    final _columnIndexes = columnIndexesByShowFixed();

    for (var i = rowStartIdx; i <= rowEndIdx; i += 1) {
      List<String> columnText = [];

      for (var j = columnStartIdx; j <= columnEndIdx; j += 1) {
        final String field = _columns[_columnIndexes[j]].field;

        columnText.add(_rows[i].cells[field].value);
      }

      textList.add(columnText.join('\t'));
    }

    return textList.join('\n');
  }

  /// 수정 전 셀 값
  dynamic _cellValueBeforeEditing;

  dynamic get cellValueBeforeEditing => _cellValueBeforeEditing;

  /// [CellWidget] 에서 cell 값 변경 확인 여부
  bool _checkCellValue = true;

  /// 현재 선택 된 셀을 변경
  void setCurrentCell(
    PlutoCell cell,
    int rowIdx, {
    bool notify = true,
  }) {
    if (_currentCell != null && _currentCell._key == cell._key) {
      return;
    }

    _checkCellValue = false;

    _currentCell = cell;

    _currentSelectingPosition = null;

    setEditing(false, notify: false);

    if (rowIdx != null) _currentRowIdx = rowIdx;

    if (notify) {
      notifyListeners();
    }

    _checkCellValue = true;
  }

  /// LayoutBuilder 가 build 될 때 화면 사이즈 정보 갱신
  void setLayout(BoxConstraints size) {
    _layout = PlutoLayout(
      maxWidth: size.maxWidth,
      maxHeight: size.maxHeight,
      showFixedColumn: isShowFixedColumn(size.maxWidth),
    );

    _gridGlobalOffset = null;
  }

  /// 현재 셀의 편집 상태를 변경
  void setEditing(
    bool flag, {
    bool notify = true,
  }) {
    if (mode.isSelectRow) {
      return;
    }

    _checkCellValue = false;

    if (_currentCell == null || _isEditing == flag) {
      return;
    }

    if (flag == true) {
      _cellValueBeforeEditing = currentCell.value;
    }

    _isEditing = flag;

    if (notify) {
      notifyListeners();
    }

    _checkCellValue = true;
  }

  void setSelecting(bool flag) {
    if (mode.isSelectRow) {
      return;
    }

    _checkCellValue = false;

    if (_currentCell == null || _isSelecting == flag) {
      _checkCellValue = true;
      return;
    }

    _isSelecting = flag;

    notifyListeners();

    _checkCellValue = true;
  }

  void setCurrentSelectingPosition(Offset offset) {
    if (_currentCell == null) {
      return;
    }

    _checkCellValue = false;

    final double gridBodyOffsetDy = gridGlobalOffset.dy +
        PlutoDefaultSettings.rowHeight +
        PlutoDefaultSettings.gridBorderWidth +
        PlutoDefaultSettings.rowBorderWidth;

    double currentCellOffsetDy = (currentRowIdx *
            (PlutoDefaultSettings.rowHeight +
                PlutoDefaultSettings.rowBorderWidth)) +
        gridBodyOffsetDy -
        _scroll.vertical.offset;

    if (gridBodyOffsetDy > offset.dy) {
      _checkCellValue = true;
      return;
    }

    int rowIdx = (((currentCellOffsetDy - offset.dy) /
                    (PlutoDefaultSettings.rowHeight +
                        PlutoDefaultSettings.rowBorderWidth))
                .ceil() -
            currentRowIdx)
        .abs();

    int columnIdx;

    double currentWidth = 0.0;
    currentWidth += gridGlobalOffset.dx;
    currentWidth += PlutoDefaultSettings.gridPadding;
    currentWidth += PlutoDefaultSettings.gridBorderWidth;

    final _columnIndexes = columnIndexesByShowFixed();

    for (var i = 0; i < _columnIndexes.length; i += 1) {
      currentWidth += _columns[_columnIndexes[i]].width;

      if (currentWidth > offset.dx + _scroll.horizontal.offset) {
        columnIdx = i;
        break;
      }
    }

    if (columnIdx == null) {
      _checkCellValue = true;
      return;
    }

    _currentSelectingPosition =
        PlutoCellPosition(columnIdx: columnIdx, rowIdx: rowIdx);

    notifyListeners();

    _checkCellValue = true;
  }

  /// currentRowIdx 를 업데이트
  /// - rows 의 위치가 정렬 등으로 바뀔 때 호출
  void updateCurrentRowIdx(GlobalKey cellKey) {
    if (cellKey == null) {
      return;
    }

    for (var rowIdx = 0; rowIdx < _rows.length; rowIdx += 1) {
      for (var columnIdx = 0;
          columnIdx < columnIndexes.length;
          columnIdx += 1) {
        final field = _columns[columnIndexes[columnIdx]].field;

        if (_rows[rowIdx].cells[field]._key == cellKey) {
          _currentRowIdx = rowIdx;
        }
      }
    }
    return;
  }

  /// 현재 셀의 편집 상태를 토글
  void toggleEditing() => setEditing(!(_isEditing == true));

  /// 컬럼의 고정 여부를 토글
  void toggleFixedColumn(GlobalKey columnKey, PlutoColumnFixed fixed) {
    for (var i = 0; i < _columns.length; i += 1) {
      if (_columns[i]._key == columnKey) {
        _columns[i].fixed =
            _columns[i].fixed.isFixed ? PlutoColumnFixed.None : fixed;
        break;
      }
    }
    notifyListeners();
  }

  /// 컬럼 정렬 토글
  void toggleSortColumn(GlobalKey columnKey) {
    for (var i = 0; i < _columns.length; i += 1) {
      if (_columns[i]._key == columnKey) {
        final field = _columns[i].field;
        if (_columns[i].sort.isNone) {
          _columns[i].sort = PlutoColumnSort.Ascending;

          _rows.sort((a, b) => a.cells[field].value
              .toString()
              .compareTo(b.cells[field].value.toString()));
        } else if (_columns[i].sort.isAscending) {
          _columns[i].sort = PlutoColumnSort.Descending;

          _rows.sort((b, a) => a.cells[field].value
              .toString()
              .compareTo(b.cells[field].value.toString()));
        } else {
          _columns[i].sort = PlutoColumnSort.None;

          _rows.sort((a, b) {
            if (a.sortIdx == null || b.sortIdx == null) return 0;
            return a.sortIdx.compareTo(b.sortIdx);
          });
        }
      } else {
        _columns[i].sort = PlutoColumnSort.None;
      }
    }

    updateCurrentRowIdx(_currentCell?._key);

    notifyListeners();
  }

  /// 전체 컬럼의 인덱스 위치까지의 넓이
  double columnsWidthAtColumnIdx(int columnIdx) {
    double width = 0.0;
    columnIndexes.getRange(0, columnIdx).forEach((idx) {
      width += _columns[idx].width;
    });
    return width;
  }

  /// body 컬럼의 인덱스 까지의 넓이
  double bodyColumnsWidthAtColumnIdx(int columnIdx) {
    double width = 0.0;
    bodyColumnIndexes.getRange(0, columnIdx).forEach((idx) {
      width += columns[idx].width;
    });
    return width;
  }

  /// 고정 컬럼 여부에 따른 컬럼 인덱스 리스트
  List<int> columnIndexesByShowFixed() {
    return _layout.showFixedColumn ? columnIndexesForShowFixed : columnIndexes;
  }

  /// 해당 컬럼 인덱스에서 셀의 인덱스 위치
  PlutoCellPosition cellPositionByCellKey(
      GlobalKey cellKey, List<int> columnIndexes) {
    for (var rowIdx = 0; rowIdx < _rows.length; rowIdx += 1) {
      for (var columnIdx = 0;
          columnIdx < columnIndexes.length;
          columnIdx += 1) {
        final field = _columns[columnIndexes[columnIdx]].field;
        if (_rows[rowIdx].cells[field]._key == cellKey) {
          return PlutoCellPosition(columnIdx: columnIdx, rowIdx: rowIdx);
        }
      }
    }
    throw Exception('CellKey was not found in the list.');
  }

  /// 셀의 위치에서 해당 뱡향으로 이동 가능 한 여부
  bool canNotMoveCell(PlutoCellPosition cellPosition, MoveDirection direction) {
    return !canMoveCell(cellPosition, direction);
  }

  bool canMoveCell(PlutoCellPosition cellPosition, MoveDirection direction) {
    switch (direction) {
      case MoveDirection.Left:
        return cellPosition.columnIdx > 0;
      case MoveDirection.Right:
        return cellPosition.columnIdx <
            _rows[cellPosition.rowIdx].cells.length - 1;
      case MoveDirection.Up:
        return cellPosition.rowIdx > 0;
      case MoveDirection.Down:
        return cellPosition.rowIdx < _rows.length - 1;
    }
    throw Exception('MoveDirection case was not handled.');
  }

  /// 움직이려는 셀의 위치로 스크롤이 이동 할 수 있는지 여부
  bool canHorizontalCellScrollByDirection(
    MoveDirection direction,
    PlutoColumn columnToMove,
  ) {
    // 고정 컬럼이 보여지는 상태에서 이동 할 컬럼이 고정 컬럼인 경우 스크롤 불필요
    return !(_layout.showFixedColumn == true && columnToMove.fixed.isFixed);
  }

  /// 현재 셀에서 해당 방향으로 이동 하려는 셀의 인덱스 위치
  /// columnIndexes : 현재 셀이 위치하고 있는 컬럼(leftFixed, body)
  PlutoCellPosition cellPositionToMove(
    PlutoCellPosition cellPosition,
    MoveDirection direction,
    List<int> columnIndexes,
  ) {
    switch (direction) {
      case MoveDirection.Left:
        return PlutoCellPosition(
          columnIdx: columnIndexes[cellPosition.columnIdx - 1],
          rowIdx: cellPosition.rowIdx,
        );
      case MoveDirection.Right:
        return PlutoCellPosition(
          columnIdx: columnIndexes[cellPosition.columnIdx + 1],
          rowIdx: cellPosition.rowIdx,
        );
      case MoveDirection.Up:
        return PlutoCellPosition(
          columnIdx: columnIndexes[cellPosition.columnIdx],
          rowIdx: cellPosition.rowIdx - 1,
        );
      case MoveDirection.Down:
        return PlutoCellPosition(
          columnIdx: columnIndexes[cellPosition.columnIdx],
          rowIdx: cellPosition.rowIdx + 1,
        );
    }
    throw Exception('MoveDirection case was not handled.');
  }

  /// 현재 셀을 direction 방향의 셀로 변경하고 스크롤을 이동 시킴
  /// [force] true : 편집상태에서 탭키로 좌우 이동 허용
  void moveCurrentCell(
    MoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (_currentCell == null) return;

    _checkCellValue = false;

    // @formatter:off
    if (!force && _isEditing && direction.horizontal) {
      // Select 타입의 컬럼은 편집 상태라도 좌우로 이동 가능
      if (currentColumn?.type?.name?.isSelect == true) {}
      // 수정 불가 컬럼은 편집 상태라도 좌우로 이동 가능
      else if (currentColumn?.type?.readOnly == true) {}
      // 그 밖의 수정 상태에서 좌우 이동 불가능
      else {
        _checkCellValue = true;
        return;
      }
    }
    // @formatter:on

    final columnIndexes = columnIndexesByShowFixed();
    final cellPosition =
    cellPositionByCellKey(_currentCell._key, columnIndexes);

    if (canNotMoveCell(cellPosition, direction)) {
      _checkCellValue = true;
      return;
    }

    final toMove = cellPositionToMove(
      cellPosition,
      direction,
      columnIndexes,
    );

    setCurrentCell(_rows[toMove.rowIdx].cells[_columns[toMove.columnIdx].field],
        toMove.rowIdx, notify: notify);

    if (direction.horizontal) {
      moveScrollByColumn(direction, cellPosition.columnIdx);
    } else if (direction.vertical) {
      moveScrollByRow(direction, cellPosition.rowIdx);
    }
    _checkCellValue = true;
    return;
  }

  /// offset 으로 direction 뱡향으로 스크롤
  void scrollByDirection(MoveDirection direction, double offset) {
    if (direction.isLeft && offset < _scroll.horizontal.offset ||
        direction.isRight && offset > _scroll.horizontal.offset) {
      _scroll.horizontal.jumpTo(offset);
    } else if (direction.isUp && offset < _scroll.vertical.offset ||
        direction.isDown && offset > _scroll.vertical.offset) {
      _scroll.vertical.jumpTo(offset);
    }
  }

  /// 해당 Row 로 세로축 스크롤
  void moveScrollByRow(MoveDirection direction, int rowIdx) {
    if (!direction.vertical) {
      return;
    }

    final double offset = direction.isUp
        ? ((rowIdx - 1) *
        (_style.rowHeight + PlutoDefaultSettings.rowBorderWidth))
        : ((rowIdx + 3) *
        (_style.rowHeight + PlutoDefaultSettings.rowBorderWidth)) +
        5 -
        (_layout.maxHeight);

    scrollByDirection(direction, offset);
  }

  /// 해당 Column 으로 가로축 스크롤
  void moveScrollByColumn(MoveDirection direction, int columnIdx) {
    if (!direction.horizontal) {
      return;
    }

    final PlutoColumn columnToMove =
    _columns[columnIndexesForShowFixed[columnIdx + direction.offset]];

    if (!canHorizontalCellScrollByDirection(
      direction,
      columnToMove,
    )) {
      return;
    }

    // 우측 이동의 경우 스크롤 위치를 셀의 우측 끝에 맞추기 위해 컬럼을 한칸 더 이동하여 계산.
    if (direction.isRight) columnIdx++;
    // 이동할 스크롤 포지션 계산을 위해 이동 할 컬럼까지의 넓이 합계를 구한다.
    double offset = layout.showFixedColumn == true
        ? bodyColumnsWidthAtColumnIdx(
        columnIdx + direction.offset - leftFixedColumnIndexes.length)
        : columnsWidthAtColumnIdx(columnIdx + direction.offset);

    if (direction.isRight) {
      final double screenOffset = _layout.showFixedColumn == true
          ? _layout.maxWidth - leftFixedColumnsWidth - rightFixedColumnsWidth
          : _layout.maxWidth;
      offset -= screenOffset;
      offset += 6;
    }

    scrollByDirection(direction, offset);
  }

  /// 컬럼 위치를 변경
  void moveColumn(GlobalKey columnKey, double offset) {
    // todo : 우측 고정 2개 상태에서 body 스크롤 좌측 끝으로 하고 우측 고정 컬럼 끼리 이동 시 오류
    double currentOffset = 0.0 - _scroll.horizontal.offset;

    int columnIndex;
    int indexToMove;

    final List<int> _columnIndexes =
    _layout.showFixedColumn ? columnIndexesForShowFixed : columnIndexes;

    for (var i = 0; i < _columnIndexes.length; i += 1) {
      if (currentOffset < offset &&
          offset < currentOffset + _columns[_columnIndexes[i]].width) {
        indexToMove = _columnIndexes[i];
      }

      currentOffset += _columns[_columnIndexes[i]].width;

      if (_columns[_columnIndexes[i]]._key == columnKey) {
        columnIndex = _columnIndexes[i];
      }

      if (indexToMove != null && columnIndex != null) {
        break;
      }
    }

    if (columnIndex == indexToMove || indexToMove == null) {
      return;
    }

    // 컬럼의 순서 변경
    _columns[columnIndex].fixed = _columns[indexToMove].fixed;
    if (indexToMove < columnIndex) {
      _columns.insert(indexToMove, _columns[columnIndex]);
      _columns.removeRange(columnIndex + 1, columnIndex + 2);
    } else {
      _columns.insert(indexToMove + 1, _columns[columnIndex]);
      _columns.removeRange(columnIndex, columnIndex + 1);
    }

    notifyListeners();
  }

  /// 컬럼 사이즈를 변경
  void resizeColumn(GlobalKey columnKey, double offset) {
    for (var i = 0; i < _columns.length; i += 1) {
      if (_columns[i]._key == columnKey) {
        final setWidth = _columns[i].width + offset;

        _columns[i].width = setWidth > PlutoDefaultSettings.minColumnWidth
            ? setWidth
            : PlutoDefaultSettings.minColumnWidth;
        break;
      }
    }

    notifyListeners();
  }

  /// 셀에 붙여넣기
  void pasteCellValue(List<List<String>> textList) {
    if (currentCellPosition == null) {
      return;
    }

    int columnStartIdx;

    int rowStartIdx;

    int columnEndIdx;

    int rowEndIdx;

    if (_currentSelectingPosition == null) {
      // 셀 선택이 없는 경우 : 현재 셀을 기준으로 순서대로 붙여 넣기
      columnStartIdx = currentCellPosition.columnIdx;

      rowStartIdx = currentCellPosition.rowIdx;

      columnEndIdx = currentCellPosition.columnIdx +
          textList.first.length;

      rowEndIdx = currentCellPosition.rowIdx + textList.length;
    } else {
      // 셀 선택이 있는 경우 : 선택 된 셀 범위에서 순서대로 붙여 넣기
      columnStartIdx = min(
          currentCellPosition.columnIdx, _currentSelectingPosition.columnIdx);

      rowStartIdx = min(
          currentCellPosition.rowIdx, _currentSelectingPosition.rowIdx);

      columnEndIdx = max(
          currentCellPosition.columnIdx, _currentSelectingPosition.columnIdx) +
          1;

      rowEndIdx = max(
          currentCellPosition.rowIdx, _currentSelectingPosition.rowIdx) + 1;
    }

    final _columnIndexes = columnIndexesByShowFixed();

    int textRowIdx = 0;

    for (var rowIdx = rowStartIdx; rowIdx < rowEndIdx; rowIdx += 1) {
      int textColumnIdx = 0;

      if (rowIdx >= _rows.length) {
        break;
      }

      if (textRowIdx > textList.length - 1) {
        textRowIdx = 0;
      }

      for (var columnIdx = columnStartIdx; columnIdx < columnEndIdx;
      columnIdx += 1) {
        if (columnIdx >= _columnIndexes.length) {
          break;
        }

        if (textColumnIdx > textList.first.length - 1) {
          textColumnIdx = 0;
        }

        changeCellValue(
            _rows[rowIdx].cells[_columns[_columnIndexes[columnIdx]].field]
                ._key,
            textList[textRowIdx][textColumnIdx], notify: false);

        ++textColumnIdx;
      }
      ++textRowIdx;
    }

    notifyListeners();
  }

  /// 셀 값 변경
  ///
  /// [callOnChangedEvent] PlutoOnChangedEventCallback 콜백을 발생 시킨다.
  void changeCellValue(GlobalKey cellKey, String value, {
    bool callOnChangedEvent = true,
    bool notify = true,
  }) {
    for (var rowIdx = 0; rowIdx < _rows.length; rowIdx += 1) {
      for (var columnIdx = 0; columnIdx < columnIndexes.length;
      columnIdx += 1) {
        final field = _columns[columnIndexes[columnIdx]].field;

        if (_rows[rowIdx].cells[field]._key == cellKey) {
          final currentColumn = _columns[columnIndexes[columnIdx]];

          // 읽기 전용 컬럼인 경우 값 변경 불가
          if (currentColumn.type.readOnly) {
            return;
          }

          final oldValue = _rows[rowIdx].cells[field].value;

          if (currentColumn.type.name.isSelect &&
              !currentColumn.type.selectItems.contains(value)) {
            value = oldValue;
          }

          _rows[rowIdx].cells[field].value = value;

          if (oldValue == value) {
            return;
          }

          if (callOnChangedEvent == true && _onChanged != null) {
            _onChanged(PlutoOnChangedEvent(
              columnIdx: columnIdx,
              rowIdx: rowIdx,
              value: value,
              oldValue: oldValue,
            ));
          }

          if (notify) {
            notifyListeners();
          }

          return;
        }
      }
    }
  }

  /// Select 모드에서 Row 선택 후 이벤트 발생.
  void handleOnSelectedRow() {
    if (_mode.isSelectRow == true && _onSelected != null) {
      _onSelected(PlutoOnSelectedEvent(row: currentRow));
    }
  }

  /// Select dialog 에서 선택 후 dialog 가 닫히고 난 후 동작.
  void handleAfterSelectingRow(PlutoCell cell, String value) {
    moveCurrentCell(MoveDirection.Down, notify: false);

    changeCellValue(cell._key, value, notify: false);

    setEditing(true, notify: false);

    notifyListeners();
  }

  /// 셀이 현재 선택 된 셀인지 여부
  bool isCurrentCell(PlutoCell cell) {
    return _currentCell != null && _currentCell._key == cell._key;
  }

  /// 화면 넓이에서 fixed 컬럼이 보여질지 여부
  bool isShowFixedColumn(double maxWidth) {
    final bool hasFixedColumn =
        leftFixedColumns.length > 0 || rightFixedColumns.length > 0;

    return hasFixedColumn &&
        maxWidth >
            (leftFixedColumnsWidth +
                rightFixedColumnsWidth +
                _style.bodyMinWidth +
                PlutoDefaultSettings.totalShadowLineWidth);
  }
}

class PlutoScrollController {
  LinkedScrollControllerGroup vertical;
  ScrollController leftFixedRowsVertical;
  ScrollController bodyRowsVertical;
  ScrollController rightRowsVerticalScroll;

  LinkedScrollControllerGroup horizontal;
  ScrollController bodyHeadersHorizontal;
  ScrollController bodyRowsHorizontal;

  PlutoScrollController({
    this.vertical,
    this.leftFixedRowsVertical,
    this.bodyRowsVertical,
    this.rightRowsVerticalScroll,
    this.horizontal,
    this.bodyHeadersHorizontal,
    this.bodyRowsHorizontal,
  });
}

class PlutoStyle {
  double bodyMinWidth;
  double rowHeight;

  PlutoStyle({
    this.bodyMinWidth = PlutoDefaultSettings.bodyMinWidth,
    this.rowHeight = PlutoDefaultSettings.rowHeight,
  });
}

class PlutoLayout {
  /// 화면 최대 넓이
  double maxWidth;

  /// 화면 최대 높이
  double maxHeight;

  /// 화면 사이즈에 따른 고정 컬럼 적용 여부
  /// true : 고정 컬럼이 있는 경우 고정 컬럼이 노출
  /// false : 고정 컬럼이 있지만 화면이 좁은 경우 일반 컬럼으로 노출
  bool showFixedColumn;

  PlutoLayout({
    this.maxWidth,
    this.maxHeight,
    this.showFixedColumn,
  });
}

class PlutoCellPosition {
  int columnIdx;
  int rowIdx;

  PlutoCellPosition({
    this.columnIdx,
    this.rowIdx,
  });
}
