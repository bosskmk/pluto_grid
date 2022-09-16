import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IGridState {
  GlobalKey? get gridKey;

  PlutoGridMode? get mode;

  PlutoGridConfiguration get configuration;

  PlutoGridKeyManager? get keyManager;

  PlutoGridEventManager? get eventManager;

  PlutoOnChangedEventCallback? get onChanged;

  PlutoOnSelectedEventCallback? get onSelected;

  PlutoOnSortedEventCallback? get onSorted;

  PlutoOnRowCheckedEventCallback? get onRowChecked;

  PlutoOnRowDoubleTapEventCallback? get onRowDoubleTap;

  PlutoOnRowSecondaryTapEventCallback? get onRowSecondaryTap;

  PlutoOnRowsMovedEventCallback? get onRowsMoved;

  PlutoColumnMenuDelegate get columnMenuDelegate;

  CreateHeaderCallBack? get createHeader;

  CreateFooterCallBack? get createFooter;

  PlutoGridLocaleText get localeText;

  PlutoGridStyleConfig get style;

  void setGridKey(GlobalKey key);

  void setKeyManager(PlutoGridKeyManager keyManager);

  void setEventManager(PlutoGridEventManager eventManager);

  void setGridMode(PlutoGridMode mode);

  void setOnChanged(PlutoOnChangedEventCallback onChanged);

  void setColumnMenuDelegate(PlutoColumnMenuDelegate? columnMenuDelegate);

  void setCreateHeader(CreateHeaderCallBack createHeader);

  void setCreateFooter(CreateFooterCallBack createFooter);

  void setOnSelected(PlutoOnSelectedEventCallback onSelected);

  void setOnSorted(PlutoOnSortedEventCallback? onSorted);

  void setOnRowChecked(PlutoOnRowCheckedEventCallback? onRowChecked);

  void setOnRowDoubleTap(PlutoOnRowDoubleTapEventCallback? onDoubleTap);

  void setOnRowSecondaryTap(
      PlutoOnRowSecondaryTapEventCallback? onSecondaryTap);

  void setOnRowsMoved(PlutoOnRowsMovedEventCallback? onRowsMoved);

  void setConfiguration(
    PlutoGridConfiguration? configuration, {
    bool updateLocale = true,
    bool applyColumnFilter = true,
  });

  void resetCurrentState({bool notify = true});

  /// Event occurred after selecting Row in Select mode.
  void handleOnSelected();

  void forceUpdate();
}

mixin GridState implements IPlutoGridState {
  @override
  GlobalKey? get gridKey => _gridKey;

  GlobalKey? _gridKey;

  @override
  PlutoGridMode? get mode => _mode;

  PlutoGridMode? _mode;

  @override
  PlutoGridConfiguration get configuration => _configuration!;

  PlutoGridConfiguration? _configuration;

  PlutoGridKeyManager? _keyManager;

  @override
  PlutoGridKeyManager? get keyManager => _keyManager;

  PlutoGridEventManager? _eventManager;

  @override
  PlutoGridEventManager? get eventManager => _eventManager;

  @override
  PlutoOnChangedEventCallback? get onChanged => _onChanged;

  PlutoOnChangedEventCallback? _onChanged;

  @override
  PlutoOnSelectedEventCallback? get onSelected => _onSelected;

  PlutoOnSelectedEventCallback? _onSelected;

  @override
  PlutoOnSortedEventCallback? get onSorted => _onSorted;

  PlutoOnSortedEventCallback? _onSorted;

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
  PlutoColumnMenuDelegate get columnMenuDelegate => _columnMenuDelegate;

  PlutoColumnMenuDelegate _columnMenuDelegate =
      const PlutoDefaultColumnMenuDelegate();

  @override
  CreateHeaderCallBack? get createHeader => _createHeader;

  CreateHeaderCallBack? _createHeader;

  @override
  CreateFooterCallBack? get createFooter => _createFooter;

  CreateFooterCallBack? _createFooter;

  @override
  PlutoGridLocaleText get localeText => configuration.localeText;

  @override
  PlutoGridStyleConfig get style => configuration.style;

  @override
  void setKeyManager(PlutoGridKeyManager? keyManager) {
    _keyManager = keyManager;
  }

  @override
  void setEventManager(PlutoGridEventManager? eventManager) {
    _eventManager = eventManager;
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
  void setOnSorted(PlutoOnSortedEventCallback? onSorted) {
    _onSorted = onSorted;
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
  void setColumnMenuDelegate(PlutoColumnMenuDelegate? columnMenuDelegate) {
    if (columnMenuDelegate == null) {
      return;
    }

    _columnMenuDelegate = columnMenuDelegate;
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
  void setConfiguration(
    PlutoGridConfiguration? configuration, {
    bool updateLocale = true,
    bool applyColumnFilter = true,
  }) {
    _configuration = configuration ?? const PlutoGridConfiguration();

    if (updateLocale) {
      _configuration!.updateLocale();
    }

    if (applyColumnFilter) {
      _configuration!.applyColumnFilter(refColumns);
    }
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
        PlutoGridOnSelectedEvent(
          row: currentRow,
          rowIdx: currentRowIdx,
          cell: currentCell,
        ),
      );
    }
  }

  @override
  void forceUpdate() {
    if (gridKey?.currentContext == null) {
      return;
    }

    gridKey!.currentContext!
        .findAncestorStateOfType<PlutoGridState>()!
        // ignore: invalid_use_of_protected_member
        .setState(() {});
  }
}
