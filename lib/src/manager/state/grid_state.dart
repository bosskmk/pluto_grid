part of '../../../pluto_grid.dart';

abstract class IGridState {
  GlobalKey get gridKey;

  /// FocusNode to control keyboard input.
  FocusNode get gridFocusNode;

  PlutoMode get mode;

  PlutoConfiguration get configuration;

  PlutoKeyManager get keyManager;

  PlutoEventManager get eventManager;

  /// Event callback fired when cell value changes.
  PlutoOnChangedEventCallback get onChanged;

  /// Event callback that occurs when a row is selected
  /// when the grid mode is selectRow.
  PlutoOnSelectedEventCallback get onSelected;

  CreateHeaderCallBack get createHeader;

  CreateFooterCallBack get createFooter;

  bool get keepFocus;

  bool get hasFocus;

  PlutoGridLocaleText get localeText;

  void setGridKey(Key key);

  void setKeyManager(PlutoKeyManager keyManager);

  void setEventManager(PlutoEventManager eventManager);

  void setGridFocusNode(FocusNode focusNode);

  void setGridMode(PlutoMode mode);

  void setOnChanged(PlutoOnChangedEventCallback onChanged);

  void setCreateHeader(CreateHeaderCallBack createHeader);

  void setCreateFooter(CreateFooterCallBack createFooter);

  void setOnSelected(PlutoOnSelectedEventCallback onSelected);

  void setConfiguration(PlutoConfiguration configuration);

  void setKeepFocus(bool flag);

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

  PlutoOnChangedEventCallback get onChanged => _onChanged;

  PlutoOnChangedEventCallback _onChanged;

  PlutoOnSelectedEventCallback get onSelected => _onSelected;

  PlutoOnSelectedEventCallback _onSelected;

  CreateHeaderCallBack get createHeader => _createHeader;

  CreateHeaderCallBack _createHeader;

  CreateFooterCallBack get createFooter => _createFooter;

  CreateFooterCallBack _createFooter;

  bool get keepFocus => _keepFocus;

  bool _keepFocus = false;

  bool get hasFocus => _gridFocusNode != null && _gridFocusNode.hasFocus;

  PlutoGridLocaleText get localeText => configuration.localeText;

  void setKeyManager(PlutoKeyManager keyManager) {
    _keyManager = keyManager;
  }

  void setEventManager(PlutoEventManager eventManager) {
    _eventManager = eventManager;
  }

  void setGridFocusNode(FocusNode focusNode) {
    _gridFocusNode = focusNode;
  }

  void setGridMode(PlutoMode mode) {
    _mode = mode;
  }

  void setOnChanged(PlutoOnChangedEventCallback onChanged) {
    _onChanged = onChanged;
  }

  void setOnSelected(PlutoOnSelectedEventCallback onSelected) {
    _onSelected = onSelected;
  }

  void setCreateHeader(CreateHeaderCallBack createHeader) {
    _createHeader = createHeader;
  }

  void setCreateFooter(CreateFooterCallBack createFooter) {
    _createFooter = createFooter;
  }

  void setConfiguration(PlutoConfiguration configuration) {
    _configuration = configuration ?? PlutoConfiguration();
  }

  void setGridKey(Key key) {
    _gridKey = key;
  }

  void setKeepFocus(bool flag, {bool notify: true}) {
    if (_keepFocus == flag) {
      return;
    }

    _keepFocus = flag;

    if (_keepFocus == true) {
      _gridFocusNode.requestFocus();
    }

    if (notify) {
      notifyListeners();
    }
  }

  void resetCurrentState({notify = true}) {
    clearCurrentRowIdx(notify: false);

    clearCurrentCell(notify: false);

    clearCurrentSelectingPosition(notify: false);

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
