import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class PlutoChangeNotifier extends ChangeNotifier {
  final PublishSubject<PlutoStreamNotifierEvent> _streamNotifier =
      PublishSubject<PlutoStreamNotifierEvent>();

  PublishSubject<PlutoStreamNotifierEvent> get streamNotifier =>
      _streamNotifier;

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

      _streamNotifier.add(PlutoEmptyStreamNotifierEvent());
    }
  }

  void notifyListenersOnPostFrame() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }

  notifyStreamListeners(PlutoStreamNotifierEvent event) {
    if (!_disposed) {
      super.notifyListeners();

      _streamNotifier.add(event);
    }
  }
}

abstract class PlutoStreamNotifierEvent {}

class PlutoEmptyStreamNotifierEvent extends PlutoStreamNotifierEvent {}

class PlutoInitStateStreamNotifierEvent extends PlutoStreamNotifierEvent {}

class PlutoSetCurrentCellStreamNotifierEvent extends PlutoStreamNotifierEvent {}

class PlutoVisibilityColumnStreamNotifierEvent
    extends PlutoStreamNotifierEvent {}
