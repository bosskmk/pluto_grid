part of '../../pluto_grid.dart';

class PlutoStateManager extends ChangeNotifier {
  /// [columns]
  ///
  /// Columns provided at grid start.
  List<PlutoColumn> get columns => [..._columns];
  List<PlutoColumn> _columns;

  /// [rows]
  ///
  /// Rows provided at grid start.
  List<PlutoRow> get rows => [..._rows];
  List<PlutoRow> _rows;

  /// [gridFocusNode]
  ///
  /// FocusNode to control keyboard input.
  FocusNode get gridFocusNode => _gridFocusNode;
  FocusNode _gridFocusNode;

  /// [scroll]
  ///
  /// Controller to control the scrolling of the grid.
  PlutoScrollController get scroll => _scroll;
  PlutoScrollController _scroll;

  /// [mode]
  ///
  /// Grid mode.
  PlutoMode get mode => _mode;
  PlutoMode _mode;

  /// [gridKey]
  ///
  /// GlobalKey
  GlobalKey get gridKey => _gridKey;
  final GlobalKey _gridKey;

  /// Event callback fired when cell value changes.
  final PlutoOnChangedEventCallback _onChanged;

  /// Event callback that occurs when a row is selected
  /// when the grid mode is selectRow.
  final PlutoOnSelectedEventCallback _onSelected;

  PlutoStateManager({
    @required List<PlutoColumn> columns,
    @required List<PlutoRow> rows,
    @required FocusNode gridFocusNode,
    @required PlutoScrollController scroll,
    PlutoMode mode,
    PlutoOnChangedEventCallback onChangedEventCallback,
    PlutoOnSelectedEventCallback onSelectedEventCallback,
  })  : this._columns = columns,
        this._rows = rows,
        this._gridFocusNode = gridFocusNode,
        this._scroll = scroll,
        this._mode = mode,
        this._onChanged = onChangedEventCallback,
        this._onSelected = onSelectedEventCallback,
        this._gridKey = GlobalKey();

  /// [keyManager]
  PlutoKeyManager _keyManager;

  PlutoKeyManager get keyManager => _keyManager;

  /// [eventManager]
  PlutoEventManager _eventManager;

  PlutoEventManager get eventManager => _eventManager;

  /// [columnIndexes]
  ///
  /// Column index list.
  List<int> get columnIndexes => _columns.asMap().keys.toList();

  /// [columnIndexesForShowFixed]
  ///
  /// List of column indexes in which the sequence is maintained
  /// while the Fixed column is visible.
  List<int> get columnIndexesForShowFixed {
    return [
      ...leftFixedColumnIndexes,
      ...bodyColumnIndexes,
      ...rightFixedColumnIndexes
    ];
  }

  /// [columnsWidth]
  ///
  /// Width of the entire column.
  double get columnsWidth {
    return _columns.fold(0, (double value, element) => value + element.width);
  }

  /// [leftFixedColumns]
  ///
  /// Left fixed columns.
  List<PlutoColumn> get leftFixedColumns {
    return _columns.where((e) => e.fixed.isLeft).toList();
  }

  /// [leftFixedColumnIndexes]
  ///
  /// Left fixed column Index List.
  List<int> get leftFixedColumnIndexes {
    return _columns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.fixed.isLeft) {
        return [...previousValue, columns.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  /// [leftFixedColumnsWidth]
  ///
  /// Width of the left fixed column.
  double get leftFixedColumnsWidth {
    return leftFixedColumns.fold(
        0, (double value, element) => value + element.width);
  }

  /// [rightFixedColumns]
  ///
  /// Right fixed columns.
  List<PlutoColumn> get rightFixedColumns {
    return _columns.where((e) => e.fixed.isRight).toList();
  }

  /// [rightFixedColumnIndexes]
  ///
  /// Right fixed column Index List.
  List<int> get rightFixedColumnIndexes {
    return _columns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.fixed.isRight) {
        return [...previousValue, columns.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  /// [rightFixedColumnsWidth]
  ///
  /// Width of the right fixed column.
  double get rightFixedColumnsWidth {
    return rightFixedColumns.fold(
        0, (double value, element) => value + element.width);
  }

  /// [bodyColumns]
  ///
  /// Body columns.
  List<PlutoColumn> get bodyColumns {
    return _columns.where((e) => e.fixed.isNone).toList();
  }

  /// [bodyColumnIndexes]
  ///
  /// Body column Index List.
  List<int> get bodyColumnIndexes {
    return bodyColumns.fold<List<int>>([], (List<int> previousValue, element) {
      if (element.fixed.isNone) {
        return [...previousValue, columns.indexOf(element)];
      }
      return previousValue;
    }).toList();
  }

  /// [bodyColumnsWidth]
  ///
  /// Width of the body column.
  double get bodyColumnsWidth {
    return bodyColumns.fold(
        0, (double value, element) => value + element.width);
  }

  /// [layout]
  ///
  /// Screen size, fixed column visibility.
  PlutoLayout get layout => _layout;
  PlutoLayout _layout = PlutoLayout();

  /// [currentColumn]
  ///
  /// Column of currently selected cell.
  PlutoColumn get currentColumn {
    if (currentColumnField == null) {
      return null;
    }

    return _columns
        .where((element) => element.field == currentColumnField)
        ?.first;
  }

  /// [currentColumnField]
  ///
  /// Column field name of currently selected cell.
  String get currentColumnField {
    if (currentRow == null) {
      return null;
    }

    return currentRow.cells.keys.firstWhere(
        (key) => currentRow.cells[key]._key == _currentCell?._key,
        orElse: () => null);
  }

  /// [gridGlobalOffset]
  ///
  /// Global offset of Grid.
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

  Offset _gridGlobalOffset;

  /// [currentCell]
  ///
  /// currently selected cell.
  PlutoCell get currentCell => _currentCell;
  PlutoCell _currentCell;

  /// [currentCellPosition]
  ///
  /// The position index value of the currently selected cell.
  PlutoCellPosition get currentCellPosition {
    if (_currentCell == null) {
      return null;
    }

    final columnIndexes = columnIndexesByShowFixed();

    return cellPositionByCellKey(_currentCell._key, columnIndexes);
  }

  /// [currentRowIdx]
  ///
  /// Row index of currently selected cell.
  int get currentRowIdx => _currentRowIdx;
  int _currentRowIdx;

  /// [currentRow]
  ///
  /// Row of currently selected cell.
  PlutoRow get currentRow {
    if (_currentRowIdx == null) {
      return null;
    }

    return _rows[_currentRowIdx];
  }

  /// [isEditing]
  ///
  /// Editing status of the current.
  bool get isEditing => _isEditing;
  bool _isEditing = false;

  /// [isSelecting]
  ///
  /// Multi-selection state.
  bool get isSelecting => _isSelecting;
  bool _isSelecting = false;

  /// [currentSelectingPosition]
  ///
  /// Current position of multi-select cell.
  /// Calculate the currently selected cell and its multi-selection range.
  PlutoCellPosition get currentSelectingPosition => _currentSelectingPosition;
  PlutoCellPosition _currentSelectingPosition;

  /// [currentSelectingText]
  ///
  /// String of multi-selected cells.
  /// Preserves the structure of the cells selected by the tabs and the enter key.
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

    final columnIndexes = columnIndexesByShowFixed();

    for (var i = rowStartIdx; i <= rowEndIdx; i += 1) {
      List<String> columnText = [];

      for (var j = columnStartIdx; j <= columnEndIdx; j += 1) {
        final String field = _columns[columnIndexes[j]].field;

        columnText.add(_rows[i].cells[field].value.toString());
      }

      textList.add(columnText.join('\t'));
    }

    return textList.join('\n');
  }

  /// [cellValueBeforeEditing]
  ///
  /// pre-modification cell value
  dynamic get cellValueBeforeEditing => _cellValueBeforeEditing;
  dynamic _cellValueBeforeEditing;

  /// [keyPressed]
  ///
  /// Currently pressed key
  PlutoKeyPressed get keyPressed => _keyPressed;
  PlutoKeyPressed _keyPressed = PlutoKeyPressed();

  /// True, check the change of value when moving cells.
  bool _checkCellValue = true;

  void setKeyManager(PlutoKeyManager keyManager) {
    _keyManager = keyManager;
  }

  void setEventManager(PlutoEventManager eventManager) {
    _eventManager = eventManager;
  }

  /// Change the selected cell.
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

  /// Update screen size information when LayoutBuilder builds.
  void setLayout(
      BoxConstraints size, double headerHeight, double footerHeight) {
    final _isShowFixedColumn = isShowFixedColumn(size.maxWidth);

    final bool notify = _layout.showFixedColumn != _isShowFixedColumn;

    _layout.maxWidth = size.maxWidth;
    _layout.maxHeight = size.maxHeight;
    _layout.showFixedColumn = _isShowFixedColumn;
    _layout.headerHeight = headerHeight;
    _layout.footerHeight = footerHeight;

    _gridGlobalOffset = null;

    if (notify) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Change the editing status of the current cell.
  void setEditing(
    bool flag, {
    bool notify = true,
  }) {
    if (mode.isSelect) {
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

    _currentSelectingPosition = null;

    if (notify) {
      notifyListeners();
    }

    _checkCellValue = true;
  }

  /// Change Multi-Select Status.
  void setSelecting(bool flag) {
    if (mode.isSelect) {
      return;
    }

    _checkCellValue = false;

    if (_currentCell == null || _isSelecting == flag) {
      _checkCellValue = true;
      return;
    }

    _isSelecting = flag;

    if (_isEditing == true) {
      setEditing(false, notify: false);
    }

    notifyListeners();

    _checkCellValue = true;
  }

  /// Sets the position of a multi-selected cell.
  void setCurrentSelectingPosition({
    int columnIdx,
    int rowIdx,
  }) {
    _currentSelectingPosition =
        PlutoCellPosition(columnIdx: columnIdx, rowIdx: rowIdx);

    notifyListeners();
  }

  /// Sets the position of a multi-selected cell.
  void setCurrentSelectingPositionWithOffset(Offset offset) {
    if (_currentCell == null) {
      return;
    }

    _checkCellValue = false;

    final double gridBodyOffsetDy = gridGlobalOffset.dy +
        PlutoDefaultSettings.gridBorderWidth +
        layout.headerHeight +
        PlutoDefaultSettings.rowTotalHeight;

    double currentCellOffsetDy =
        (currentRowIdx * PlutoDefaultSettings.rowTotalHeight) +
            gridBodyOffsetDy -
            _scroll.vertical.offset;

    if (gridBodyOffsetDy > offset.dy) {
      _checkCellValue = true;
      return;
    }

    int rowIdx = (((currentCellOffsetDy - offset.dy) /
                    PlutoDefaultSettings.rowTotalHeight)
                .ceil() -
            currentRowIdx)
        .abs();

    int columnIdx;

    double currentWidth = 0.0;
    currentWidth += gridGlobalOffset.dx;
    currentWidth += PlutoDefaultSettings.gridPadding;
    currentWidth += PlutoDefaultSettings.gridBorderWidth;

    final columnIndexes = columnIndexesByShowFixed();

    for (var i = 0; i < columnIndexes.length; i += 1) {
      currentWidth += _columns[columnIndexes[i]].width;

      if (currentWidth > offset.dx + _scroll.horizontal.offset) {
        columnIdx = i;
        break;
      }
    }

    if (columnIdx == null) {
      _checkCellValue = true;
      return;
    }

    setCurrentSelectingPosition(columnIdx: columnIdx, rowIdx: rowIdx);

    _checkCellValue = true;
  }

  /// Set the current pressed key state.
  void setKeyPressed(PlutoKeyPressed keyPressed) {
    _keyPressed = keyPressed;
  }

  void prependRows(List<PlutoRow> rows) {
    _rows.insertAll(0, rows);

    /// Update currentRowIdx
    if (_currentRowIdx != null) {
      _currentRowIdx = rows.length + _currentRowIdx;

      double offsetToMove = rows.length * PlutoDefaultSettings.rowTotalHeight;

      scrollByDirection(MoveDirection.Up, offsetToMove);
    }

    notifyListeners();
  }

  void appendRows(List<PlutoRow> rows) {
    _rows.addAll(rows);

    notifyListeners();
  }

  /// Update RowIdx to Current Cell.
  void updateCurrentRowIdx(Key cellKey) {
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

  /// Toggle the editing status of the current cell.
  void toggleEditing() => setEditing(!(_isEditing == true));

  /// Toggle whether the column is fixed or not.
  void toggleFixedColumn(Key columnKey, PlutoColumnFixed fixed) {
    for (var i = 0; i < _columns.length; i += 1) {
      if (_columns[i]._key == columnKey) {
        _columns[i].fixed =
            _columns[i].fixed.isFixed ? PlutoColumnFixed.None : fixed;
        break;
      }
    }
    notifyListeners();
  }

  /// Toggle column sorting.
  void toggleSortColumn(Key columnKey) {
    for (var i = 0; i < _columns.length; i += 1) {
      PlutoColumn column = _columns[i];

      if (column._key == columnKey) {
        final field = column.field;

        if (column.sort.isNone) {
          column.sort = PlutoColumnSort.Ascending;

          _rows.sort(
              (a, b) => a.cells[field].value.compareTo(b.cells[field].value));
        } else if (column.sort.isAscending) {
          column.sort = PlutoColumnSort.Descending;

          _rows.sort(
              (b, a) => a.cells[field].value.compareTo(b.cells[field].value));
        } else {
          column.sort = PlutoColumnSort.None;

          _rows.sort((a, b) {
            if (a.sortIdx == null || b.sortIdx == null) return 0;

            return a.sortIdx.compareTo(b.sortIdx);
          });
        }
      } else {
        column.sort = PlutoColumnSort.None;
      }
    }

    updateCurrentRowIdx(_currentCell?._key);

    notifyListeners();
  }

  /// Column width to index location based on full column.
  double columnsWidthAtColumnIdx(int columnIdx) {
    double width = 0.0;
    columnIndexes.getRange(0, columnIdx).forEach((idx) {
      width += _columns[idx].width;
    });
    return width;
  }

  /// Column width to index location based on Body column
  double bodyColumnsWidthAtColumnIdx(int columnIdx) {
    double width = 0.0;
    bodyColumnIndexes.getRange(0, columnIdx).forEach((idx) {
      width += columns[idx].width;
    });
    return width;
  }

  /// Column Index List by Fixed Column
  List<int> columnIndexesByShowFixed() {
    return _layout.showFixedColumn ? columnIndexesForShowFixed : columnIndexes;
  }

  /// Index position of cell in a column
  PlutoCellPosition cellPositionByCellKey(
      Key cellKey, List<int> columnIndexes) {
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

  /// Index of [column] in [columns]
  ///
  /// Depending on the state of the fixed column, the column order index
  /// must be referenced with the columnIndexesByShowFixed function.
  int columnIndex(PlutoColumn column) {
    final columnIndexes = columnIndexesByShowFixed();

    for (var i = 0; i < columnIndexes.length; i += 1) {
      if (_columns[columnIndexes[i]].field == column.field) {
        return i;
      }
    }

    return null;
  }

  /// Whether it is possible to move in the [direction] from [cellPosition].
  bool canMoveCell(PlutoCellPosition cellPosition, MoveDirection direction) {
    bool _canMoveCell;

    switch (direction) {
      case MoveDirection.Left:
        _canMoveCell = cellPosition.columnIdx > 0;
        break;
      case MoveDirection.Right:
        _canMoveCell = cellPosition.columnIdx <
            _rows[cellPosition.rowIdx].cells.length - 1;
        break;
      case MoveDirection.Up:
        _canMoveCell = cellPosition.rowIdx > 0;
        break;
      case MoveDirection.Down:
        _canMoveCell = cellPosition.rowIdx < _rows.length - 1;
        break;
    }

    assert(_canMoveCell != null);

    return _canMoveCell;
  }

  bool canNotMoveCell(PlutoCellPosition cellPosition, MoveDirection direction) {
    return !canMoveCell(cellPosition, direction);
  }

  /// Whether the cell can be scrolled when moving.
  bool canHorizontalCellScrollByDirection(
    MoveDirection direction,
    PlutoColumn columnToMove,
  ) {
    // 고정 컬럼이 보여지는 상태에서 이동 할 컬럼이 고정 컬럼인 경우 스크롤 불필요
    return !(_layout.showFixedColumn == true && columnToMove.fixed.isFixed);
  }

  /// Whether the cell is in a mutable state
  bool canChangeCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  }) {
    if (column.type.readOnly) {
      return false;
    }

    if (newValue.toString() == oldValue.toString()) {
      return false;
    }

    return true;
  }

  bool canNotChangeCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  }) {
    return !canChangeCellValue(
      column: column,
      newValue: newValue,
      oldValue: oldValue,
    );
  }

  /// Filter on cell value change
  dynamic filteredCellValue({
    PlutoColumn column,
    dynamic newValue,
    dynamic oldValue,
  }) {
    if (column.type.name.isSelect &&
        !column.type.selectItems.contains(newValue)) {
      newValue = oldValue;
    } else if (column.type.name.isDate) {
      final parseNewValue = DateTime.tryParse(newValue);

      if (parseNewValue == null) {
        newValue = oldValue;
      } else {
        newValue = intl.DateFormat(column.type.format).format(parseNewValue);
      }
    } else if (column.type.name.isTime) {
      final time = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');

      if (!time.hasMatch(newValue)) {
        newValue = oldValue;
      }
    }

    return newValue;
  }

  /// The index position of the cell to move in that direction in the current cell.
  ///
  /// [columnIndexes] : Provided differently depending on the current cell location
  /// - [leftFixedColumnIndexes]
  /// - [bodyColumnIndexes]
  /// - [rightFixedColumnIndexes]
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

  /// Change the current cell to the cell in the [direction] and move the scroll
  /// [force] true : Allow left and right movement with tab key in editing state.
  void moveCurrentCell(
    MoveDirection direction, {
    bool force = false,
    bool notify = true,
  }) {
    if (_currentCell == null) return;

    _checkCellValue = false;

    // @formatter:off
    if (!force && _isEditing && direction.horizontal) {
      // Select type column can be moved left or right even in edit state
      if (currentColumn?.type?.name?.isSelect == true) {}
      // Date type column can be moved left or right even in edit state
      else if (currentColumn?.type?.name?.isDate == true) {}
      // Time type column can be moved left or right even in edit state
      else if (currentColumn?.type?.name?.isTime == true) {}
      // Read only type column can be moved left or right even in edit state
      else if (currentColumn?.type?.readOnly == true) {}
      // Unable to move left and right in other modified states
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
      _eventManager.subject.add(
        PlutoCannotMoveCurrentCellEvent(
          cellPosition: cellPosition,
          direction: direction,
        ),
      );

      _checkCellValue = true;

      return;
    }

    final toMove = cellPositionToMove(
      cellPosition,
      direction,
      columnIndexes,
    );

    setCurrentCell(_rows[toMove.rowIdx].cells[_columns[toMove.columnIdx].field],
        toMove.rowIdx,
        notify: notify);

    if (direction.horizontal) {
      moveScrollByColumn(direction, cellPosition.columnIdx);
    } else if (direction.vertical) {
      moveScrollByRow(direction, cellPosition.rowIdx);
    }
    _checkCellValue = true;
    return;
  }

  void moveSelectingCell(MoveDirection direction) {
    final PlutoCellPosition cellPosition =
        currentSelectingPosition ?? currentCellPosition;

    if (canNotMoveCell(cellPosition, direction)) {
      _checkCellValue = true;
      return;
    }

    setCurrentSelectingPosition(
      columnIdx: cellPosition.columnIdx +
          (direction.horizontal ? direction.offset : 0),
      rowIdx: cellPosition.rowIdx + (direction.vertical ? direction.offset : 0),
    );

    if (direction.horizontal) {
      moveScrollByColumn(direction, cellPosition.columnIdx);
    } else {
      moveScrollByRow(direction, cellPosition.rowIdx);
    }
  }

  /// [direction] Scroll direction
  /// [offset] Scroll position
  void scrollByDirection(MoveDirection direction, double offset) {
    if (direction.vertical) {
      _scroll.vertical.jumpTo(offset);
    } else {
      _scroll.horizontal.jumpTo(offset);
    }
  }

  /// Scroll to [rowIdx] position.
  void moveScrollByRow(MoveDirection direction, int rowIdx) {
    if (!direction.vertical) {
      return;
    }

    final double rowSize = PlutoDefaultSettings.rowTotalHeight;

    final double gridOffset =
        PlutoDefaultSettings.gridPadding + PlutoDefaultSettings.shadowLineSize;

    final double screenOffset =
        _scroll.vertical.offset + _layout.offsetHeight - rowSize - gridOffset;

    double offsetToMove =
    direction.isUp ? (rowIdx - 1) * rowSize : (rowIdx + 1) * rowSize;

    final bool inScrollStart = _scroll.vertical.offset <= offsetToMove;

    final bool inScrollEnd = offsetToMove + rowSize <= screenOffset;

    if (inScrollStart && inScrollEnd) {
      return;
    } else if (inScrollEnd == false) {
      offsetToMove =
          _scroll.vertical.offset + offsetToMove + rowSize - screenOffset;
    }

    scrollByDirection(direction, offsetToMove);
  }

  /// Scroll to [columnIdx] position.
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

    // 이동할 스크롤 포지션 계산을 위해 이동 할 컬럼까지의 넓이 합계를 구한다.
    double offsetToMove = layout.showFixedColumn == true
        ? bodyColumnsWidthAtColumnIdx(
        columnIdx + direction.offset - leftFixedColumnIndexes.length)
        : columnsWidthAtColumnIdx(columnIdx + direction.offset);

    final double screenOffset = _layout.showFixedColumn == true
        ? _layout.maxWidth - leftFixedColumnsWidth - rightFixedColumnsWidth
        : _layout.maxWidth;

    if (direction.isRight) {
      if (offsetToMove > _scroll.horizontal.offset) {
        offsetToMove -= screenOffset;
        offsetToMove += PlutoDefaultSettings.totalShadowLineWidth;
        offsetToMove += columnToMove.width;

        if (offsetToMove < _scroll.horizontal.offset) {
          return;
        }
      }
    } else {
      final offsetToNeed = offsetToMove +
          columnToMove.width +
          PlutoDefaultSettings.totalShadowLineWidth;

      final currentOffset = screenOffset + _scroll.horizontal.offset;

      if (offsetToNeed > currentOffset) {
        offsetToMove = _scroll.horizontal.offset + offsetToNeed - currentOffset;
      } else if (offsetToMove > _scroll.horizontal.offset) {
        return;
      }
    }

    scrollByDirection(direction, offsetToMove);
  }

  /// Change column position.
  void moveColumn(Key columnKey, double offset) {
    offset -= gridGlobalOffset.dx;

    final List<int> columnIndexes = columnIndexesByShowFixed();

    Function findColumnIndex = (int i) {
      if (_columns[columnIndexes[i]]._key == columnKey) {
        return columnIndexes[i];
      }
      return null;
    };

    Function findIndexToMove = () {
      final double minLeft =
      _layout.showFixedColumn ? leftFixedColumnsWidth : 0;

      final double minRight = _layout.showFixedColumn
          ? _layout.maxWidth - rightFixedColumnsWidth
          : _layout.maxWidth;

      double currentOffset = 0.0;

      int startIndexToMove = 0;

      if (minRight < offset) {
        currentOffset = minRight;
        startIndexToMove = _columns.length - rightFixedColumns.length;
      } else if (minLeft < offset) {
        currentOffset -= _scroll.horizontal.offset;
      }

      return (int i) {
        if (i == startIndexToMove) {
          if (currentOffset < offset &&
              offset <
                  currentOffset +
                      _columns[columnIndexes[startIndexToMove]].width) {
            return columnIndexes[startIndexToMove];
          }

          currentOffset += _columns[columnIndexes[startIndexToMove]].width;
          ++startIndexToMove;
        }

        return null;
      };
    }();

    int columnIndex;
    int indexToMove;

    for (var i = 0; i < columnIndexes.length; i += 1) {
      if (columnIndex == null) {
        columnIndex = findColumnIndex(i);
      }

      if (indexToMove == null) {
        indexToMove = findIndexToMove(i);
      }

      if (indexToMove != null && columnIndex != null) {
        break;
      }
    }

    if (columnIndex == indexToMove ||
        columnIndex == null ||
        indexToMove == null) {
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

  /// Change column size
  void resizeColumn(Key columnKey, double offset) {
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

  /// Paste based on current cell
  void pasteCellValue(List<List<String>> textList) {
    if (currentCellPosition == null) {
      return;
    }

    int columnStartIdx;

    int rowStartIdx;

    int columnEndIdx;

    int rowEndIdx;

    if (_currentSelectingPosition == null) {
      // No cell selection : Paste in order based on the current cell
      columnStartIdx = currentCellPosition.columnIdx;

      rowStartIdx = currentCellPosition.rowIdx;

      columnEndIdx = currentCellPosition.columnIdx + textList.first.length;

      rowEndIdx = currentCellPosition.rowIdx + textList.length;
    } else {
      // If there are selected cells : Paste in order from selected cell range
      columnStartIdx = min(
          currentCellPosition.columnIdx, _currentSelectingPosition.columnIdx);

      rowStartIdx =
          min(currentCellPosition.rowIdx, _currentSelectingPosition.rowIdx);

      columnEndIdx = max(currentCellPosition.columnIdx,
          _currentSelectingPosition.columnIdx) +
          1;

      rowEndIdx =
          max(currentCellPosition.rowIdx, _currentSelectingPosition.rowIdx) + 1;
    }

    final List<int> columnIndexes = columnIndexesByShowFixed();

    int textRowIdx = 0;

    for (var rowIdx = rowStartIdx; rowIdx < rowEndIdx; rowIdx += 1) {
      int textColumnIdx = 0;

      if (rowIdx >= _rows.length) {
        break;
      }

      if (textRowIdx > textList.length - 1) {
        textRowIdx = 0;
      }

      for (var columnIdx = columnStartIdx;
      columnIdx < columnEndIdx;
      columnIdx += 1) {
        if (columnIdx >= columnIndexes.length) {
          break;
        }

        if (textColumnIdx > textList.first.length - 1) {
          textColumnIdx = 0;
        }

        final currentColumn = _columns[columnIndexes[columnIdx]];

        final currentRow = _rows[rowIdx].cells[currentColumn.field];

        dynamic newValue = textList[textRowIdx][textColumnIdx];

        final dynamic oldValue = currentRow.value;

        newValue = filteredCellValue(
          column: currentColumn,
          newValue: newValue,
          oldValue: oldValue,
        );

        if (canNotChangeCellValue(
          column: currentColumn,
          newValue: newValue,
          oldValue: oldValue,
        )) {
          ++textColumnIdx;
          continue;
        }

        currentRow.value =
            newValue = castValueByColumnType(newValue, currentColumn);

        _onChanged(PlutoOnChangedEvent(
          columnIdx: columnIndexes[columnIdx],
          column: currentColumn,
          rowIdx: rowIdx,
          row: _rows[rowIdx],
          value: newValue,
          oldValue: oldValue,
        ));

        ++textColumnIdx;
      }
      ++textRowIdx;
    }

    notifyListeners();
  }

  /// Change cell value
  ///
  /// [callOnChangedEvent] triggers a [PlutoOnChangedEventCallback] callback.
  void changeCellValue(Key cellKey,
      dynamic value, {
        bool callOnChangedEvent = true,
        bool notify = true,
      }) {
    for (var rowIdx = 0; rowIdx < _rows.length; rowIdx += 1) {
      for (var columnIdx = 0;
      columnIdx < columnIndexes.length;
      columnIdx += 1) {
        final field = _columns[columnIndexes[columnIdx]].field;

        if (_rows[rowIdx].cells[field]._key == cellKey) {
          final currentColumn = _columns[columnIndexes[columnIdx]];

          final dynamic oldValue = _rows[rowIdx].cells[field].value;

          value = filteredCellValue(
            column: currentColumn,
            newValue: value,
            oldValue: oldValue,
          );

          if (canNotChangeCellValue(
            column: currentColumn,
            newValue: value,
            oldValue: oldValue,
          )) {
            return;
          }

          _rows[rowIdx].cells[field].value =
              value = castValueByColumnType(value, currentColumn);

          if (callOnChangedEvent == true && _onChanged != null) {
            _onChanged(PlutoOnChangedEvent(
              columnIdx: columnIdx,
              column: currentColumn,
              rowIdx: rowIdx,
              row: _rows[rowIdx],
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

  /// Cast the value according to the column type.
  dynamic castValueByColumnType(dynamic value, PlutoColumn column) {
    if (column.type.name.isNumber && value.runtimeType != num) {
      return num.tryParse(value.toString()) ?? 0;
    }

    return value;
  }

  /// Event occurred after selecting Row in Select mode.
  void handleOnSelected() {
    if (_mode.isSelect == true && _onSelected != null) {
      _onSelected(PlutoOnSelectedEvent(row: currentRow, cell: currentCell));
    }
  }

  /// The action that is selected in the Select dialog
  /// and processed after the dialog is closed.
  void handleAfterSelectingRow(PlutoCell cell, dynamic value) {
    moveCurrentCell(MoveDirection.Down, notify: false);

    changeCellValue(cell._key, value, notify: false);

    setEditing(true, notify: false);

    notifyListeners();
  }

  /// Whether the cell is the currently selected cell.
  bool isCurrentCell(PlutoCell cell) {
    return _currentCell != null && _currentCell._key == cell._key;
  }

  /// Whether a fixed column is displayed in the screen width.
  bool isShowFixedColumn(double maxWidth) {
    final bool hasFixedColumn =
        leftFixedColumns.length > 0 || rightFixedColumns.length > 0;

    return hasFixedColumn &&
        maxWidth >
            (leftFixedColumnsWidth +
                rightFixedColumnsWidth +
                PlutoDefaultSettings.bodyMinWidth +
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

class PlutoLayout {
  /// Screen width
  double maxWidth;

  /// Screen height
  double maxHeight;

  /// grid header height
  double headerHeight;

  /// grid footer height
  double footerHeight;

  /// Whether to apply a fixed column according to the screen size.
  /// true : If there is a fixed column, the fixed column is exposed.
  /// false : If there is a fixed column but the screen is narrow, it is exposed as a normal column.
  bool showFixedColumn;

  PlutoLayout({
    this.maxWidth,
    this.maxHeight,
    this.showFixedColumn,
    this.headerHeight,
    this.footerHeight,
  });

  double get offsetHeight => maxHeight - headerHeight - footerHeight;
}

class PlutoCellPosition {
  int columnIdx;
  int rowIdx;

  PlutoCellPosition({
    this.columnIdx,
    this.rowIdx,
  });
}

class PlutoKeyPressed {
  bool shift;

  PlutoKeyPressed({
    this.shift = false,
  });
}
