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

  /// To delegate sort handling in the [PlutoInfinityScrollRows] or [PlutoLazyPagination] widget
  /// Whether to override the default sort processing.
  /// If this value is true,
  /// the default sorting processing of [PlutoGrid] is ignored and only events are issued.
  /// [PlutoGridChangeColumnSortEvent]
  bool get sortOnlyEvent;

  /// To delegate filtering processing in the [PlutoInfinityScrollRows] or [PlutoLazyPagination] widget
  /// Whether to override the default filtering processing.
  /// If this value is true,
  /// the default filtering processing of [PlutoGrid] is ignored and only events are issued.
  /// [PlutoGridSetColumnFilterEvent]
  bool get filterOnlyEvent;

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

  /// Set whether to ignore the default sort processing and issue only events.
  /// [PlutoGridChangeColumnSortEvent]
  void setSortOnlyEvent(bool flag);

  /// Set whether to ignore the basic filtering process and issue only events.
  /// [PlutoGridSetColumnFilterEvent]
  void setFilterOnlyEvent(bool flag);

  void forceUpdate();
}

class _State {
  PlutoGridConfiguration? _configuration;

  PlutoGridKeyManager? _keyManager;

  PlutoGridEventManager? _eventManager;

  bool _sortOnlyEvent = false;

  bool _filterOnlyEvent = false;
}

mixin GridState implements IPlutoGridState {
  final _State _state = _State();

  @override
  PlutoGridConfiguration get configuration => _state._configuration!;

  @override
  PlutoGridKeyManager? get keyManager => _state._keyManager;

  @override
  PlutoGridEventManager? get eventManager => _state._eventManager;

  @override
  PlutoGridLocaleText get localeText => configuration.localeText;

  @override
  PlutoGridStyleConfig get style => configuration.style;

  @override
  bool get sortOnlyEvent => _state._sortOnlyEvent;

  @override
  bool get filterOnlyEvent => _state._filterOnlyEvent;

  @override
  void setKeyManager(PlutoGridKeyManager? keyManager) {
    _state._keyManager = keyManager;
  }

  @override
  void setEventManager(PlutoGridEventManager? eventManager) {
    _state._eventManager = eventManager;
  }

  @override
  void setConfiguration(
    PlutoGridConfiguration? configuration, {
    bool updateLocale = true,
    bool applyColumnFilter = true,
  }) {
    _state._configuration = configuration ?? const PlutoGridConfiguration();

    if (updateLocale) {
      _state._configuration!.updateLocale();
    }

    if (applyColumnFilter) {
      _state._configuration!.applyColumnFilter(refColumns.originalList);
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
  void setSortOnlyEvent(bool flag) {
    _state._sortOnlyEvent = flag;
  }

  @override
  void setFilterOnlyEvent(bool flag) {
    _state._filterOnlyEvent = flag;
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
