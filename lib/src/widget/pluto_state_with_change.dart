part of '../../pluto_grid.dart';

typedef _ResetStateCallback = void Function(_UpdateStateFunction update);

typedef _UpdateStateFunction = T Function<T>(
  T oldValue,
  T newValue, {
  _CompareFunction<T> compare,
  bool destructureList,
});

typedef _CompareFunction<T> = bool Function(T a, T b);

abstract class _PlutoStatefulWidget extends StatefulWidget
    implements _HasPlutoStateManager {
  _PlutoStatefulWidget({Key key}) : super(key: key);
}

abstract class _PlutoStateWithChange<T extends _PlutoStatefulWidget>
    extends State<T> {
  bool _initialized = false;

  bool _changed = false;

  StatefulElement get _statefulElement => mounted ? context : null;

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
    _CompareFunction<T> compare,
    bool destructureList = false,
  }) {
    if (_changed == false) {
      _changed = compare == null
          ? oldValue != newValue
          : compare(oldValue, newValue) == false;
    }

    if (destructureList) {
      if (newValue is List<PlutoRow>) {
        return [...newValue] as T;
      } else if (newValue is List<PlutoColumn>) {
        return [...newValue] as T;
      } else {
        developer.log(
          'Warning',
          name: '_PlutoStateWithChange',
          error: 'Unhandled destructureList sub type.',
        );
      }
    }

    return newValue;
  }
}

abstract class _PlutoStateWithChangeKeepAlive<T extends _PlutoStatefulWidget>
    extends _PlutoStateWithChange<T> with AutomaticKeepAliveClientMixin {
  bool _keepAlive = false;

  KeepAliveHandle _keepAliveHandle;

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
    KeepAliveNotification(_keepAliveHandle).dispatch(context);
  }

  void _releaseKeepAlive() {
    _keepAliveHandle.release();
    _keepAliveHandle = null;
  }
}

abstract class _HasPlutoStateManager {
  final PlutoStateManager stateManager;

  _HasPlutoStateManager({
    @required this.stateManager,
  });
}
