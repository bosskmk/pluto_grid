import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class IGridState {
  GlobalKey get gridKey;

  PlutoGridMode get mode;

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

  void setKeyManager(PlutoGridKeyManager keyManager);

  void setEventManager(PlutoGridEventManager eventManager);

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
  PlutoGridConfiguration get configuration => _configuration!;

  PlutoGridConfiguration? _configuration;

  PlutoGridKeyManager? _keyManager;

  @override
  PlutoGridKeyManager? get keyManager => _keyManager;

  PlutoGridEventManager? _eventManager;

  @override
  PlutoGridEventManager? get eventManager => _eventManager;

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
      _configuration!.applyColumnFilter(refColumns.originalList);
    }
  }

  @override
  void resetCurrentState({bool notify = true}) {
    clearCurrentCell(notify: false);

    clearCurrentSelecting(notify: false);

    notifyListeners(notify, resetCurrentState.hashCode);
  }

  @override
  void handleOnSelected() {
    if (mode.isSelect == true && onSelected != null) {
      onSelected!(
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
    if (gridKey.currentContext == null) {
      return;
    }

    gridKey.currentContext!
        .findAncestorStateOfType<PlutoGridState>()!
        // ignore: invalid_use_of_protected_member
        .setState(() {});
  }
}
