import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IGridState {
  GlobalKey get gridKey;

  PlutoGridMode get mode;

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

  PlutoGridLocaleText get localeText;

  void setGridKey(Key key);

  void setKeyManager(PlutoKeyManager keyManager);

  void setEventManager(PlutoEventManager eventManager);

  void setGridMode(PlutoGridMode mode);

  void setOnChanged(PlutoOnChangedEventCallback onChanged);

  void setCreateHeader(CreateHeaderCallBack createHeader);

  void setCreateFooter(CreateFooterCallBack createFooter);

  void setOnSelected(PlutoOnSelectedEventCallback onSelected);

  void setConfiguration(PlutoConfiguration configuration);

  void resetCurrentState({notify = true});

  /// Event occurred after selecting Row in Select mode.
  void handleOnSelected();
}

mixin GridState implements IPlutoState {
  GlobalKey get gridKey => _gridKey;

  GlobalKey _gridKey;

  PlutoGridMode get mode => _mode;

  PlutoGridMode _mode;

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

  PlutoGridLocaleText get localeText => configuration.localeText;

  void setKeyManager(PlutoKeyManager keyManager) {
    _keyManager = keyManager;
  }

  void setEventManager(PlutoEventManager eventManager) {
    _eventManager = eventManager;
  }

  void setGridMode(PlutoGridMode mode) {
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

  void resetCurrentState({notify = true}) {
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
