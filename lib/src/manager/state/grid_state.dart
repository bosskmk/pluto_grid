import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IGridState {
  GlobalKey? get gridKey;

  PlutoGridMode? get mode;

  PlutoGridConfiguration? get configuration;

  PlutoGridKeyManager? get keyManager;

  PlutoGridEventManager? get eventManager;

  /// Event callback fired when cell value changes.
  PlutoOnChangedEventCallback? get onChanged;

  /// Event callback that occurs when a row is selected
  /// when the grid mode is selectRow.
  PlutoOnSelectedEventCallback? get onSelected;

  CreateHeaderCallBack? get createHeader;

  CreateFooterCallBack? get createFooter;

  PlutoGridLocaleText get localeText;

  void setGridKey(GlobalKey key);

  void setKeyManager(PlutoGridKeyManager keyManager);

  void setEventManager(PlutoGridEventManager eventManager);

  void setGridMode(PlutoGridMode mode);

  void setOnChanged(PlutoOnChangedEventCallback onChanged);

  void setCreateHeader(CreateHeaderCallBack createHeader);

  void setCreateFooter(CreateFooterCallBack createFooter);

  void setOnSelected(PlutoOnSelectedEventCallback onSelected);

  void setConfiguration(PlutoGridConfiguration configuration);

  void resetCurrentState({bool notify = true});

  /// Event occurred after selecting Row in Select mode.
  void handleOnSelected();
}

mixin GridState implements IPlutoGridState {
  GlobalKey? get gridKey => _gridKey;

  GlobalKey? _gridKey;

  PlutoGridMode? get mode => _mode;

  PlutoGridMode? _mode;

  PlutoGridConfiguration? get configuration => _configuration;

  PlutoGridConfiguration? _configuration;

  PlutoGridKeyManager? _keyManager;

  PlutoGridKeyManager? get keyManager => _keyManager;

  PlutoGridEventManager? _eventManager;

  PlutoGridEventManager? get eventManager => _eventManager;

  PlutoOnChangedEventCallback? get onChanged => _onChanged;

  PlutoOnChangedEventCallback? _onChanged;

  PlutoOnSelectedEventCallback? get onSelected => _onSelected;

  PlutoOnSelectedEventCallback? _onSelected;

  PlutoOnRowCheckedEventCallback? get onRowChecked => _onRowChecked;

  PlutoOnRowCheckedEventCallback? _onRowChecked;

  CreateHeaderCallBack? get createHeader => _createHeader;

  CreateHeaderCallBack? _createHeader;

  CreateFooterCallBack? get createFooter => _createFooter;

  CreateFooterCallBack? _createFooter;

  PlutoGridLocaleText get localeText => configuration!.localeText;

  void setKeyManager(PlutoGridKeyManager? keyManager) {
    _keyManager = keyManager;
  }

  void setEventManager(PlutoGridEventManager? eventManager) {
    _eventManager = eventManager;
  }

  void setGridMode(PlutoGridMode? mode) {
    _mode = mode;
  }

  void setOnChanged(PlutoOnChangedEventCallback? onChanged) {
    _onChanged = onChanged;
  }

  void setOnSelected(PlutoOnSelectedEventCallback? onSelected) {
    _onSelected = onSelected;
  }

  void setOnRowChecked(PlutoOnRowCheckedEventCallback? onRowChecked) {
    _onRowChecked = onRowChecked;
  }

  void setCreateHeader(CreateHeaderCallBack? createHeader) {
    _createHeader = createHeader;
  }

  void setCreateFooter(CreateFooterCallBack? createFooter) {
    _createFooter = createFooter;
  }

  void setConfiguration(PlutoGridConfiguration? configuration) {
    _configuration = configuration ?? PlutoGridConfiguration();

    _configuration!.applyColumnFilter(refColumns);
  }

  void setGridKey(GlobalKey key) {
    _gridKey = key;
  }

  void resetCurrentState({bool notify = true}) {
    clearCurrentCell(notify: false);

    clearCurrentSelectingPosition(notify: false);

    if (notify) {
      notifyListeners();
    }
  }

  void handleOnSelected() {
    if (_mode.isSelect == true && _onSelected != null) {
      _onSelected!(
          PlutoGridOnSelectedEvent(row: currentRow, cell: currentCell));
    }
  }
}
