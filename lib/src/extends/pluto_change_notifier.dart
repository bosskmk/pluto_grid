import 'package:flutter/material.dart';

class PlutoChangeNotifier extends ChangeNotifier {
  bool _disposed = false;

  @override
  dispose() {
    _disposed = true;
    super.dispose();
  }

  notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void notifyListenersOnPostFrame() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }
}
