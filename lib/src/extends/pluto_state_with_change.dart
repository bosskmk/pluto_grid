import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

typedef PlutoStateResetStateCallback = void Function(
    PlutoStateUpdateStateFunction update);

typedef PlutoStateUpdateStateFunction = T Function<T>(
  T oldValue,
  T newValue, {
  bool Function(T a, T b)? compare,
  bool? ignoreChange,
});

abstract class PlutoStatefulWidget<StateManager extends ChangeNotifier>
    extends StatefulWidget implements _HasPlutoStateManager {
  const PlutoStatefulWidget({Key? key}) : super(key: key);
}

abstract class PlutoStateWithChange<T extends PlutoStatefulWidget>
    extends State<T> {
  late final StreamSubscription _subscription;

  bool _initialized = false;

  bool _changed = false;

  bool get changed => _changed;

  StatefulElement? get _statefulElement =>
      mounted ? context as StatefulElement? : null;

  void onChange(PlutoStreamNotifierEvent event);

  bool allowStream(PlutoStreamNotifierEvent event) {
    return true;
  }

  @override
  void dispose() {
    _subscription.cancel();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    onChange(PlutoInitStateStreamNotifierEvent());

    _subscription = widget.stateManager.streamNotifier.stream
        .where(allowStream)
        .listen(onChange);

    _initialized = true;
  }

  void resetState(PlutoStateResetStateCallback callback) {
    callback(_update);
    // it may have not been layout yet.
    if (mounted &&
        _initialized &&
        _changed &&
        widget.stateManager.maxWidth != null) {
      _changed = false;
      _statefulElement?.markNeedsBuild();
    }
  }

  U _update<U>(
    U oldValue,
    U newValue, {
    bool Function(U a, U b)? compare,
    bool? ignoreChange = false,
  }) {
    if (oldValue == null) {
      _changed = true;
    } else if (ignoreChange == false && _changed == false) {
      _changed = compare == null
          ? oldValue != newValue
          : compare(oldValue, newValue) == false;
    }

    return newValue;
  }
}

mixin PlutoStateWithKeepAlive<T extends StatefulWidget>
    on AutomaticKeepAliveClientMixin<T> {
  bool _keepAlive = false;

  KeepAliveHandle? _keepAliveHandle;

  @override
  bool get wantKeepAlive => _keepAlive;

  void setKeepAlive(bool flag) {
    if (_keepAlive != flag) {
      _keepAlive = flag;

      updateKeepAlive();
    }
  }

  @override
  @protected
  void updateKeepAlive() {
    if (wantKeepAlive) {
      if (_keepAliveHandle == null) _ensureKeepAlive();
    } else {
      if (_keepAliveHandle != null) _releaseKeepAlive();
    }
  }

  void _ensureKeepAlive() {
    assert(_keepAliveHandle == null);
    _keepAliveHandle = KeepAliveHandle();
    KeepAliveNotification(_keepAliveHandle!).dispatch(context);
  }

  void _releaseKeepAlive() {
    _keepAliveHandle!.release();
    _keepAliveHandle = null;
  }
}

abstract class _HasPlutoStateManager {
  PlutoGridStateManager get stateManager;
}
