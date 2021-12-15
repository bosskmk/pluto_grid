import 'package:flutter/material.dart';

class PlutoChangeNotifier extends ChangeNotifier {
  bool _disposed = false;

  bool get hasRemainingFrame => remainingFrameCount > 0;

  int get remainingFrameCount => _remainingFrameCount;

  int _remainingFrameCount = 0;

  @override
  dispose() {
    _disposed = true;
    super.dispose();
  }

  notifyListeners() {
    if (!_disposed) {
      _remainingFrameCount += 1;
      super.notifyListeners();

      WidgetsBinding.instance?.endOfFrame.whenComplete(() {
        _remainingFrameCount = 0;
      });
    }
  }

  void notifyListenersOnPostFrame() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      notifyListeners();
    });
  }
}
