import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PlutoChangeNotifier extends ChangeNotifier {
  final PublishSubject<PlutoNotifierEvent> _streamNotifier =
      PublishSubject<PlutoNotifierEvent>();

  PublishSubject<PlutoNotifierEvent> get streamNotifier => _streamNotifier;

  bool _disposed = false;

  @override
  dispose() {
    _disposed = true;

    _streamNotifier.close();

    super.dispose();
  }

  @override
  notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();

      _streamNotifier.add(PlutoNotifierEvent.instance);
    }
  }

  void notifyListenersOnPostFrame() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }
}

class PlutoNotifierEvent {
  const PlutoNotifierEvent();

  static PlutoNotifierEvent instance = const PlutoNotifierEvent();
}
