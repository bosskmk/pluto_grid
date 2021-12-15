import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

typedef _ResetStateCallback = void Function(_UpdateStateFunction update);

typedef _UpdateStateFunction = T Function<T>(
  T oldValue,
  T newValue, {
  _CompareFunction<T>? compare,
  bool? destructureList,
  bool? ignoreChange,
});

typedef _CompareFunction<T> = bool Function(T a, T b);

abstract class PlutoStatefulWidget extends StatefulWidget
    implements HasPlutoStateManager<PlutoGridStateManager> {
  PlutoStatefulWidget({Key? key}) : super(key: key);
}

abstract class PlutoStateWithChange<T extends PlutoStatefulWidget>
    extends State<T> {
  bool _initialized = false;

  bool _changed = false;

  bool get changed => _changed;

  StatefulElement? get _statefulElement =>
      mounted ? context as StatefulElement? : null;

  void onChange();

  @override
  void dispose() {
    widget.stateManager.removeListener(onChange);

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    onChange();

    widget.stateManager.addListener(onChange);

    _initialized = true;
  }

  void resetState(_ResetStateCallback callback) {
    callback(_update);
    if (mounted && _initialized && _changed) {
      _changed = false;
      _statefulElement?.markNeedsBuild();
    }
  }

  T _update<T>(
    T oldValue,
    T newValue, {
    _CompareFunction<T>? compare,
    bool? destructureList = false,
    bool? ignoreChange = false,
  }) {
    if (ignoreChange == false && _changed == false) {
      _changed = compare == null
          ? oldValue != newValue
          : compare(oldValue, newValue) == false;
    }

    if (destructureList!) {
      if (newValue is Iterable) {
        return newValue.toList() as T;
      }

      PlutoLog(
        'Cannot destructure newValue.',
        type: PlutoLogType.warning,
      );
    }

    return newValue;
  }
}

abstract class PlutoStateWithChangeKeepAlive<T extends PlutoStatefulWidget>
    extends PlutoStateWithChange<T> with AutomaticKeepAliveClientMixin {
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

abstract class HasPlutoStateManager<T extends ChangeNotifier> {
  T get stateManager;
}
