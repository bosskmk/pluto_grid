part of '../../../pluto_grid.dart';

abstract class IGridState {
  GlobalKey get gridKey;

  /// FocusNode to control keyboard input.
  FocusNode get gridFocusNode;

  FocusNode _gridFocusNode;

  PlutoMode get mode;

  PlutoMode _mode;

  /// Screen size, fixed column visibility.
  PlutoLayout get layout;

  PlutoLayout _layout;

  /// Global offset of Grid.
  Offset get gridGlobalOffset;

  Offset _gridGlobalOffset;

  /// [keyManager]
  PlutoKeyManager _keyManager;

  PlutoKeyManager get keyManager;

  void setKeyManager(PlutoKeyManager keyManager);

  /// [eventManager]
  PlutoEventManager _eventManager;

  PlutoEventManager get eventManager;

  void setEventManager(PlutoEventManager eventManager);

  /// Event callback fired when cell value changes.
  PlutoOnChangedEventCallback _onChanged;

  /// Event callback that occurs when a row is selected
  /// when the grid mode is selectRow.
  PlutoOnSelectedEventCallback _onSelected;

  void resetCurrentState({notify = true});

  /// Update screen size information when LayoutBuilder builds.
  void setLayout(
      BoxConstraints size, double headerHeight, double footerHeight);

  /// Event occurred after selecting Row in Select mode.
  void handleOnSelected();
}

mixin GridState implements IPlutoState {
  GlobalKey get gridKey => _gridKey;

  GlobalKey _gridKey;

  FocusNode get gridFocusNode => _gridFocusNode;

  FocusNode _gridFocusNode;

  PlutoMode get mode => _mode;

  PlutoMode _mode;

  PlutoLayout get layout => _layout;

  PlutoLayout _layout = PlutoLayout();

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

  PlutoKeyManager _keyManager;

  PlutoKeyManager get keyManager => _keyManager;

  void setKeyManager(PlutoKeyManager keyManager) {
    _keyManager = keyManager;
  }

  PlutoEventManager _eventManager;

  PlutoEventManager get eventManager => _eventManager;

  void setEventManager(PlutoEventManager eventManager) {
    _eventManager = eventManager;
  }

  PlutoOnChangedEventCallback _onChanged;

  PlutoOnSelectedEventCallback _onSelected;

  void resetCurrentState({notify = true}) {
    _currentRowIdx = null;
    _currentCell = null;
    _currentSelectingPosition = null;

    if (notify) {
      notifyListeners();
    }
  }

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

  void handleOnSelected() {
    if (_mode.isSelect == true && _onSelected != null) {
      _onSelected(PlutoOnSelectedEvent(row: currentRow, cell: currentCell));
    }
  }
}