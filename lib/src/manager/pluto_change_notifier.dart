import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PlutoChangeNotifier extends ChangeNotifier {
  final PublishSubject<PlutoNotifierEvent> _streamNotifier =
      PublishSubject<PlutoNotifierEvent>();

  PublishSubject<PlutoNotifierEvent> get streamNotifier => _streamNotifier;

  bool _disposed = false;

  final Set<int> _notifier = {};

  Set<int> _drainNotifier() {
    final drain = <int>{..._notifier};
    _notifier.clear();
    return drain;
  }

  @protected
  void addNotifier(int hash) {
    _notifier.add(hash);
  }

  @override
  void dispose() {
    _disposed = true;

    _streamNotifier.close();

    super.dispose();
  }

  @override
  void notifyListeners([bool notify = true, int? notifier]) {
    if (notifier != null) {
      addNotifier(notifier);
    }

    if (!notify) {
      return;
    }

    if (!_disposed) {
      super.notifyListeners();

      _streamNotifier.add(PlutoNotifierEvent(_drainNotifier()));
    }
  }

  void notifyListenersOnPostFrame([bool notify = true, int? notifier]) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners(notify, notifier);
    });
  }
}

class PlutoNotifierEvent {
  PlutoNotifierEvent(this._notifier);

  final Set<int> _notifier;

  Set<int> get notifier => {..._notifier};

  bool any(Set<int> hashes) {
    return _notifier.isEmpty ? true : _notifier.any((e) => hashes.contains(e));
  }
}

class PlutoNotifierEventForceUpdate extends PlutoNotifierEvent {
  PlutoNotifierEventForceUpdate._() : super({});

  static PlutoNotifierEventForceUpdate instance =
      PlutoNotifierEventForceUpdate._();

  @override
  bool any(Set<int> hashes) {
    return true;
  }
}
