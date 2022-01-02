import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IGridState {
  GlobalKey? get gridKey;

  PlutoGridMode? get mode;

  PlutoGridConfiguration? get configuration;

  PlutoGridKeyManager get keyManager;

  PlutoGridEventManager get eventManager;

  PlutoGridNodeManager get nodeManager;

  /// Event callback fired when cell value changes.
  PlutoOnChangedEventCallback? get onChanged;

  /// Event callback that occurs when a row is selected
  /// when the grid mode is selectRow.
  PlutoOnSelectedEventCallback? get onSelected;

  PlutoOnRowCheckedEventCallback? get onRowChecked;

  PlutoOnRowDoubleTapEventCallback? get onRowDoubleTap;

  PlutoOnRowSecondaryTapEventCallback? get onRowSecondaryTap;

  PlutoOnRowsMovedEventCallback? get onRowsMoved;

  CreateHeaderCallBack? get createHeader;

  CreateFooterCallBack? get createFooter;

  PlutoGridLocaleText get localeText;

  void setGridKey(GlobalKey key);

  void setKeyManager(PlutoGridKeyManager keyManager);

  void setEventManager(PlutoGridEventManager eventManager);

  void setNodeManager(PlutoGridNodeManager nodeManager);

  void setGridMode(PlutoGridMode mode);

  void setOnChanged(PlutoOnChangedEventCallback onChanged);

  void setCreateHeader(CreateHeaderCallBack createHeader);

  void setCreateFooter(CreateFooterCallBack createFooter);

  void setOnSelected(PlutoOnSelectedEventCallback onSelected);

  void setOnRowChecked(PlutoOnRowCheckedEventCallback? onRowChecked);

  void setOnRowDoubleTap(PlutoOnRowDoubleTapEventCallback? onDoubleTap);

  void setOnRowSecondaryTap(
      PlutoOnRowSecondaryTapEventCallback? onSecondaryTap);

  void setOnRowsMoved(PlutoOnRowsMovedEventCallback? onRowsMoved);

  void setConfiguration(PlutoGridConfiguration configuration);

  void resetCurrentState({bool notify = true});

  /// Event occurred after selecting Row in Select mode.
  void handleOnSelected();
}

mixin GridState implements IPlutoGridState {
  @override
  GlobalKey? get gridKey => _gridKey;

  GlobalKey? _gridKey;

  @override
  PlutoGridMode? get mode => _mode;

  PlutoGridMode? _mode;

  @override
  PlutoGridConfiguration? get configuration => _configuration;

  PlutoGridConfiguration? _configuration;

  late PlutoGridKeyManager _keyManager;

  @override
  PlutoGridKeyManager get keyManager => _keyManager;

  late PlutoGridEventManager _eventManager;

  @override
  PlutoGridEventManager get eventManager => _eventManager;

  late PlutoGridNodeManager _nodeManager;

  @override
  PlutoGridNodeManager get nodeManager => _nodeManager;

  @override
  PlutoOnChangedEventCallback? get onChanged => _onChanged;

  PlutoOnChangedEventCallback? _onChanged;

  @override
  PlutoOnSelectedEventCallback? get onSelected => _onSelected;

  PlutoOnSelectedEventCallback? _onSelected;

  @override
  PlutoOnRowCheckedEventCallback? get onRowChecked => _onRowChecked;

  PlutoOnRowCheckedEventCallback? _onRowChecked;

  @override
  PlutoOnRowDoubleTapEventCallback? get onRowDoubleTap => _onRowDoubleTap;

  PlutoOnRowDoubleTapEventCallback? _onRowDoubleTap;

  @override
  PlutoOnRowSecondaryTapEventCallback? get onRowSecondaryTap =>
      _onRowSecondaryTap;

  PlutoOnRowSecondaryTapEventCallback? _onRowSecondaryTap;

  @override
  PlutoOnRowsMovedEventCallback? get onRowsMoved => _onRowsMoved;

  PlutoOnRowsMovedEventCallback? _onRowsMoved;

  @override
  CreateHeaderCallBack? get createHeader => _createHeader;

  CreateHeaderCallBack? _createHeader;

  @override
  CreateFooterCallBack? get createFooter => _createFooter;

  CreateFooterCallBack? _createFooter;

  @override
  PlutoGridLocaleText get localeText => configuration!.localeText;

  @override
  void setKeyManager(PlutoGridKeyManager keyManager) {
    _keyManager = keyManager;
  }

  @override
  void setEventManager(PlutoGridEventManager eventManager) {
    _eventManager = eventManager;
  }

  @override
  void setNodeManager(PlutoGridNodeManager nodeManager) {
    _nodeManager = nodeManager;
  }

  @override
  void setGridMode(PlutoGridMode? mode) {
    _mode = mode;
  }

  @override
  void setOnChanged(PlutoOnChangedEventCallback? onChanged) {
    _onChanged = onChanged;
  }

  @override
  void setOnSelected(PlutoOnSelectedEventCallback? onSelected) {
    _onSelected = onSelected;
  }

  @override
  void setOnRowChecked(PlutoOnRowCheckedEventCallback? onRowChecked) {
    _onRowChecked = onRowChecked;
  }

  @override
  void setOnRowDoubleTap(PlutoOnRowDoubleTapEventCallback? onRowDoubleTap) {
    _onRowDoubleTap = onRowDoubleTap;
  }

  @override
  void setOnRowSecondaryTap(
      PlutoOnRowSecondaryTapEventCallback? onRowSecondaryTap) {
    _onRowSecondaryTap = onRowSecondaryTap;
  }

  @override
  void setOnRowsMoved(PlutoOnRowsMovedEventCallback? onRowsMoved) {
    _onRowsMoved = onRowsMoved;
  }

  @override
  void setCreateHeader(CreateHeaderCallBack? createHeader) {
    _createHeader = createHeader;
  }

  @override
  void setCreateFooter(CreateFooterCallBack? createFooter) {
    _createFooter = createFooter;
  }

  @override
  void setConfiguration(PlutoGridConfiguration? configuration) {
    _configuration = configuration ?? const PlutoGridConfiguration();

    _configuration!.updateLocale();

    _configuration!.applyColumnFilter(refColumns);
  }

  @override
  void setGridKey(GlobalKey key) {
    _gridKey = key;
  }

  @override
  void resetCurrentState({bool notify = true}) {
    clearCurrentCell(notify: false);

    clearCurrentSelecting(notify: false);

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void handleOnSelected() {
    if (_mode.isSelect == true && _onSelected != null) {
      _onSelected!(
          PlutoGridOnSelectedEvent(row: currentRow, cell: currentCell));
    }
  }
}
