part of '../../../pluto_grid.dart';

abstract class IGridState {
  GlobalKey get gridKey;

  /// FocusNode to control keyboard input.
  FocusNode get gridFocusNode;

  FocusNode _gridFocusNode;

  PlutoMode get mode;

  PlutoMode _mode;

  PlutoConfiguration get configuration;

  PlutoConfiguration _configuration;

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

  PlutoConfiguration get configuration => _configuration;

  PlutoConfiguration _configuration;

  PlutoKeyManager _keyManager;

  PlutoKeyManager get keyManager => _keyManager;

  PlutoEventManager _eventManager;

  PlutoEventManager get eventManager => _eventManager;

  PlutoOnChangedEventCallback _onChanged;

  PlutoOnSelectedEventCallback _onSelected;

  void setKeyManager(PlutoKeyManager keyManager) {
    _keyManager = keyManager;
  }

  void setEventManager(PlutoEventManager eventManager) {
    _eventManager = eventManager;
  }

  void resetCurrentState({notify = true}) {
    _currentRowIdx = null;
    clearCurrentCell(notify: false);
    _currentSelectingPosition = null;

    if (notify) {
      notifyListeners();
    }
  }

  void handleOnSelected() {
    if (_mode.isSelect == true && _onSelected != null) {
      _onSelected(PlutoOnSelectedEvent(row: currentRow, cell: currentCell));
    }
  }
}
